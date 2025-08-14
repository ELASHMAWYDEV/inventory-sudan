import 'package:get/get.dart';
import 'package:inventory_sudan/services/auth_service.dart';
import 'package:inventory_sudan/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_sudan/utils/constants/app_constants.dart';
import 'package:inventory_sudan/models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String _error = '';
  bool _isFirstLaunch = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isFirstLaunch => _isFirstLaunch;

  // Setters that trigger update
  set user(UserModel? value) {
    _user = value;
    update();
  }

  set isLoading(bool value) {
    _isLoading = value;
    update();
  }

  set error(String value) {
    _error = value;
    update();
  }

  set isFirstLaunch(bool value) {
    _isFirstLaunch = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    checkFirstLaunch();
    checkAuth();
  }

  Future<void> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstLaunch = !(prefs.getBool(AppConstants.keyIsFirstLaunch) ?? false);

    if (isFirstLaunch) {
      // Get.offAllNamed(AppRouter.ONBOARDING);
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsFirstLaunch, true);
    isFirstLaunch = false;
    Get.offAllNamed(AppRouter.LOGIN);
  }

  Future<void> checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    final currentUser = await _authService.getCurrentUser();

    if (isLoggedIn && currentUser != null) {
      user = currentUser;

      // If not first launch and logged in, navigate to home
      if (!isFirstLaunch) {
        Get.offAllNamed(AppRouter.HOME);
      }
    } else if (!isFirstLaunch) {
      Get.offAllNamed(AppRouter.LOGIN);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading = true;
      error = '';

      final userModel = await _authService.signInWithEmailAndPassword(email, password);

      if (userModel != null) {
        user = userModel;
        Get.offAllNamed(AppRouter.HOME);
      } else {
        error = 'Invalid email or password';
      }
    } catch (e) {
      error = 'An error occurred during sign in';
      print('Sign in error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading = true;
      await _authService.signOut();
      user = null;
      Get.offAllNamed(AppRouter.LOGIN);
    } catch (e) {
      error = 'An error occurred during sign out';
      print('Sign out error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> createUser(String email, String password, String name, String role) async {
    try {
      isLoading = true;
      error = '';

      final userModel = await _authService.createUser(email, password, name, role);

      if (userModel != null) {
        Get.back(); // Go back to previous screen
      } else {
        error = 'Failed to create user';
      }
    } catch (e) {
      error = 'An error occurred while creating user';
      print('Create user error: $e');
    } finally {
      isLoading = false;
    }
  }
}
