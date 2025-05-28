import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_sudan/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_sudan/utils/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final user = UserModel(
            id: userCredential.user!.uid,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            role: userData['role'] ?? 'worker',
            createdAt: userData['created_at']?.toDate() ?? DateTime.now(),
            lastLogin: DateTime.now(),
          );

          await _saveUserSession(user);
          return user;
        }
      }
      return null;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      return UserModel(
        id: currentUser.uid,
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        role: userData['role'] ?? 'worker',
        createdAt: userData['created_at']?.toDate() ?? DateTime.now(),
        lastLogin: userData['last_login']?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // Create new user (for admin to create worker accounts)
  Future<UserModel?> createUser(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          role: role,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set(user.toMap());
        return user;
      }
      return null;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyUserLoggedIn, true);
    await prefs.setString(AppConstants.keyUserId, user.id);
    await prefs.setString(AppConstants.keyUserName, user.name);
    await prefs.setString(AppConstants.keyUserRole, user.role);
  }
}
