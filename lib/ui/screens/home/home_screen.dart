import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/controllers/auth/auth_controller.dart';
import 'package:inventory_sudan/ui/widgets/common/process_card.dart';
import 'package:inventory_sudan/utils/app_router.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'نظام المخزون',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmationDialog(context, authController);
            },
          ),
        ],
      ),
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
                            Obx(() {
                              final displayName = authController.user.value?.name ?? 'مستخدم';
                              return Text(
                                displayName,
                                style: AppTextStyles.heading2,
                              );
                            }),
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
            ],
          ),
        ),
      ),
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
}
