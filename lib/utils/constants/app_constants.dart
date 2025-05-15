class AppConstants {
  // App info
  static const String appName = 'Inventory Sudan';
  static const String appVersion = '1.0.0';
  
  // Shared preferences keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyUserLoggedIn = 'user_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  
  // Process types
  static const int processFarmToDrying = 1;
  static const int processPackaging = 2;
  static const int processSales = 3;
  
  // Default values
  static const double defaultPadding = 16.0;
  static const double borderRadius = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Database
  static const String dbName = 'inventory_sudan.db';
  static const int dbVersion = 1;
  
  // Tables
  static const String tableUsers = 'users';
  static const String tableFarmToDrying = 'farm_to_drying';
  static const String tablePackaging = 'packaging';
  static const String tableSales = 'sales';
  static const String tableStockLog = 'stock_log';
  
  // API endpoints (for future use)
  static const String baseUrl = '';
}
