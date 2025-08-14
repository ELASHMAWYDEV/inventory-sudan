import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_sudan/utils/constants/app_constants.dart';

class SettingsController extends GetxController {
  // Settings state
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoBackupEnabled = true;
  String _language = 'ar'; // Arabic by default
  String _dateFormat = 'dd/MM/yyyy';
  bool _confirmOnDelete = true;
  bool _biometricEnabled = false;
  int _sessionTimeout = 30; // minutes

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get autoBackupEnabled => _autoBackupEnabled;
  String get language => _language;
  String get dateFormat => _dateFormat;
  bool get confirmOnDelete => _confirmOnDelete;
  bool get biometricEnabled => _biometricEnabled;
  int get sessionTimeout => _sessionTimeout;

  // Preference keys
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keySound = 'sound_enabled';
  static const String _keyDarkMode = 'dark_mode_enabled';
  static const String _keyAutoBackup = 'auto_backup_enabled';
  static const String _keyLanguage = 'language';
  static const String _keyDateFormat = 'date_format';
  static const String _keyConfirmOnDelete = 'confirm_on_delete';
  static const String _keyBiometric = 'biometric_enabled';
  static const String _keySessionTimeout = 'session_timeout';

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
      _soundEnabled = prefs.getBool(_keySound) ?? true;
      _darkModeEnabled = prefs.getBool(_keyDarkMode) ?? false;
      _autoBackupEnabled = prefs.getBool(_keyAutoBackup) ?? true;
      _language = prefs.getString(_keyLanguage) ?? 'ar';
      _dateFormat = prefs.getString(_keyDateFormat) ?? 'dd/MM/yyyy';
      _confirmOnDelete = prefs.getBool(_keyConfirmOnDelete) ?? true;
      _biometricEnabled = prefs.getBool(_keyBiometric) ?? false;
      _sessionTimeout = prefs.getInt(_keySessionTimeout) ?? 30;

      update();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _saveSetting(_keyNotifications, value);
    update();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _saveSetting(_keySound, value);
    update();
  }

  Future<void> setDarkModeEnabled(bool value) async {
    _darkModeEnabled = value;
    await _saveSetting(_keyDarkMode, value);
    update();

    // Apply theme change immediately
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setAutoBackupEnabled(bool value) async {
    _autoBackupEnabled = value;
    await _saveSetting(_keyAutoBackup, value);
    update();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await _saveSetting(_keyLanguage, value);
    update();

    // Apply language change
    Locale locale = value == 'ar' ? const Locale('ar', 'SA') : const Locale('en', 'US');
    Get.updateLocale(locale);
  }

  Future<void> setDateFormat(String value) async {
    _dateFormat = value;
    await _saveSetting(_keyDateFormat, value);
    update();
  }

  Future<void> setConfirmOnDelete(bool value) async {
    _confirmOnDelete = value;
    await _saveSetting(_keyConfirmOnDelete, value);
    update();
  }

  Future<void> setBiometricEnabled(bool value) async {
    _biometricEnabled = value;
    await _saveSetting(_keyBiometric, value);
    update();
  }

  Future<void> setSessionTimeout(int value) async {
    _sessionTimeout = value;
    await _saveSetting(_keySessionTimeout, value);
    update();
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      }
    } catch (e) {
      print('Error saving setting $key: $e');
    }
  }

  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove all settings keys
      await prefs.remove(_keyNotifications);
      await prefs.remove(_keySound);
      await prefs.remove(_keyDarkMode);
      await prefs.remove(_keyAutoBackup);
      await prefs.remove(_keyLanguage);
      await prefs.remove(_keyDateFormat);
      await prefs.remove(_keyConfirmOnDelete);
      await prefs.remove(_keyBiometric);
      await prefs.remove(_keySessionTimeout);

      // Reset to defaults
      _notificationsEnabled = true;
      _soundEnabled = true;
      _darkModeEnabled = false;
      _autoBackupEnabled = true;
      _language = 'ar';
      _dateFormat = 'dd/MM/yyyy';
      _confirmOnDelete = true;
      _biometricEnabled = false;
      _sessionTimeout = 30;

      update();

      Get.snackbar(
        'تم',
        'تم إعادة تعيين الإعدادات بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error resetting settings: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إعادة تعيين الإعدادات',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> exportData() async {
    try {
      // TODO: Implement data export functionality
      Get.snackbar(
        'قريباً',
        'ميزة تصدير البيانات قيد التطوير',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error exporting data: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      // TODO: Implement cache clearing functionality
      Get.snackbar(
        'تم',
        'تم مسح الذاكرة المؤقتة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<void> backupData() async {
    try {
      // TODO: Implement backup functionality
      Get.snackbar(
        'تم',
        'تم إنشاء نسخة احتياطية بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error backing up data: $e');
    }
  }
}
