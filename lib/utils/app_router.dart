// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:inventory_sudan/ui/screens/auth/login_screen.dart';
import 'package:inventory_sudan/ui/screens/error/not_found_screen.dart';
import 'package:inventory_sudan/ui/screens/farm_to_drying/farm_to_drying_form_screen.dart';
import 'package:inventory_sudan/ui/screens/farm_to_drying/farm_to_drying_screen.dart';
import 'package:inventory_sudan/ui/screens/farm_to_drying/farm_to_drying_details_screen.dart';
import 'package:inventory_sudan/ui/screens/home/home_screen.dart';
import 'package:inventory_sudan/ui/screens/onboarding/onboarding_screen.dart';
import 'package:inventory_sudan/ui/screens/packaging/packaging_screen.dart';
import 'package:inventory_sudan/ui/screens/packaging/products_after_drying_form_screen.dart';
import 'package:inventory_sudan/ui/screens/packaging/empty_packages_inventory_form_screen.dart';
import 'package:inventory_sudan/ui/screens/packaging/finished_products_form_screen.dart';
import 'package:inventory_sudan/ui/screens/sales/sales_screen.dart';
import 'package:inventory_sudan/ui/screens/sales/sales_form_screen.dart';
import 'package:inventory_sudan/ui/screens/sales/sales_details_screen.dart';
import 'package:inventory_sudan/ui/screens/stock_log/stock_log_screen.dart';
import 'package:inventory_sudan/ui/screens/stock_log/stock_log_form_screen.dart';
import 'package:inventory_sudan/ui/screens/stock_log/stock_log_details_screen.dart';
import 'package:inventory_sudan/ui/screens/users/users_management_screen.dart';
import 'package:inventory_sudan/ui/screens/settings/settings_screen.dart';
import 'package:inventory_sudan/ui/screens/statistics/statistics_screen.dart';

class AppRouter {
  // Auth routes
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String FORGOT_PASSWORD = '/forgot-password';

  // Onboarding routes
  static const String ONBOARDING = '/onboarding';

  // Home routes
  static const String HOME = '/home';

  // Farm to drying routes
  static const String FARM_TO_DRYING = '/farm-to-drying';
  static const String FARM_TO_DRYING_FORM = '/farm-to-drying/form';
  static const String FARM_TO_DRYING_DETAILS = '/farm-to-drying/details';

  // Packaging routes
  static const String PACKAGING = '/packaging';
  static const String PACKAGING_PRODUCTS_AFTER_DRYING_FORM = '/packaging/products-after-drying-form';
  static const String PACKAGING_EMPTY_PACKAGES_INVENTORY_FORM = '/packaging/empty-packages-inventory-form';
  static const String PACKAGING_FINISHED_PRODUCTS_FORM = '/packaging/finished-products-form';

  // Sales routes
  static const String SALES = '/sales';
  static const String SALES_FORM = '/sales/form';
  static const String SALES_DETAILS = '/sales/details';

  // Stock log routes
  static const String STOCK_LOG = '/stock-log';
  static const String STOCK_LOG_FORM = '/stock-log/form';
  static const String STOCK_LOG_DETAILS = '/stock-log/details';

  // Users routes
  static const String USERS_MANAGEMENT = '/users-management';

  // Settings routes
  static const String SETTINGS = '/settings';
  static const String PROFILE = '/profile';

  // Statistics routes
  static const String STATISTICS = '/statistics';

  // Error routes
  static const String ERROR = '/error';
  static const String NOT_FOUND = '/not-found';

  static final routes = [
    GetPage(
      name: HOME,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: LOGIN,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: ONBOARDING,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: FARM_TO_DRYING,
      page: () => const FarmToDryingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: FARM_TO_DRYING_FORM,
      page: () => const FarmToDryingFormScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: FARM_TO_DRYING_DETAILS,
      page: () => const FarmToDryingDetailsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PACKAGING,
      page: () => const PackagingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PACKAGING_PRODUCTS_AFTER_DRYING_FORM,
      page: () => const ProductsAfterDryingFormScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PACKAGING_EMPTY_PACKAGES_INVENTORY_FORM,
      page: () => const EmptyPackagesInventoryFormScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PACKAGING_FINISHED_PRODUCTS_FORM,
      page: () => const FinishedProductsFormScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: SALES,
      page: () => const SalesScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: SALES_FORM,
      page: () => const SalesFormScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: SALES_DETAILS,
      page: () => const SalesDetailsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: STOCK_LOG,
      page: () => const StockLogScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: STOCK_LOG_FORM,
      page: () => const StockLogFormScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: STOCK_LOG_DETAILS,
      page: () => const StockLogDetailsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: USERS_MANAGEMENT,
      page: () => const UsersManagementScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: SETTINGS,
      page: () => const SettingsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: STATISTICS,
      page: () => const StatisticsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: NOT_FOUND,
      page: () => const NotFoundScreen(),
      transition: Transition.fadeIn,
    ),
  ];

  static void configureRoutes() {
    Get.config(
      defaultTransition: Transition.fadeIn,
    );
  }
}
