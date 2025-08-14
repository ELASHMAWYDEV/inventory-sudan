import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:inventory_sudan/models/user_model.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_text_field.dart';
import 'package:inventory_sudan/ui/widgets/common/permission_selector.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class UserFormScreen extends StatefulWidget {
  final String role;
  final UserModel? user;
  final Function(UserModel) onUserSaved;

  const UserFormScreen({
    Key? key,
    required this.role,
    this.user,
    required this.onUserSaved,
  }) : super(key: key);

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  List<String> _selectedPermissions = [];

  @override
  void initState() {
    super.initState();
    // Initialize permissions based on user data or default role permissions
    _selectedPermissions = widget.user?.permissions ?? _getDefaultRolePermissions(widget.role);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'تعديل المستخدم' : 'إضافة مستخدم جديد',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role info card
                _buildRoleInfoCard(),

                const SizedBox(height: 24),

                // Form fields
                _buildFormFields(isEditing),

                const SizedBox(height: 24),

                // Permissions section
                _buildPermissionsSection(),

                const SizedBox(height: 32),

                // Save button
                _buildSaveButton(isEditing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleInfoCard() {
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getRoleColor(widget.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getRoleIcon(widget.role),
                    color: _getRoleColor(widget.role),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دور المستخدم: ${_getRoleDisplayName(widget.role)}',
                      style: AppTextStyles.heading3,
                    ),
                    Text(
                      _getRoleDescription(widget.role),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'الصلاحيات:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getRolePermissions(widget.role).map((permission) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(widget.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    permission,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getRoleColor(widget.role),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'بيانات المستخدم',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 16),

        // Name field
        CustomTextField(
          name: 'name',
          label: 'الاسم الكامل',
          hint: 'أدخل الاسم الكامل',
          prefixIcon: const Icon(Icons.person),
          initialValue: widget.user?.name,
          validators: [
            FormBuilderValidators.required(errorText: 'الاسم مطلوب'),
            FormBuilderValidators.minLength(2, errorText: 'الاسم يجب أن يكون أكثر من حرفين'),
          ],
        ),

        const SizedBox(height: 16),

        // Email field
        CustomTextField(
          name: 'email',
          label: 'البريد الإلكتروني',
          hint: 'أدخل البريد الإلكتروني',
          prefixIcon: const Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
          initialValue: widget.user?.email,
          validators: [
            FormBuilderValidators.required(errorText: 'البريد الإلكتروني مطلوب'),
            FormBuilderValidators.email(errorText: 'البريد الإلكتروني غير صحيح'),
          ],
        ),

        if (!isEditing) ...[
          const SizedBox(height: 16),

          // Password field
          CustomTextField(
            name: 'password',
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            prefixIcon: const Icon(Icons.lock),
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validators: [
              FormBuilderValidators.required(errorText: 'كلمة المرور مطلوبة'),
              FormBuilderValidators.minLength(6, errorText: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'),
            ],
          ),

          const SizedBox(height: 16),

          // Confirm password field
          CustomTextField(
            name: 'confirmPassword',
            label: 'تأكيد كلمة المرور',
            hint: 'أعد إدخال كلمة المرور',
            prefixIcon: const Icon(Icons.lock_outline),
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validators: [
              FormBuilderValidators.required(errorText: 'تأكيد كلمة المرور مطلوب'),
              (value) {
                final password = _formKey.currentState?.fields['password']?.value;
                if (value != password) {
                  return 'كلمات المرور غير متطابقة';
                }
                return null;
              },
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPermissionsSection() {
    return PermissionSelector(
      title: 'صلاحيات المستخدم',
      availablePermissions: _getAllAvailablePermissions(),
      selectedPermissions: _selectedPermissions,
      accentColor: _getRoleColor(widget.role),
      onPermissionsChanged: (permissions) {
        setState(() {
          _selectedPermissions = permissions;
        });
      },
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return CustomButton(
      label: isEditing ? 'حفظ التعديلات' : 'إضافة المستخدم',
      onPressed: _isLoading ? null : _saveUser,
      isLoading: _isLoading,
      backgroundColor: _getRoleColor(widget.role),
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
        return AppColors.primary;
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

  String _getRoleDescription(String role) {
    switch (role) {
      case 'admin':
        return 'صلاحيات كاملة لإدارة النظام';
      case 'manager':
        return 'صلاحيات إدارة المخزون والبيانات';
      case 'employee':
        return 'صلاحيات محدودة للعرض والإدخال';
      default:
        return '';
    }
  }

  List<String> _getAllAvailablePermissions() {
    return [
      // User Management
      'إدارة المستخدمين',
      'إضافة مستخدمين جدد',
      'تعديل بيانات المستخدمين',
      'حذف المستخدمين',
      'عرض قائمة المستخدمين',

      // System Management
      'إدارة النظام',
      'تعديل الإعدادات',
      'إعدادات النظام',
      'إدارة التطبيق',

      // Data Management
      'عرض جميع البيانات',
      'عرض البيانات',
      'إضافة البيانات',
      'تعديل البيانات',
      'حذف البيانات',
      'إضافة البيانات المحدودة',

      // Inventory Management
      'إدارة المخزون',
      'عرض المخزون',
      'تحديث المخزون',
      'جرد المخزون',

      // Farm to Drying
      'إدارة من المزرعة للتجفيف',
      'إضافة منتجات للتجفيف',
      'تعديل بيانات التجفيف',
      'عرض بيانات التجفيف',

      // Packaging
      'إدارة التعبئة',
      'إضافة منتجات معبأة',
      'تعديل بيانات التعبئة',
      'عرض بيانات التعبئة',

      // Sales
      'إدارة المبيعات',
      'إضافة مبيعات',
      'تعديل المبيعات',
      'عرض المبيعات',
      'حذف المبيعات',

      // Reports
      'عرض التقارير',
      'إنشاء التقارير',
      'تصدير التقارير',

      // Analytics
      'عرض الإحصائيات',
      'عرض التحليلات المتقدمة',
    ];
  }

  List<String> _getDefaultRolePermissions(String role) {
    switch (role) {
      case 'admin':
        return [
          'إدارة المستخدمين',
          'إدارة النظام',
          'عرض جميع البيانات',
          'تعديل الإعدادات',
          'حذف البيانات',
          'إدارة المخزون',
          'إدارة من المزرعة للتجفيف',
          'إدارة التعبئة',
          'إدارة المبيعات',
          'عرض التقارير',
          'إنشاء التقارير',
          'عرض الإحصائيات',
        ];
      case 'manager':
        return [
          'عرض البيانات',
          'إضافة البيانات',
          'تعديل البيانات',
          'إدارة المخزون',
          'إدارة من المزرعة للتجفيف',
          'إدارة التعبئة',
          'إدارة المبيعات',
          'عرض التقارير',
          'عرض الإحصائيات',
        ];
      case 'employee':
        return [
          'عرض البيانات',
          'إضافة البيانات المحدودة',
          'عرض المخزون',
          'عرض بيانات التجفيف',
          'عرض بيانات التعبئة',
          'عرض المبيعات',
        ];
      default:
        return [];
    }
  }

  List<String> _getRolePermissions(String role) {
    return _getDefaultRolePermissions(role);
  }

  void _saveUser() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      final formData = _formKey.currentState!.value;
      final isEditing = widget.user != null;
      final savedUser = UserModel(
        id: isEditing ? widget.user!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: formData['name'].toString().trim(),
        email: formData['email'].toString().trim(),
        role: widget.role,
        permissions: _selectedPermissions,
        createdAt: isEditing ? widget.user!.createdAt : DateTime.now(),
        lastLogin: isEditing ? widget.user!.lastLogin : DateTime.now(),
      );

      widget.onUserSaved(savedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'تم تحديث المستخدم بنجاح' : 'تم إضافة المستخدم بنجاح',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
