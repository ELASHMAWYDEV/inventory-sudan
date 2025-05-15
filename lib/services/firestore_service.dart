import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_sudan/services/firebase_service.dart';

class FirestoreService {
  final FirebaseService _firebase = FirebaseService();

  // Collection names
  static const String collectionUsers = 'users';
  static const String collectionFarmToDrying = 'farm_to_drying';
  static const String collectionPackaging = 'packaging';
  static const String collectionSales = 'sales';
  static const String collectionStockLog = 'stock_log';

  // Generic method to get a collection reference
  CollectionReference _getCollection(String collectionName) {
    return _firebase.firestore.collection(collectionName);
  }

  // Generic CRUD Operations

  // Create document
  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      // Add timestamp
      data['created_at'] = FieldValue.serverTimestamp();

      return await _getCollection(collection).add(data);
    } catch (e) {
      print('Error adding document: $e');
      rethrow;
    }
  }

  // Create document with specific ID
  Future<void> setDocument(String collection, String documentId, Map<String, dynamic> data, {bool merge = true}) async {
    try {
      // Add timestamp if not merging or if it doesn't exist
      if (!merge || !data.containsKey('created_at')) {
        data['created_at'] = FieldValue.serverTimestamp();
      }

      // Always update the 'updated_at' field
      data['updated_at'] = FieldValue.serverTimestamp();

      await _getCollection(collection).doc(documentId).set(data, SetOptions(merge: merge));
    } catch (e) {
      print('Error setting document: $e');
      rethrow;
    }
  }

  // Read document
  Future<DocumentSnapshot> getDocument(String collection, String documentId) async {
    try {
      return await _getCollection(collection).doc(documentId).get();
    } catch (e) {
      print('Error getting document: $e');
      rethrow;
    }
  }

  // Read collection (with optional queries)
  Future<QuerySnapshot> getDocuments(
    String collection, {
    List<List<dynamic>>? whereConditions,
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _getCollection(collection);

      // Apply where conditions if provided
      if (whereConditions != null) {
        for (var condition in whereConditions) {
          if (condition.length >= 3) {
            query = query.where(
              condition[0] as String,
              isEqualTo: condition[1] == '==' ? condition[2] : null,
              isNotEqualTo: condition[1] == '!=' ? condition[2] : null,
              isLessThan: condition[1] == '<' ? condition[2] : null,
              isLessThanOrEqualTo: condition[1] == '<=' ? condition[2] : null,
              isGreaterThan: condition[1] == '>' ? condition[2] : null,
              isGreaterThanOrEqualTo: condition[1] == '>=' ? condition[2] : null,
              arrayContains: condition[1] == 'array-contains' ? condition[2] : null,
            );
          }
        }
      }

      // Apply ordering if provided
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply pagination if provided
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      print('Error getting documents: $e');
      rethrow;
    }
  }

  // Update document
  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) async {
    try {
      // Add updated timestamp
      data['updated_at'] = FieldValue.serverTimestamp();

      await _getCollection(collection).doc(documentId).update(data);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  // Delete document
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _getCollection(collection).doc(documentId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  // Get real-time updates for a document
  Stream<DocumentSnapshot> documentStream(String collection, String documentId) {
    return _getCollection(collection).doc(documentId).snapshots();
  }

  // Get real-time updates for a collection
  Stream<QuerySnapshot> collectionStream(
    String collection, {
    List<List<dynamic>>? whereConditions,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _getCollection(collection);

    // Apply where conditions if provided
    if (whereConditions != null) {
      for (var condition in whereConditions) {
        if (condition.length >= 3) {
          query = query.where(
            condition[0] as String,
            isEqualTo: condition[1] == '==' ? condition[2] : null,
            isNotEqualTo: condition[1] == '!=' ? condition[2] : null,
            isLessThan: condition[1] == '<' ? condition[2] : null,
            isLessThanOrEqualTo: condition[1] == '<=' ? condition[2] : null,
            isGreaterThan: condition[1] == '>' ? condition[2] : null,
            isGreaterThanOrEqualTo: condition[1] == '>=' ? condition[2] : null,
            arrayContains: condition[1] == 'array-contains' ? condition[2] : null,
          );
        }
      }
    }

    // Apply ordering if provided
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply limit if provided
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  // Firebase Storage Methods

  // Upload file to storage
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _firebase.storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  // Delete file from storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = _firebase.storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  // Generate a unique filename for storage
  String generateUniqueFileName(String userId, String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalFileName.split('.').last;
    return '$userId-$timestamp.$extension';
  }
}
