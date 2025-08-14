import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/models/sales_model.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/models/stock_log_model.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:inventory_sudan/ui/widgets/common/period_selector.dart';

class StatisticsController extends GetxController {
  final DataService _dataService = serviceLocator<DataService>();

  // Loading states
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Period selection
  final Rx<StatisticsPeriod> selectedPeriod = StatisticsPeriod.thisMonth.obs;
  final Rx<DateTimeRange?> customDateRange = Rx<DateTimeRange?>(null);

  // Statistics data
  final RxMap<String, dynamic> overviewStats = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> salesStats = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> inventoryStats = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> productionStats = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> financialStats = <String, dynamic>{}.obs;

  // Raw data
  List<FarmToDryingModel> farmToDryingRecords = [];
  List<SalesModel> salesRecords = [];
  List<PackagingModel> packagingRecords = [];
  List<ProductsAfterDryingModel> productsAfterDryingRecords = [];
  List<EmptyPackagesInventoryModel> emptyPackagesRecords = [];
  List<FinishedProductsModel> finishedProductsRecords = [];
  List<StockLogModel> stockLogRecords = [];

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Load all data in parallel
      await Future.wait([
        _loadFarmToDryingData(),
        _loadSalesData(),
        _loadPackagingData(),
        _loadStockLogData(),
      ]);

