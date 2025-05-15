import 'dart:async';
import 'package:inventory_sudan/domain/repositories/data_repository.dart';
import 'package:inventory_sudan/models/user_model.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/models/sales_model.dart';
import 'package:inventory_sudan/models/stock_log_model.dart';

class DataService {
  final DataRepository _repository;

  // Stream controllers
  final _farmToDryingController = StreamController<List<FarmToDryingModel>>.broadcast();
  final _packagingController = StreamController<List<PackagingModel>>.broadcast();
  final _salesController = StreamController<List<SalesModel>>.broadcast();
  final _stockLogController = StreamController<List<StockLogModel>>.broadcast();

  // Collections
  static const String collectionFarmToDrying = 'farm_to_drying';
  static const String collectionPackaging = 'packaging';
  static const String collectionUsers = 'users';

  DataService(this._repository) {
    // Initialize streams
    _repository.streamFarmToDryingRecords().listen((data) {
      if (!_farmToDryingController.isClosed) {
        _farmToDryingController.add(data);
      }
    });

    _repository.streamPackagingRecords().listen((data) {
      if (!_packagingController.isClosed) {
        _packagingController.add(data);
      }
    });

    _repository.streamSalesRecords().listen((data) {
      if (!_salesController.isClosed) {
        _salesController.add(data);
      }
    });

    _repository.streamStockLogRecords().listen((data) {
      if (!_stockLogController.isClosed) {
        _stockLogController.add(data);
      }
    });
  }

  // Stream getters
  Stream<List<FarmToDryingModel>> get farmToDryingStream => _farmToDryingController.stream;
  Stream<List<PackagingModel>> get packagingStream => _packagingController.stream;
  Stream<List<SalesModel>> get salesStream => _salesController.stream;
  Stream<List<StockLogModel>> get stockLogStream => _stockLogController.stream;

  // Authentication methods
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) {
    return _repository.signInWithEmailAndPassword(email, password);
  }

  Future<void> signOut() {
    return _repository.signOut();
  }

  // Farm to Drying methods
  Future<List<FarmToDryingModel>> getFarmToDryingRecords() {
    return _repository.getFarmToDryingRecords();
  }

  Future<FarmToDryingModel?> getFarmToDryingRecord(String id) {
    return _repository.getFarmToDryingRecord(id);
  }

  Future<void> addFarmToDryingRecord(FarmToDryingModel record) {
    return _repository.addFarmToDryingRecord(record);
  }

  Future<void> updateFarmToDryingRecord(String id, FarmToDryingModel record) {
    return _repository.updateFarmToDryingRecord(id, record);
  }

  Future<void> deleteFarmToDryingRecord(String id) {
    return _repository.deleteFarmToDryingRecord(id);
  }

  // Packaging methods
  Future<List<PackagingModel>> getPackagingRecords() {
    return _repository.getPackagingRecords();
  }

  Future<PackagingModel?> getPackagingRecord(String id) {
    return _repository.getPackagingRecord(id);
  }

  Future<void> addPackagingRecord(PackagingModel record) {
    return _repository.addPackagingRecord(record);
  }

  Future<void> updatePackagingRecord(String id, PackagingModel record) {
    return _repository.updatePackagingRecord(id, record);
  }

  Future<void> deletePackagingRecord(String id) {
    return _repository.deletePackagingRecord(id);
  }

  // Sales methods
  Future<List<SalesModel>> getSalesRecords() {
    return _repository.getSalesRecords();
  }

  Future<SalesModel?> getSalesRecord(String id) {
    return _repository.getSalesRecord(id);
  }

  Future<void> addSalesRecord(SalesModel record) {
    return _repository.addSalesRecord(record);
  }

  Future<void> updateSalesRecord(String id, SalesModel record) {
    return _repository.updateSalesRecord(id, record);
  }

  Future<void> deleteSalesRecord(String id) {
    return _repository.deleteSalesRecord(id);
  }

  // Stock Log methods
  Future<List<StockLogModel>> getStockLogRecords() {
    return _repository.getStockLogRecords();
  }

  Future<StockLogModel?> getStockLogRecord(String id) {
    return _repository.getStockLogRecord(id);
  }

  Future<void> addStockLogRecord(StockLogModel record) {
    return _repository.addStockLogRecord(record);
  }

  Future<void> updateStockLogRecord(String id, StockLogModel record) {
    return _repository.updateStockLogRecord(id, record);
  }

  Future<void> deleteStockLogRecord(String id) {
    return _repository.deleteStockLogRecord(id);
  }

  // Cleanup
  void dispose() {
    _farmToDryingController.close();
    _packagingController.close();
    _salesController.close();
    _stockLogController.close();
  }
}
