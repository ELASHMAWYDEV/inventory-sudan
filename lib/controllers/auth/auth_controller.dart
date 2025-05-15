import 'package:get/get.dart';
import 'package:inventory_sudan/services/auth_service.dart';
import 'package:inventory_sudan/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_sudan/utils/constants/app_constants.dart';
import 'package:inventory_sudan/models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isFirstLaunch = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkFirstLaunch();
    checkAuth();
  }

  Future<void> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstLaunch.value = !(prefs.getBool(AppConstants.keyIsFirstLaunch) ?? false);

    if (isFirstLaunch.value) {
      // Get.offAllNamed(AppRouter.ONBOARDING);
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsFirstLaunch, true);
    isFirstLaunch.value = false;
    Get.offAllNamed(AppRouter.LOGIN);
  }

  Future<void> checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    final currentUser = await _authService.getCurrentUser();

    if (isLoggedIn && currentUser != null) {
      user.value = currentUser;

      // If not first launch and logged in, navigate to home
      if (!isFirstLaunch.value) {
        Get.offAllNamed(AppRouter.HOME);
      }
    } else if (!isFirstLaunch.value) {
      Get.offAllNamed(AppRouter.LOGIN);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final userModel = await _authService.signInWithEmailAndPassword(email, password);

      if (userModel != null) {
        user.value = userModel;
        Get.offAllNamed(AppRouter.HOME);
      } else {
        error.value = 'Invalid email or password';
      }
    } catch (e) {
      error.value = 'An error occurred during sign in';
      print('Sign in error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      user.value = null;
      Get.offAllNamed(AppRouter.LOGIN);
    } catch (e) {
      error.value = 'An error occurred during sign out';
      print('Sign out error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(String email, String password, String name, String role) async {
    try {
      isLoading.value = true;
      error.value = '';

      final userModel = await _authService.createUser(email, password, name, role);

      if (userModel != null) {
        Get.back(); // Go back to previous screen
      } else {
        error.value = 'Failed to create user';
      }
    } catch (e) {
      error.value = 'An error occurred while creating user';
      print('Create user error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
