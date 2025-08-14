import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/controllers/auth/auth_controller.dart';
import 'package:inventory_sudan/ui/widgets/common/process_card.dart';
import 'package:inventory_sudan/ui/widgets/common/batch_workflow_widget.dart';
import 'package:inventory_sudan/utils/app_router.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/services/dummy_data_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'نظام المخزون',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          drawer: _buildDrawer(context, authController),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                                  'مرحباً،',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                Text(
                                  authController.user?.name ?? 'مستخدم',
                                  style: AppTextStyles.heading2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section title
                  Text(
                    'العمليات',
                    style: AppTextStyles.heading2,
                  ),

                  const SizedBox(height: 16),

                  // Process grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                    children: [
                      // Farm to Drying process
                      ProcessCard(
                        title: 'من المزرعة للتجفيف',
                        description: 'تسجيل المنتجات من المزرعة إلى مرحلة التجفيف',
                        icon: Icons.agriculture,
                        iconColor: Colors.green,
                        onTap: () {
                          Get.toNamed(AppRouter.FARM_TO_DRYING);
                        },
                      ),

                      // Packaging process
                      ProcessCard(
                        title: 'التعبئة',
                        description: 'تسجيل المنتجات بعد التجفيف والتعبئة',
                        icon: Icons.inventory,
                        iconColor: Colors.orange,
                        onTap: () {
                          Get.toNamed(AppRouter.PACKAGING);
                        },
                      ),

                      // Sales process
                      ProcessCard(
                        title: 'المبيعات',
                        description: 'تسجيل مبيعات المنتجات',
                        icon: Icons.point_of_sale,
                        iconColor: Colors.blue,
                        onTap: () {
                          Get.toNamed(AppRouter.SALES);
                        },
                      ),

                      // Stock log process
                      ProcessCard(
                        title: 'جرد المخزون',
                        description: 'تسجيل وتتبع حالة المخزون',
                        icon: Icons.inventory_2,
                        iconColor: Colors.purple,
                        onTap: () {
                          Get.toNamed(AppRouter.STOCK_LOG);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Quick stats section
                  Text(
                    'إحصائيات سريعة',
                    style: AppTextStyles.heading2,
                  ),

                  const SizedBox(height: 16),

                  // Stats cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'المنتجات',
                          value: '24',
                          icon: Icons.category,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'المبيعات اليوم',
                          value: '3',
                          icon: Icons.shopping_cart,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'قيد التجفيف',
                          value: '120 كجم',
                          icon: Icons.timer,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'نفاذ المخزون',
                          value: '2',
                          icon: Icons.warning_amber,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Batch Workflow Section
                  Text(
                    'تتبع مسار الدفعات',
                    style: AppTextStyles.heading2,
                  ),

                  const SizedBox(height: 16),

                  // Batch Workflow Widget
                  const BatchWorkflowWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: AppTextStyles.heading2,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthController authController) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authController.user?.name ?? 'مستخدم',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'نظام إدارة المخزون',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'الرئيسية',
                    isSelected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: 'إدارة المستخدمين',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRouter.USERS_MANAGEMENT);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics,
                    title: 'الإحصائيات',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRouter.STATISTICS);
                    },
                  ),
                  const Divider(
                    height: 40,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'الإعدادات',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRouter.SETTINGS);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.data_usage,
                    title: 'إضافة بيانات تجريبية',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      _showAddDummyDataDialog(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'المساعدة',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Help screen
                      Get.snackbar(
                        'قريباً',
                        'شاشة المساعدة قيد التطوير',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Logout section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'تسجيل الخروج',
                    isSelected: false,
                    isLogout: true,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutConfirmationDialog(context, authController);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : isLogout
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : isLogout
                    ? Colors.red
                    : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showAddDummyDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.data_usage, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('إضافة بيانات تجريبية'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'سيتم إضافة 5 دفعات تجريبية مختلفة لاختبار تتبع مسار الدفعات:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildDummyDataItem('🥜 BATCH-001: فول سوداني (مسار كامل)', 'مزرعة → تجفيف → تعبئة → بيع'),
            _buildDummyDataItem('🌽 BATCH-002: ذرة (مزرعة فقط)', 'مزرعة'),
            _buildDummyDataItem('🌻 BATCH-003: سمسم (حتى التجفيف)', 'مزرعة → تجفيف'),
            _buildDummyDataItem('🥜 BATCH-004: فول سوداني (حتى التعبئة)', 'مزرعة → تجفيف → تعبئة'),
            _buildDummyDataItem('🌻 BATCH-005: سمسم ذهبي (مسار كامل)', 'مزرعة → تجفيف → تعبئة → بيع'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ملاحظة: هذه بيانات تجريبية للاختبار فقط',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading dialog
              Get.dialog(
                const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('جاري إضافة البيانات التجريبية...'),
                    ],
                  ),
                ),
                barrierDismissible: false,
              );

              try {
                await DummyDataService.addDummyBatches();
                Get.back(); // Close loading dialog

                Get.snackbar(
                  'نجح',
                  'تم إضافة البيانات التجريبية بنجاح! يمكنك الآن اختبار تتبع مسار الدفعات',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.back(); // Close loading dialog

                Get.snackbar(
                  'خطأ',
                  'حدث خطأ أثناء إضافة البيانات: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة البيانات'),
          ),
        ],
      ),
    );
  }

  Widget _buildDummyDataItem(String title, String stages) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            stages,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