      // Calculate statistics
      _calculateOverviewStats();
      _calculateSalesStats();
      _calculateInventoryStats();
      _calculateProductionStats();
      _calculateFinancialStats();

      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'حدث خطأ في تحميل الإحصائيات: ${e.toString()}';
      isLoading.value = false;
    }
  }

  Future<void> _loadFarmToDryingData() async {
    farmToDryingRecords = await _dataService.getFarmToDryingRecords();
  }

  Future<void> _loadSalesData() async {
    salesRecords = await _dataService.getSalesRecords();
  }

  Future<void> _loadPackagingData() async {
    packagingRecords = await _dataService.getPackagingRecords();
    productsAfterDryingRecords = await _dataService.getProductsAfterDrying();
    emptyPackagesRecords = await _dataService.getEmptyPackagesInventory();
    finishedProductsRecords = await _dataService.getFinishedProducts();
  }

  Future<void> _loadStockLogData() async {
    stockLogRecords = await _dataService.getStockLogRecords();
  }

  void _calculateOverviewStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonth = DateTime(now.year, now.month, 1);

    // Today's sales
    final todaySales = salesRecords.where((sale) {
      final saleDate = DateTime(sale.saleDate.year, sale.saleDate.month, sale.saleDate.day);
      return saleDate.isAtSameMomentAs(today);
    }).length;

    // This month's sales
    final thisMonthSales = salesRecords.where((sale) {
      return sale.saleDate.isAfter(thisMonth);
    }).length;

    // Total products in drying
    final totalWeightInDrying = farmToDryingRecords
        .where((record) => record.totalWeightAfterDrying == null || record.totalWeightAfterDrying == 0)
        .fold<double>(0, (sum, record) => sum + (record.totalWeightToDryer ?? 0));

    // Low stock items
    final lowStockItems = emptyPackagesRecords.where((item) => item.stock <= 5).length;

    // Recent stock discrepancies
    final recentDiscrepancies = stockLogRecords
        .where((log) => log.hasDiscrepancies && log.logDate.isAfter(now.subtract(const Duration(days: 30))))
        .length;

    overviewStats.value = {
      'todaySales': todaySales,
      'thisMonthSales': thisMonthSales,
      'totalWeightInDrying': totalWeightInDrying,
      'lowStockItems': lowStockItems,
      'recentDiscrepancies': recentDiscrepancies,
      'totalBatches': farmToDryingRecords.length,
      'finishedProducts': finishedProductsRecords.length,
    };
  }

  void _calculateSalesStats() {
    final dateRange = currentDateRange;
    final filteredSales = salesRecords
        .where((sale) =>
            sale.saleDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            sale.saleDate.isBefore(dateRange.end.add(const Duration(days: 1))))
        .toList();

    // Period revenue
    final periodRevenue = filteredSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    // Calculate comparison period for growth
    final periodDuration = dateRange.end.difference(dateRange.start);
    final comparisonStart = dateRange.start.subtract(periodDuration);
    final comparisonEnd = dateRange.start.subtract(const Duration(days: 1));

    final comparisonRevenue = salesRecords
        .where((sale) =>
            sale.saleDate.isAfter(comparisonStart) &&
            sale.saleDate.isBefore(comparisonEnd.add(const Duration(days: 1))))
        .fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    // Payment status breakdown (for selected period)
    final paidSales = filteredSales.where((sale) => sale.paymentStatus == 'paid').length;
    final unpaidSales = filteredSales.where((sale) => sale.paymentStatus == 'unpaid').length;
    final partialSales = filteredSales.where((sale) => sale.paymentStatus == 'partial').length;

    // Outstanding amount (for selected period)
    final outstandingAmount = filteredSales
        .where((sale) => sale.paymentStatus != 'paid')
        .fold<double>(0, (sum, sale) => sum + sale.remainingAmount);

    // Top buyers (for selected period)
    final Map<String, int> buyerCounts = {};
    for (var sale in filteredSales) {
      buyerCounts[sale.buyerName] = (buyerCounts[sale.buyerName] ?? 0) + 1;
    }
    final topBuyers = buyerCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Sales by buyer type (for selected period)
    final Map<String, int> salesByBuyerType = {};
    for (var sale in filteredSales) {
      salesByBuyerType[sale.buyerType] = (salesByBuyerType[sale.buyerType] ?? 0) + 1;
    }

    salesStats.value = {
      'periodRevenue': periodRevenue,
      'comparisonRevenue': comparisonRevenue,
      'revenueGrowth': comparisonRevenue > 0 ? ((periodRevenue - comparisonRevenue) / comparisonRevenue) * 100 : 0,
      'paidSales': paidSales,
      'unpaidSales': unpaidSales,
      'partialSales': partialSales,
      'outstandingAmount': outstandingAmount,
      'topBuyers': topBuyers.take(5).toList(),
      'salesByBuyerType': salesByBuyerType,
      'totalSales': filteredSales.length,
    };
  }

  void _calculateInventoryStats() {
    // Current stock levels
    final totalEmptyPackages = emptyPackagesRecords.fold<int>(0, (sum, item) => sum + item.stock);
    final totalFinishedProducts = finishedProductsRecords.fold<int>(0, (sum, item) => sum + item.quantity);

    // Low stock alerts
    final lowStockItems = emptyPackagesRecords.where((item) => item.stock <= 5).toList();

    // Inventory value
    final inventoryValue = emptyPackagesRecords.fold<double>(0, (sum, item) => sum + item.totalCost);

    // Stock movement (last 30 days)
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    final recentStockLogs = stockLogRecords.where((log) => log.logDate.isAfter(last30Days)).toList();

    // Package type distribution
    final Map<String, int> packageTypeDistribution = {};
    for (var item in emptyPackagesRecords) {
      packageTypeDistribution[item.packageType] = (packageTypeDistribution[item.packageType] ?? 0) + item.stock;
    }

    inventoryStats.value = {
      'totalEmptyPackages': totalEmptyPackages,
      'totalFinishedProducts': totalFinishedProducts,
      'lowStockCount': lowStockItems.length,
      'lowStockItems': lowStockItems,
      'inventoryValue': inventoryValue,
      'recentStockMovements': recentStockLogs.length,
      'packageTypeDistribution': packageTypeDistribution,
    };
  }

  void _calculateProductionStats() {
    final dateRange = currentDateRange;
    final filteredRecords = farmToDryingRecords
        .where((record) =>
            record.purchaseDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            record.purchaseDate.isBefore(dateRange.end.add(const Duration(days: 1))))
        .toList();

    // Total weight processed (for selected period)
    final totalWeightProcessed =
        filteredRecords.fold<double>(0, (sum, record) => sum + (record.totalWeightBeforeDrying ?? 0));
    final totalWeightAfterDrying =
        filteredRecords.fold<double>(0, (sum, record) => sum + (record.totalWeightAfterDrying ?? 0));

    // Average drying percentage (for selected period)
    final recordsWithDryingPercentage =
        filteredRecords.where((record) => record.dryingPercentage != null && record.dryingPercentage! > 0).toList();

    final averageDryingPercentage = recordsWithDryingPercentage.isNotEmpty
        ? recordsWithDryingPercentage.fold<double>(0, (sum, record) => sum + record.dryingPercentage!) /
            recordsWithDryingPercentage.length
        : 0.0;

    // Average drying days (for selected period)
    final recordsWithDryingDays =
        filteredRecords.where((record) => record.dryingDays != null && record.dryingDays! > 0).toList();

    final averageDryingDays = recordsWithDryingDays.isNotEmpty
        ? recordsWithDryingDays.fold<int>(0, (sum, record) => sum + record.dryingDays!) / recordsWithDryingDays.length
        : 0.0;

    // Production by product type (for selected period)
    final Map<String, double> productionByType = {};
    for (var record in filteredRecords) {
      final productName = record.productName;
      productionByType[productName] = (productionByType[productName] ?? 0) + (record.totalWeightAfterDrying ?? 0);
    }

    productionStats.value = {
      'totalWeightProcessed': totalWeightProcessed,
      'totalWeightAfterDrying': totalWeightAfterDrying,
      'weightLossPercentage':
          totalWeightProcessed > 0 ? ((totalWeightProcessed - totalWeightAfterDrying) / totalWeightProcessed) * 100 : 0,
      'averageDryingPercentage': averageDryingPercentage,
      'averageDryingDays': averageDryingDays,
      'productionByType': productionByType,
      'totalBatches': filteredRecords.length,
    };
  }

  void _calculateFinancialStats() {
    final dateRange = currentDateRange;

    // Filter records by selected period
    final filteredFarmRecords = farmToDryingRecords
        .where((record) =>
            record.purchaseDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            record.purchaseDate.isBefore(dateRange.end.add(const Duration(days: 1))))
        .toList();

    final filteredSalesRecords = salesRecords
        .where((sale) =>
            sale.saleDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            sale.saleDate.isBefore(dateRange.end.add(const Duration(days: 1))))
        .toList();

    // Total costs and revenue (for selected period)
    final totalPurchaseCosts = filteredFarmRecords.fold<double>(0, (sum, record) => sum + record.totalCosts);
    final totalRevenue = filteredSalesRecords.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final totalCollected = filteredSalesRecords.fold<double>(0, (sum, sale) => sum + sale.collectedAmount);

    // Profit calculation (for selected period)
    final grossProfit = totalRevenue - totalPurchaseCosts;
    final profitMargin = totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0;

    // Cost breakdown (for selected period)
    final totalLogisticsCosts =
        filteredFarmRecords.fold<double>(0, (sum, record) => sum + (record.logisticsTotalCost ?? 0));
    final totalLaborCosts = filteredFarmRecords.fold<double>(0, (sum, record) => sum + (record.laborCost ?? 0));
    final totalTransportationCosts =
        filteredFarmRecords.fold<double>(0, (sum, record) => sum + (record.transportationCost ?? 0));

    financialStats.value = {
      'totalPurchaseCosts': totalPurchaseCosts,
      'totalRevenue': totalRevenue,
      'totalCollected': totalCollected,
      'outstandingAmount': totalRevenue - totalCollected,
      'grossProfit': grossProfit,
      'profitMargin': profitMargin,
      'totalLogisticsCosts': totalLogisticsCosts,
      'totalLaborCosts': totalLaborCosts,
      'totalTransportationCosts': totalTransportationCosts,
    };
  }

  Future<void> refreshStatistics() async {
    await loadStatistics();
  }

  void changePeriod(StatisticsPeriod period) {
    selectedPeriod.value = period;
    _recalculateStats();
  }

  void changeCustomDateRange(DateTimeRange dateRange) {
    customDateRange.value = dateRange;
    _recalculateStats();
  }

  DateTimeRange get currentDateRange {
    if (selectedPeriod.value == StatisticsPeriod.custom && customDateRange.value != null) {
      return customDateRange.value!;
    }
    return selectedPeriod.value.getDateRange();
  }

  void _recalculateStats() {
    _calculateOverviewStats();
    _calculateSalesStats();
    _calculateInventoryStats();
    _calculateProductionStats();
    _calculateFinancialStats();
  }

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} جنيه';
  }

  String formatWeight(double weight) {
    return '${weight.toStringAsFixed(1)} كجم';
  }

  String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
}
