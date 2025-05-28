import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_sudan/models/user_model.dart';

class SetupService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize test users for the application
  Future<void> initializeTestUsers() async {
    try {
      // Check if users already exist
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      if (usersSnapshot.docs.isNotEmpty) {
        print('Users already exist, skipping initialization');
        return;
      }

      print('Initializing test users...');

      // Create admin user
      await _createTestUser(
        email: 'admin@inventory.sudan',
        password: 'admin123',
        name: 'مدير النظام',
        role: 'admin',
      );

      // Create worker user
      await _createTestUser(
        email: 'worker@inventory.sudan',
        password: 'worker123',
        name: 'عامل المخزون',
        role: 'worker',
      );

      print('Test users initialized successfully');
    } catch (e) {
      print('Error initializing test users: $e');
    }
  }

  Future<void> _createTestUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        final user = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          role: role,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set({
          'name': user.name,
          'email': user.email,
          'role': user.role,
          'created_at': user.createdAt,
          'last_login': user.lastLogin,
        });

        print('Created test user: $email ($role)');
      }
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('User $email already exists');
      } else {
        print('Error creating user $email: $e');
      }
    }
  }

  /// Get test user credentials for development
  Map<String, Map<String, String>> getTestCredentials() {
    return {
      'admin': {
        'email': 'admin@inventory.sudan',
        'password': 'admin123',
        'name': 'مدير النظام',
        'role': 'admin',
      },
      'worker': {
        'email': 'worker@inventory.sudan',
        'password': 'worker123',
        'name': 'عامل المخزون',
        'role': 'worker',
      },
    };
  }
}
