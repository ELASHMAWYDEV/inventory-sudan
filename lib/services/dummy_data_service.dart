import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/models/sales_model.dart';
import 'package:inventory_sudan/services/service_locator.dart';

class DummyDataService {
  static final _dataService = serviceLocator<DataService>();

  /// Adds comprehensive dummy batch data to test different workflow stages
  static Future<void> addDummyBatches() async {
    try {
      // Batch 1: Complete workflow (Farm → Drying → Packaging → Sales)
      await _addCompleteBatch();

      // Batch 2: Only Farm to Drying stage
      await _addFarmOnlyBatch();

      // Batch 3: Farm to Drying + Products After Drying
      await _addFarmToDryingBatch();

      // Batch 4: Farm to Drying + Products After Drying + Finished Products
      await _addFarmToPackagingBatch();

      // Batch 5: Different product - Sesame (Complete workflow)
      await _addSesameBatch();

      print('✅ Dummy batch data added successfully!');
    } catch (e) {
      print('❌ Error adding dummy batch data: $e');
    }
  }

  /// Batch 1: Complete workflow - Peanuts
  static Future<void> _addCompleteBatch() async {
    const batchNumber = 'BATCH-001';

    // 1. Farm to Drying
    final farmRecord = FarmToDryingModel(
      batchNumber: batchNumber,
      productName: 'فول سوداني',
      purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
      purchaseLocation: 'كسلا',
      supplierName: 'محمد أحمد الفاتح',
      sackCount: 100,
      productCost: 850000.0,
      logisticsCost: 25000.0,
      totalCosts: 875000.0,
      totalWeightBeforeDrying: 5000.0,
      notes: 'دفعة ممتازة من فول سوداني كسلا',
    );
    await _dataService.addFarmToDryingRecord(farmRecord);

    // 2. Products After Drying
    final productsAfterDrying = ProductsAfterDryingModel(
      batchNumber: batchNumber,
      totalGeneratedWeight: 4200.0,
      notes: 'نسبة فقدان جيدة 16%',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    );
    await _dataService.addProductsAfterDrying(productsAfterDrying);

    // 3. Finished Products
    final finishedProducts = FinishedProductsModel(
      batchNumber: batchNumber,
      emptyPackageId: 'dummy_package_1',
      quantity: 840, // 4200kg / 5kg packages = 840 packages
      notes: 'تعبئة في أكياس 5 كيلو',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    );
    await _dataService.addFinishedProducts(finishedProducts);

    // 4. Sales Records
    final sale1 = SalesModel(
      saleDate: DateTime.now().subtract(const Duration(days: 15)),
      items: [
        SaleItem(
          productName: 'فول سوداني',
          quantityOfPackages: 300,
          pricePerPackage: 1800.0,
          packageType: 'B2B',
          totalPrice: 540000.0,
        ),
      ],
      buyerType: 'Supermarket',
      buyerName: 'كارفور الخرطوم',
      buyerLocation: 'الخرطوم',
      totalAmount: 540000.0,
      collectedAmount: 540000.0,
      remainingAmount: 0.0,
      paymentStatus: 'paid',
      notes: 'دفع نقدي كامل',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );

    final sale2 = SalesModel(
      saleDate: DateTime.now().subtract(const Duration(days: 10)),
      items: [
        SaleItem(
          productName: 'فول سوداني',
          quantityOfPackages: 200,
          pricePerPackage: 1900.0,
          packageType: 'B2C',
          totalPrice: 380000.0,
        ),
      ],
      buyerType: 'Individual',
      buyerName: 'أحمد محمد علي',
      buyerLocation: 'أم درمان',
      totalAmount: 380000.0,
      collectedAmount: 200000.0,
      remainingAmount: 180000.0,
      paymentStatus: 'partial',
      notes: 'دفعة أولى 200 ألف، الباقي آجل',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );

    await _dataService.addSale(sale1);
    await _dataService.addSale(sale2);
  }

  /// Batch 2: Only Farm to Drying stage - Corn
  static Future<void> _addFarmOnlyBatch() async {
    const batchNumber = 'BATCH-002';

    final farmRecord = FarmToDryingModel(
      batchNumber: batchNumber,
      productName: 'ذرة',
      purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
      purchaseLocation: 'الجزيرة',
      supplierName: 'علي محمد حسن',
      sackCount: 80,
      productCost: 420000.0,
      logisticsCost: 18000.0,
      totalCosts: 438000.0,
      totalWeightBeforeDrying: 4000.0,
      notes: 'تم الاستلام حديثاً، في انتظار التجفيف',
    );
    await _dataService.addFarmToDryingRecord(farmRecord);
  }

