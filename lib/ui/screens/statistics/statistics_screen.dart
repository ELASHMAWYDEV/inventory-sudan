import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/controllers/statistics/statistics_controller.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/ui/widgets/common/period_selector.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatisticsController>(
      init: StatisticsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'الإحصائيات',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.refreshStatistics(),
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.hasError.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.refreshStatistics(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.refreshStatistics(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    Obx(() => PeriodSelector(
                          selectedPeriod: controller.selectedPeriod.value,
                          customDateRange: controller.customDateRange.value,
                          onPeriodChanged: controller.changePeriod,
                          onCustomDateRangeChanged: controller.changeCustomDateRange,
                        )),

                    const SizedBox(height: 24),

                    // Overview Section
                    _buildSectionHeader('نظرة عامة', Icons.dashboard),
                    const SizedBox(height: 16),
                    _buildOverviewCards(controller),

                    const SizedBox(height: 32),

                    // Sales Statistics
                    _buildSectionHeaderWithPeriod('إحصائيات المبيعات', Icons.point_of_sale, controller),
                    const SizedBox(height: 16),
                    _buildSalesSection(controller),

                    const SizedBox(height: 32),

                    // Production Statistics
                    _buildSectionHeaderWithPeriod('إحصائيات الإنتاج', Icons.agriculture, controller),
                    const SizedBox(height: 16),
                    _buildProductionSection(controller),

                    const SizedBox(height: 32),

                    // Inventory Statistics
                    _buildSectionHeader('إحصائيات المخزون', Icons.inventory),
                    const SizedBox(height: 16),
                    _buildInventorySection(controller),

                    const SizedBox(height: 32),

                    // Financial Statistics
                    _buildSectionHeaderWithPeriod('الإحصائيات المالية', Icons.attach_money, controller),
                    const SizedBox(height: 16),
                    _buildFinancialSection(controller),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.heading2,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderWithPeriod(String title, IconData icon, StatisticsController controller) {
    return Obx(() => Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.heading2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'الفترة: ${controller.selectedPeriod.value.displayName}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildOverviewCards(StatisticsController controller) {
    final overviewData = controller.overviewStats;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'مبيعات اليوم',
                value: '${overviewData['todaySales'] ?? 0}',
                icon: Icons.today,
                color: AppColors.sales,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'مبيعات الشهر',
                value: '${overviewData['thisMonthSales'] ?? 0}',
                icon: Icons.calendar_month,
                color: AppColors.sales,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'قيد التجفيف',
                value: controller.formatWeight(overviewData['totalWeightInDrying']?.toDouble() ?? 0),
                icon: Icons.timer,
                color: AppColors.farmToDrying,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'نفاذ المخزون',
                value: '${overviewData['lowStockItems'] ?? 0}',
                icon: Icons.warning_amber,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'إجمالي الدفعات',
                value: '${overviewData['totalBatches'] ?? 0}',
                icon: Icons.inventory_2,
                color: AppColors.stockLog,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'المنتجات الجاهزة',
                value: '${overviewData['finishedProducts'] ?? 0}',
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesSection(StatisticsController controller) {
    final salesData = controller.salesStats;

    return Column(
      children: [
        // Revenue cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'إيرادات الفترة',
                value: controller.formatCurrency(salesData['periodRevenue']?.toDouble() ?? 0),
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'نمو الإيرادات',
                value: controller.formatPercentage(salesData['revenueGrowth']?.toDouble() ?? 0),
                icon: Icons.show_chart,
                color: (salesData['revenueGrowth']?.toDouble() ?? 0) >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Payment status
        _buildPaymentStatusCard(controller, salesData),

        const SizedBox(height: 16),

        // Top buyers
        if (salesData['topBuyers'] != null && (salesData['topBuyers'] as List).isNotEmpty)
          _buildTopBuyersCard(salesData['topBuyers'] as List),
      ],
    );
  }

  Widget _buildProductionSection(StatisticsController controller) {
    final productionData = controller.productionStats;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'إجمالي المعالج',
                value: controller.formatWeight(productionData['totalWeightProcessed']?.toDouble() ?? 0),
                icon: Icons.agriculture,
                color: AppColors.farmToDrying,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'بعد التجفيف',
                value: controller.formatWeight(productionData['totalWeightAfterDrying']?.toDouble() ?? 0),
                icon: Icons.done,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'نسبة الفقد',
                value: controller.formatPercentage(productionData['weightLossPercentage']?.toDouble() ?? 0),
                icon: Icons.trending_down,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'متوسط أيام التجفيف',
                value: '${(productionData['averageDryingDays']?.toDouble() ?? 0).toStringAsFixed(1)} يوم',
                icon: Icons.schedule,
                color: AppColors.info,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Production by type
        if (productionData['productionByType'] != null)
          _buildProductionByTypeCard(productionData['productionByType'] as Map<String, double>, controller),
      ],
    );
  }

  Widget _buildInventorySection(StatisticsController controller) {
    final inventoryData = controller.inventoryStats;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'العبوات الفارغة',
                value: '${inventoryData['totalEmptyPackages'] ?? 0}',
                icon: Icons.inventory,
                color: AppColors.packaging,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'المنتجات المعبأة',
                value: '${inventoryData['totalFinishedProducts'] ?? 0}',
                icon: Icons.check_box,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'قيمة المخزون',
                value: controller.formatCurrency(inventoryData['inventoryValue']?.toDouble() ?? 0),
                icon: Icons.account_balance_wallet,
                color: AppColors.stockLog,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'المخزون المنخفض',
                value: '${inventoryData['lowStockCount'] ?? 0}',
                icon: Icons.warning,
                color: AppColors.error,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Low stock items
        if (inventoryData['lowStockItems'] != null && (inventoryData['lowStockItems'] as List).isNotEmpty)
          _buildLowStockCard(inventoryData['lowStockItems'] as List),
      ],
    );
  }

  Widget _buildFinancialSection(StatisticsController controller) {
    final financialData = controller.financialStats;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'إجمالي الإيرادات',
                value: controller.formatCurrency(financialData['totalRevenue']?.toDouble() ?? 0),
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'إجمالي التكاليف',
                value: controller.formatCurrency(financialData['totalPurchaseCosts']?.toDouble() ?? 0),
                icon: Icons.trending_down,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'الربح الإجمالي',
                value: controller.formatCurrency(financialData['grossProfit']?.toDouble() ?? 0),
                icon: Icons.attach_money,
                color: (financialData['grossProfit']?.toDouble() ?? 0) >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'هامش الربح',
                value: controller.formatPercentage(financialData['profitMargin']?.toDouble() ?? 0),
                icon: Icons.percent,
                color: (financialData['profitMargin']?.toDouble() ?? 0) >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'المبلغ المحصل',
                value: controller.formatCurrency(financialData['totalCollected']?.toDouble() ?? 0),
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'المبلغ المستحق',
                value: controller.formatCurrency(financialData['outstandingAmount']?.toDouble() ?? 0),
                icon: Icons.pending,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard(StatisticsController controller, Map<String, dynamic> salesData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة المدفوعات',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentStatusItem(
                    'مدفوع',
                    '${salesData['paidSales'] ?? 0}',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildPaymentStatusItem(
                    'غير مدفوع',
                    '${salesData['unpaidSales'] ?? 0}',
                    AppColors.error,
                  ),
                ),
                Expanded(
                  child: _buildPaymentStatusItem(
                    'مدفوع جزئياً',
                    '${salesData['partialSales'] ?? 0}',
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'إجمالي المستحق: ${controller.formatCurrency(salesData['outstandingAmount']?.toDouble() ?? 0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusItem(String label, String count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopBuyersCard(List topBuyers) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أكثر العملاء شراءً',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            ...topBuyers
                .map((buyer) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              buyer.key,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${buyer.value}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionByTypeCard(Map<String, double> productionByType, StatisticsController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإنتاج حسب نوع المنتج',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            ...productionByType.entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Text(
                            controller.formatWeight(entry.value),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.farmToDrying,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockCard(List lowStockItems) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'تحذير: مخزون منخفض',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...lowStockItems
                .take(5)
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} (${item.packageType})',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${item.stock}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
