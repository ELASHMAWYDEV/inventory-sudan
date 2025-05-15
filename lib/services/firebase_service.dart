import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inventory_sudan/firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;

      // Set Firestore settings for offline persistence if needed
      await _firestore?.settings.copyWith(persistenceEnabled: true);

      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  // Auth getters
  FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase Auth has not been initialized');
    }
    return _auth!;
  }

  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase Firestore has not been initialized');
    }
    return _firestore!;
  }

  FirebaseStorage get storage {
    if (_storage == null) {
      throw Exception('Firebase Storage has not been initialized');
    }
    return _storage!;
  }
}
