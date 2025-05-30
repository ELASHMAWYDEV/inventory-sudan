import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_sudan/domain/repositories/data_repository.dart';
import 'package:inventory_sudan/models/user_model.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/models/sales_model.dart';
import 'package:inventory_sudan/models/stock_log_model.dart';

class FirebaseRepositoryImpl implements DataRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Collection names
  static const String _usersCollection = 'users';
  static const String _farmToDryingCollection = 'farm_to_drying';
  static const String _packagingCollection = 'packaging';
  static const String _salesCollection = 'sales';
  static const String _stockLogCollection = 'stock_log';
  static const String _productsAfterDryingCollection = 'products_after_drying';
  static const String _emptyPackagesInventoryCollection = 'empty_packages_inventory';
  static const String _finishedProductsCollection = 'finished_products';

  FirebaseRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Authentication methods
  @override
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userDoc = await _firestore.collection(_usersCollection).doc(userCredential.user!.uid).get();

        if (userDoc.exists) {
          return UserModel.fromMap({
            ...userDoc.data()!,
            'id': userCredential.user!.uid,
          });
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Farm to Drying methods
  @override
  Future<List<FarmToDryingModel>> getFarmToDryingRecords() async {
    try {
      final snapshot = await _firestore.collection(_farmToDryingCollection).get();
      return snapshot.docs.map((doc) => FarmToDryingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get farm to drying records: $e');
    }
  }

  @override
  Future<FarmToDryingModel?> getFarmToDryingRecord(String id) async {
    try {
      final doc = await _firestore.collection(_farmToDryingCollection).doc(id).get();
      return doc.exists ? FarmToDryingModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get farm to drying record: $e');
    }
  }

  @override
  Future<void> addFarmToDryingRecord(FarmToDryingModel record) async {
    try {
      await _firestore.collection(_farmToDryingCollection).add(record.toMap());
    } catch (e) {
      throw Exception('Failed to add farm to drying record: $e');
    }
  }

  @override
  Future<void> updateFarmToDryingRecord(String id, FarmToDryingModel record) async {
    try {
      await _firestore.collection(_farmToDryingCollection).doc(id).update(record.toMap());
    } catch (e) {
      throw Exception('Failed to update farm to drying record: $e');
    }
  }

  @override
  Future<void> deleteFarmToDryingRecord(String id) async {
    try {
      await _firestore.collection(_farmToDryingCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete farm to drying record: $e');
    }
  }

  @override
  Stream<List<FarmToDryingModel>> streamFarmToDryingRecords() {
    return _firestore
        .collection(_farmToDryingCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FarmToDryingModel.fromFirestore(doc)).toList());
  }

  // Packaging methods
  @override
  Future<List<PackagingModel>> getPackagingRecords() async {
    try {
      final snapshot = await _firestore.collection(_packagingCollection).get();
      return snapshot.docs.map((doc) => PackagingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get packaging records: $e');
    }
  }

  @override
  Future<PackagingModel?> getPackagingRecord(String id) async {
    try {
      final doc = await _firestore.collection(_packagingCollection).doc(id).get();
      return doc.exists ? PackagingModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get packaging record: $e');
    }
  }

  @override
  Future<void> addPackagingRecord(PackagingModel record) async {
    try {
      await _firestore.collection(_packagingCollection).add(record.toMap());
    } catch (e) {
      throw Exception('Failed to add packaging record: $e');
    }
  }

  @override
  Future<void> updatePackagingRecord(String id, PackagingModel record) async {
    try {
      await _firestore.collection(_packagingCollection).doc(id).update(record.toMap());
    } catch (e) {
      throw Exception('Failed to update packaging record: $e');
    }
  }

  @override
  Future<void> deletePackagingRecord(String id) async {
    try {
      await _firestore.collection(_packagingCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete packaging record: $e');
    }
  }

  @override
  Stream<List<PackagingModel>> streamPackagingRecords() {
    return _firestore
        .collection(_packagingCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PackagingModel.fromFirestore(doc)).toList());
  }

  // Individual Packaging Form Methods
  @override
  Future<void> addProductsAfterDrying(ProductsAfterDryingModel record) async {
    try {
      await _firestore.collection(_productsAfterDryingCollection).add(record.toMap());
    } catch (e) {
      throw Exception('Failed to add products after drying record: $e');
    }
  }

  @override
  Future<void> addEmptyPackagesInventory(EmptyPackagesInventoryModel record) async {
    try {
      await _firestore.collection(_emptyPackagesInventoryCollection).add(record.toMap());
    } catch (e) {
      throw Exception('Failed to add empty packages inventory record: $e');
    }
  }

  @override
  Future<void> addFinishedProducts(FinishedProductsModel record) async {
    try {
      await _firestore.collection(_finishedProductsCollection).add(record.toMap());
    } catch (e) {
      throw Exception('Failed to add finished products record: $e');
    }
  }

  @override
  Future<List<EmptyPackagesInventoryModel>> getEmptyPackagesInventory() async {
    try {
      final snapshot = await _firestore.collection(_emptyPackagesInventoryCollection).get();
      return snapshot.docs.map((doc) => EmptyPackagesInventoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get empty packages inventory: $e');
    }
  }

  @override
  Future<List<ProductsAfterDryingModel>> getProductsAfterDrying() async {
    try {
      final snapshot = await _firestore.collection(_productsAfterDryingCollection).get();
      return snapshot.docs.map((doc) => ProductsAfterDryingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get products after drying: $e');
    }
  }

  @override
  Future<List<FinishedProductsModel>> getFinishedProducts() async {
    try {
      final snapshot = await _firestore.collection(_finishedProductsCollection).get();
      return snapshot.docs.map((doc) => FinishedProductsModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get finished products: $e');
    }
  }

  @override
  Future<void> deductEmptyPackagesStock(String batchNumber, int quantity) async {
    try {
      // This is a simplified implementation - in a real scenario, you'd need to:
      // 1. Find the corresponding product for the batch number
      // 2. Find the empty packages inventory for that product
      // 3. Deduct the quantity from the stock
      // For now, we'll just log this action

      final inventoryItem = InventoryItem(
        itemName: 'Product for batch: $batchNumber',
        itemType: 'empty_package',
        expectedQuantity: 0.0,
        actualQuantity: -quantity.toDouble(),
        unit: 'count',
        difference: -quantity.toDouble(),
        reason: 'Finished products packaging',
      );

      final stockLogRecord = StockLogModel(
        logDate: DateTime.now(),
        inventoryItems: [inventoryItem],
        hasDiscrepancies: true,
        notes: 'Automatic deduction for finished products packaging',
        createdBy: 'system',
        createdAt: DateTime.now(),
      );

      await addStockLogRecord(stockLogRecord);
    } catch (e) {
      throw Exception('Failed to deduct empty packages stock: $e');
    }
  }

  // Sales methods
  @override
  Future<List<SalesModel>> getSalesRecords() async {
    try {
      final snapshot = await _firestore.collection(_salesCollection).get();
      return snapshot.docs.map((doc) => SalesModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get sales records: $e');
    }
  }

  @override
  Future<SalesModel?> getSalesRecord(String id) async {
    try {
      final doc = await _firestore.collection(_salesCollection).doc(id).get();
      return doc.exists ? SalesModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get sales record: $e');
    }
  }

  @override
  Future<void> addSalesRecord(SalesModel record) async {
    try {
      await _firestore.collection(_salesCollection).add(record.toMap());
    } catch (e) {
      throw Exception('Failed to add sales record: $e');
    }
  }

  @override
  Future<void> updateSalesRecord(String id, SalesModel record) async {
    try {
      await _firestore.collection(_salesCollection).doc(id).update(record.toMap());
    } catch (e) {
      throw Exception('Failed to update sales record: $e');
    }
  }

  @override
  Future<void> deleteSalesRecord(String id) async {
    try {
      await _firestore.collection(_salesCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete sales record: $e');
    }
  }

  @override
  Stream<List<SalesModel>> streamSalesRecords() {
    return _firestore
        .collection(_salesCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SalesModel.fromFirestore(doc)).toList());
  }

  // Stock Log methods
  @override
  Future<List<StockLogModel>> getStockLogRecords() async {
    try {
      final snapshot = await _firestore.collection(_stockLogCollection).get();
      return snapshot.docs.map((doc) => StockLogModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get stock log records: $e');
    }
  }

  @override
  Future<StockLogModel?> getStockLogRecord(String id) async {
    try {
      final doc = await _firestore.collection(_stockLogCollection).doc(id).get();
      return doc.exists ? StockLogModel.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get stock log record: $e');
    }
  }

  @override
  Future<void> addStockLogRecord(StockLogModel record) async {
    try {
      await _firestore.collection(_stockLogCollection).add(record.toMap());
    } catch (e) {
      throw Exception('Failed to add stock log record: $e');
    }
  }

  @override
  Future<void> updateStockLogRecord(String id, StockLogModel record) async {
    try {
      await _firestore.collection(_stockLogCollection).doc(id).update(record.toMap());
    } catch (e) {
      throw Exception('Failed to update stock log record: $e');
    }
  }

  @override
  Future<void> deleteStockLogRecord(String id) async {
    try {
      await _firestore.collection(_stockLogCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete stock log record: $e');
    }
  }

  @override
  Stream<List<StockLogModel>> streamStockLogRecords() {
    return _firestore
        .collection(_stockLogCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => StockLogModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<ProductsAfterDryingModel>> streamProductsAfterDrying() {
    return _firestore
        .collection(_productsAfterDryingCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductsAfterDryingModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<EmptyPackagesInventoryModel>> streamEmptyPackagesInventory() {
    return _firestore
        .collection(_emptyPackagesInventoryCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EmptyPackagesInventoryModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<FinishedProductsModel>> streamFinishedProducts() {
    return _firestore
        .collection(_finishedProductsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FinishedProductsModel.fromFirestore(doc)).toList());
  }
}