  /// Batch 3: Farm to Drying + Products After Drying - Sesame
  static Future<void> _addFarmToDryingBatch() async {
    const batchNumber = 'BATCH-003';

    // 1. Farm to Drying
    final farmRecord = FarmToDryingModel(
      batchNumber: batchNumber,
      productName: 'سمسم',
      purchaseDate: DateTime.now().subtract(const Duration(days: 20)),
      purchaseLocation: 'سنار',
      supplierName: 'فاطمة عبدالله',
      sackCount: 60,
      productCost: 720000.0,
      logisticsCost: 22000.0,
      totalCosts: 742000.0,
      totalWeightBeforeDrying: 3000.0,
      notes: 'سمسم أبيض ممتاز من سنار',
    );
    await _dataService.addFarmToDryingRecord(farmRecord);

    // 2. Products After Drying
    final productsAfterDrying = ProductsAfterDryingModel(
      batchNumber: batchNumber,
      totalGeneratedWeight: 2700.0,
      notes: 'نسبة فقدان 10% - ممتازة للسمسم',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );
    await _dataService.addProductsAfterDrying(productsAfterDrying);
  }

  /// Batch 4: Farm to Drying + Products After Drying + Finished Products - Peanuts
  static Future<void> _addFarmToPackagingBatch() async {
    const batchNumber = 'BATCH-004';

    // 1. Farm to Drying
    final farmRecord = FarmToDryingModel(
      batchNumber: batchNumber,
      productName: 'فول سوداني',
      purchaseDate: DateTime.now().subtract(const Duration(days: 18)),
      purchaseLocation: 'كسلا',
      supplierName: 'محمد عثمان',
      sackCount: 75,
      productCost: 637500.0,
      logisticsCost: 20000.0,
      totalCosts: 657500.0,
      totalWeightBeforeDrying: 3750.0,
      notes: 'فول سوداني متوسط الجودة',
    );
    await _dataService.addFarmToDryingRecord(farmRecord);

    // 2. Products After Drying
    final productsAfterDrying = ProductsAfterDryingModel(
      batchNumber: batchNumber,
      totalGeneratedWeight: 3200.0,
      notes: 'نسبة فقدان 14.7%',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    );
    await _dataService.addProductsAfterDrying(productsAfterDrying);

    // 3. Finished Products
    final finishedProducts = FinishedProductsModel(
      batchNumber: batchNumber,
      emptyPackageId: 'dummy_package_2',
      quantity: 640, // 3200kg / 5kg packages = 640 packages
      notes: 'تعبئة في أكياس 5 كيلو - جاهز للبيع',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    );
    await _dataService.addFinishedProducts(finishedProducts);
  }

  /// Batch 5: Complete workflow - High-quality Sesame
  static Future<void> _addSesameBatch() async {
    const batchNumber = 'BATCH-005';

    // 1. Farm to Drying
    final farmRecord = FarmToDryingModel(
      batchNumber: batchNumber,
      productName: 'سمسم',
      purchaseDate: DateTime.now().subtract(const Duration(days: 35)),
      purchaseLocation: 'سنار',
      supplierName: 'عائشة أحمد',
      sackCount: 50,
      productCost: 650000.0,
      logisticsCost: 15000.0,
      totalCosts: 665000.0,
      totalWeightBeforeDrying: 2500.0,
      notes: 'سمسم ذهبي عالي الجودة',
    );
    await _dataService.addFarmToDryingRecord(farmRecord);

    // 2. Products After Drying
    final productsAfterDrying = ProductsAfterDryingModel(
      batchNumber: batchNumber,
      totalGeneratedWeight: 2300.0,
      notes: 'نسبة فقدان 8% فقط - جودة عالية',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
    );
    await _dataService.addProductsAfterDrying(productsAfterDrying);

    // 3. Finished Products
    final finishedProducts = FinishedProductsModel(
      batchNumber: batchNumber,
      emptyPackageId: 'dummy_package_3',
      quantity: 460, // 2300kg / 5kg packages = 460 packages
      notes: 'تعبئة فاخرة للسمسم الذهبي',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 24)),
    );
    await _dataService.addFinishedProducts(finishedProducts);

    // 4. Sales - Premium pricing
    final sale = SalesModel(
      saleDate: DateTime.now().subtract(const Duration(days: 18)),
      items: [
        SaleItem(
          productName: 'سمسم',
          quantityOfPackages: 400,
          pricePerPackage: 2500.0,
          packageType: 'B2B',
          totalPrice: 1000000.0,
        ),
      ],
      buyerType: 'Supermarket',
      buyerName: 'سبينيز مول',
      buyerLocation: 'الخرطوم',
      totalAmount: 1000000.0,
      collectedAmount: 800000.0,
      remainingAmount: 200000.0,
      paymentStatus: 'partial',
      notes: 'سمسم فاخر - سعر مميز، دفع 80%',
      createdBy: 'test_user',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
    );
    await _dataService.addSale(sale);
  }

  /// Clean up all dummy data
  static Future<void> clearDummyData() async {
    try {
      // This would require implementing delete methods for each collection
      // For now, just print a message
      print('⚠️ Clear dummy data functionality needs to be implemented');
    } catch (e) {
      print('❌ Error clearing dummy data: $e');
    }
  }
}
