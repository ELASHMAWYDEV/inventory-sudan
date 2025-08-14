import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/controllers/auth/auth_controller.dart';
import 'package:inventory_sudan/controllers/settings/settings_controller.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/utils/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (settingsController) {
        return GetBuilder<AuthController>(
          builder: (authController) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text(
                  'الإعدادات',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                elevation: 0,
                backgroundColor: AppColors.primary,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Section
                    _buildSectionHeader('الملف الشخصي'),
                    _buildProfileCard(authController),

                    const SizedBox(height: 24),

                    // App Preferences
                    _buildSectionHeader('تفضيلات التطبيق'),
                    _buildPreferencesSection(settingsController),

                    const SizedBox(height: 24),

                    // Notifications
                    _buildSectionHeader('الإشعارات'),
                    _buildNotificationsSection(settingsController),

                    const SizedBox(height: 24),

                    // Security
                    _buildSectionHeader('الأمان'),
                    _buildSecuritySection(settingsController),

                    const SizedBox(height: 24),

                    // Data Management
                    _buildSectionHeader('إدارة البيانات'),
                    _buildDataManagementSection(settingsController),

                    const SizedBox(height: 24),

                    // About
                    _buildSectionHeader('حول التطبيق'),
                    _buildAboutSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildProfileCard(AuthController authController) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authController.user?.name ?? 'مستخدم',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authController.user?.email ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authController.user?.role ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(SettingsController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'الوضع المظلم',
            subtitle: 'تبديل بين الوضع الفاتح والمظلم',
            value: controller.darkModeEnabled,
            onChanged: controller.setDarkModeEnabled,
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.language,
            title: 'اللغة',
            subtitle: controller.language == 'ar' ? 'العربية' : 'English',
            onTap: () => _showLanguageDialog(controller),
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.date_range,
            title: 'تنسيق التاريخ',
            subtitle: controller.dateFormat,
            onTap: () => _showDateFormatDialog(controller),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.warning,
            title: 'تأكيد الحذف',
            subtitle: 'إظهار تأكيد قبل حذف العناصر',
            value: controller.confirmOnDelete,
            onChanged: controller.setConfirmOnDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(SettingsController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'الإشعارات',
            subtitle: 'تفعيل أو إلغاء الإشعارات',
            value: controller.notificationsEnabled,
            onChanged: controller.setNotificationsEnabled,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: 'الأصوات',
            subtitle: 'تفعيل أو إلغاء أصوات الإشعارات',
            value: controller.soundEnabled,
            onChanged: controller.setSoundEnabled,
            enabled: controller.notificationsEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(SettingsController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: 'البيومترية',
            subtitle: 'استخدام بصمة الإصبع أو الوجه',
            value: controller.biometricEnabled,
            onChanged: controller.setBiometricEnabled,
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.timer,
            title: 'انتهاء الجلسة',
            subtitle: '${controller.sessionTimeout} دقيقة',
            onTap: () => _showSessionTimeoutDialog(controller),
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.lock,
            title: 'تغيير كلمة المرور',
            subtitle: 'تحديث كلمة المرور',
            onTap: () => _showChangePasswordDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection(SettingsController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.backup,
            title: 'النسخ الاحتياطي التلقائي',
            subtitle: 'إنشاء نسخة احتياطية تلقائياً',
            value: controller.autoBackupEnabled,
            onChanged: controller.setAutoBackupEnabled,
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.cloud_upload,
            title: 'إنشاء نسخة احتياطية',
            subtitle: 'حفظ البيانات في السحابة',
            onTap: controller.backupData,
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.file_download,
            title: 'تصدير البيانات',
            subtitle: 'تصدير البيانات إلى ملف',
            onTap: controller.exportData,
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.cleaning_services,
            title: 'مسح الذاكرة المؤقتة',
            subtitle: 'حذف الملفات المؤقتة',
            onTap: () => _showClearCacheDialog(controller),
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.restore,
            title: 'إعادة تعيين الإعدادات',
            subtitle: 'العودة للإعدادات الافتراضية',
            onTap: () => _showResetSettingsDialog(controller),
            textColor: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTile(
            icon: Icons.info,
            title: 'إصدار التطبيق',
            subtitle: AppConstants.appVersion,
            onTap: () {},
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.description,
            title: 'الشروط والأحكام',
            subtitle: 'قراءة الشروط والأحكام',
            onTap: () => _showTermsDialog(),
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.privacy_tip,
            title: 'سياسة الخصوصية',
            subtitle: 'قراءة سياسة الخصوصية',
            onTap: () => _showPrivacyDialog(),
          ),
          _buildDivider(),
          _buildTile(
            icon: Icons.contact_support,
            title: 'الدعم الفني',
            subtitle: 'التواصل مع فريق الدعم',
            onTap: () => _showSupportDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: AppColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: textColor ?? AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
    );
  }

  void _showLanguageDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('اختيار اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: controller.language,
              onChanged: (value) {
                if (value != null) {
                  controller.setLanguage(value);
                  Get.back();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: controller.language,
              onChanged: (value) {
                if (value != null) {
                  controller.setLanguage(value);
                  Get.back();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showDateFormatDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('تنسيق التاريخ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('dd/MM/yyyy'),
              value: 'dd/MM/yyyy',
              groupValue: controller.dateFormat,
              onChanged: (value) {
                if (value != null) {
                  controller.setDateFormat(value);
                  Get.back();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('MM/dd/yyyy'),
              value: 'MM/dd/yyyy',
              groupValue: controller.dateFormat,
              onChanged: (value) {
                if (value != null) {
                  controller.setDateFormat(value);
                  Get.back();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('yyyy/MM/dd'),
              value: 'yyyy/MM/dd',
              groupValue: controller.dateFormat,
              onChanged: (value) {
                if (value != null) {
                  controller.setDateFormat(value);
                  Get.back();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showSessionTimeoutDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('انتهاء الجلسة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('15 دقيقة'),
              value: 15,
              groupValue: controller.sessionTimeout,
              onChanged: (value) {
                if (value != null) {
                  controller.setSessionTimeout(value);
                  Get.back();
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('30 دقيقة'),
              value: 30,
              groupValue: controller.sessionTimeout,
              onChanged: (value) {
                if (value != null) {
                  controller.setSessionTimeout(value);
                  Get.back();
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('60 دقيقة'),
              value: 60,
              groupValue: controller.sessionTimeout,
              onChanged: (value) {
                if (value != null) {
                  controller.setSessionTimeout(value);
                  Get.back();
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('عدم انتهاء'),
              value: 0,
              groupValue: controller.sessionTimeout,
              onChanged: (value) {
                if (value != null) {
                  controller.setSessionTimeout(value);
                  Get.back();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: const Text('ميزة تغيير كلمة المرور قيد التطوير'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('مسح الذاكرة المؤقتة'),
        content: const Text('هل أنت متأكد من رغبتك في مسح الذاكرة المؤقتة؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text('هل أنت متأكد من رغبتك في إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.resetSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('الشروط والأحكام'),
        content: const SingleChildScrollView(
          child: Text(
            'هذا نص تجريبي للشروط والأحكام. يجب استبداله بالنص الفعلي للشروط والأحكام الخاصة بالتطبيق.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Text(
            'هذا نص تجريبي لسياسة الخصوصية. يجب استبداله بالنص الفعلي لسياسة الخصوصية الخاصة بالتطبيق.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('الدعم الفني'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('للتواصل مع فريق الدعم الفني:'),
            SizedBox(height: 8),
            Text('البريد الإلكتروني: support@inventorysudan.com'),
            SizedBox(height: 4),
            Text('الهاتف: +249123456789'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
