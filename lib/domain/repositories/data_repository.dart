import 'package:inventory_sudan/models/user_model.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/models/sales_model.dart';
import 'package:inventory_sudan/models/stock_log_model.dart';

abstract class DataRepository {
  // Authentication methods
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();

  // Farm to Drying methods
  Future<List<FarmToDryingModel>> getFarmToDryingRecords();
  Future<FarmToDryingModel?> getFarmToDryingRecord(String id);
  Future<void> addFarmToDryingRecord(FarmToDryingModel record);
  Future<void> updateFarmToDryingRecord(String id, FarmToDryingModel record);
  Future<void> deleteFarmToDryingRecord(String id);
  Stream<List<FarmToDryingModel>> streamFarmToDryingRecords();

  // Packaging methods
  Future<List<PackagingModel>> getPackagingRecords();
  Future<PackagingModel?> getPackagingRecord(String id);
  Future<void> addPackagingRecord(PackagingModel record);
  Future<void> updatePackagingRecord(String id, PackagingModel record);
  Future<void> deletePackagingRecord(String id);
  Stream<List<PackagingModel>> streamPackagingRecords();

  // Sales methods
  Future<List<SalesModel>> getSalesRecords();
  Future<SalesModel?> getSalesRecord(String id);
  Future<void> addSalesRecord(SalesModel record);
  Future<void> updateSalesRecord(String id, SalesModel record);
  Future<void> deleteSalesRecord(String id);
  Stream<List<SalesModel>> streamSalesRecords();

  // Stock Log methods
  Future<List<StockLogModel>> getStockLogRecords();
  Future<StockLogModel?> getStockLogRecord(String id);
  Future<void> addStockLogRecord(StockLogModel record);
  Future<void> updateStockLogRecord(String id, StockLogModel record);
  Future<void> deleteStockLogRecord(String id);
  Stream<List<StockLogModel>> streamStockLogRecords();
}
