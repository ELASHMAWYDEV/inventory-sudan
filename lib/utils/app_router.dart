// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/ui/screens/auth/login_screen.dart';
import 'package:inventory_sudan/ui/screens/error/not_found_screen.dart';
import 'package:inventory_sudan/ui/screens/farm_to_drying/farm_to_drying_form_screen.dart';
import 'package:inventory_sudan/ui/screens/farm_to_drying/farm_to_drying_screen.dart';
import 'package:inventory_sudan/ui/screens/home/home_screen.dart';
import 'package:inventory_sudan/ui/screens/onboarding/onboarding_screen.dart';
import 'package:inventory_sudan/ui/screens/packaging/packaging_form_screen.dart';
import 'package:inventory_sudan/ui/screens/packaging/packaging_screen.dart';

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
  static const String PACKAGING_FORM = '/packaging/form';
  static const String PACKAGING_DETAILS = '/packaging/details';

  // Sales routes
  static const String SALES = '/sales';
  static const String SALES_FORM = '/sales/form';
  static const String SALES_DETAILS = '/sales/details';

  // Stock log routes
  static const String STOCK_LOG = '/stock-log';
  static const String STOCK_LOG_FORM = '/stock-log/form';
  static const String STOCK_LOG_DETAILS = '/stock-log/details';

  // Settings routes
  static const String SETTINGS = '/settings';
  static const String PROFILE = '/profile';

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
      name: PACKAGING,
      page: () => const PackagingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PACKAGING_FORM,
      page: () => const PackagingFormScreen(),
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
