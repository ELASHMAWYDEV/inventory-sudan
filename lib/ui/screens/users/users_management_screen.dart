import 'package:flutter/material.dart';
import 'package:inventory_sudan/models/user_model.dart';
import 'package:inventory_sudan/ui/screens/users/user_form_screen.dart';
import 'package:inventory_sudan/ui/widgets/common/form_option_bottom_sheet.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({Key? key}) : super(key: key);

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  List<UserModel> users = [
    // Mock data for demonstration
    UserModel(
      id: '1',
      name: 'أحمد محمد',
      email: 'ahmed@example.com',
      role: 'admin',
      permissions: ['إدارة المستخدمين', 'إدارة النظام', 'عرض جميع البيانات', 'تعديل الإعدادات', 'حذف البيانات'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    UserModel(
      id: '2',
      name: 'فاطمة علي',
      email: 'fatima@example.com',
      role: 'manager',
      permissions: ['عرض البيانات', 'إضافة البيانات', 'تعديل البيانات', 'إدارة المخزون'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastLogin: DateTime.now().subtract(const Duration(days: 1)),
    ),
    UserModel(
      id: '3',
      name: 'محمود حسن',
      email: 'mahmoud@example.com',
      role: 'employee',
      permissions: ['عرض البيانات', 'إضافة البيانات المحدودة'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      lastLogin: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: users.isEmpty ? _buildEmptyState() : _buildUsersList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserOptions,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'إضافة مستخدم',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.people_outline,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا يوجد مستخدمين',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة المستخدمين لإدارة النظام',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics card
          _buildStatsCard(),

          const SizedBox(height: 24),

          // Users list title
          Row(
            children: [
              Text(
                'المستخدمين',
                style: AppTextStyles.heading2,
              ),
              const Spacer(),
              Text(
                '${users.length} مستخدم',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Users list
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildUserCard(users[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final adminCount = users.where((u) => u.role == 'admin').length;
    final managerCount = users.where((u) => u.role == 'manager').length;
    final employeeCount = users.where((u) => u.role == 'employee').length;

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
            Text(
              'إحصائيات المستخدمين',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'مدراء',
                    count: adminCount,
                    color: AppColors.danger,
                    icon: Icons.admin_panel_settings,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    label: 'مشرفين',
                    count: managerCount,
                    color: AppColors.warning,
                    icon: Icons.supervisor_account,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    label: 'موظفين',
                    count: employeeCount,
                    color: AppColors.info,
                    icon: Icons.person,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: AppTextStyles.heading2.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
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
                // User avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getRoleIcon(user.role),
                      color: _getRoleColor(user.role),
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit button
                IconButton(
                  onPressed: () => _editUser(user),
                  icon: const Icon(
                    Icons.edit,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Role and permissions
            Row(
              children: [
                _buildRoleBadge(user.role),
                const Spacer(),
                Text(
                  'آخر دخول: ${_formatLastLogin(user.lastLogin)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Permissions
            _buildPermissions(user.permissions),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getRoleColor(role).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(role),
            color: _getRoleColor(role),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _getRoleDisplayName(role),
            style: AppTextStyles.bodySmall.copyWith(
              color: _getRoleColor(role),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissions(List<String> permissions) {
    if (permissions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          'لا توجد صلاحيات محددة',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'الصلاحيات:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '${permissions.length} صلاحية',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...permissions.take(4).map((permission) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  permission,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
            if (permissions.length > 4)
              GestureDetector(
                onTap: () => _showAllPermissions(permissions),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+${permissions.length - 4} أخرى',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.visibility,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.danger;
      case 'manager':
        return AppColors.warning;
      case 'employee':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'manager':
        return Icons.supervisor_account;
      case 'employee':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'مدير';
      case 'manager':
        return 'مشرف';
      case 'employee':
        return 'موظف';
      default:
        return 'غير محدد';
    }
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else {
      return '${difference.inMinutes} دقيقة';
    }
  }

  void _showAddUserOptions() {
    FormOptionBottomSheet.show(
      context: context,
      title: 'إضافة مستخدم جديد',
      options: [
        FormOptionItem(
          title: 'مدير',
          subtitle: 'صلاحيات كاملة لإدارة النظام',
          icon: Icons.admin_panel_settings,
          color: AppColors.danger,
          onTap: () {
            Navigator.pop(context);
            _navigateToUserForm('admin');
          },
        ),
        FormOptionItem(
          title: 'مشرف',
          subtitle: 'صلاحيات إدارة المخزون والبيانات',
          icon: Icons.supervisor_account,
          color: AppColors.warning,
          onTap: () {
            Navigator.pop(context);
            _navigateToUserForm('manager');
          },
        ),
        FormOptionItem(
          title: 'موظف',
          subtitle: 'صلاحيات محدودة للعرض والإدخال',
          icon: Icons.person,
          color: AppColors.info,
          onTap: () {
            Navigator.pop(context);
            _navigateToUserForm('employee');
          },
        ),
      ],
    );
  }

  void _navigateToUserForm(String role, [UserModel? user]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(
          role: role,
          user: user,
          onUserSaved: (savedUser) {
            setState(() {
              if (user != null) {
                // Edit existing user
                final index = users.indexWhere((u) => u.id == user.id);
                if (index != -1) {
                  users[index] = savedUser;
                }
              } else {
                // Add new user
                users.add(savedUser);
              }
            });
          },
        ),
      ),
    );
  }

  void _editUser(UserModel user) {
    _navigateToUserForm(user.role, user);
  }

  void _showAllPermissions(List<String> permissions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.security,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'جميع الصلاحيات',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إجمالي ${permissions.length} صلاحية',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: permissions.map((permission) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          permission,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
