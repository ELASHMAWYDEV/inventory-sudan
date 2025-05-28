import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/controllers/auth/auth_controller.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_text_field.dart';
import 'package:inventory_sudan/utils/app_router.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _authController = Get.find<AuthController>();
  bool _showPassword = false;

  void _login() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formValues = _formKey.currentState!.value;
      _authController.signIn(
        formValues['email'] as String,
        formValues['password'] as String,
      );
    }
  }

  void _quickLogin(String userType) {
    final credentials = {
      'admin': {'email': 'admin@inventory.sudan', 'password': 'admin123'},
      'worker': {'email': 'worker@inventory.sudan', 'password': 'worker123'},
    };

    final cred = credentials[userType];
    if (cred != null) {
      _authController.signIn(cred['email']!, cred['password']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or App name
                  Center(
                    child: Text(
                      'نظام المخزون',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Email/Username field
                  CustomTextField(
                    name: 'email',
                    label: 'البريد الإلكتروني',
                    hint: 'أدخل البريد الإلكتروني',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(Icons.email_outlined),
                    validators: [
                      FormBuilderValidators.required(errorText: 'يرجى إدخال البريد الإلكتروني'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    name: 'password',
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    obscureText: !_showPassword,
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    validators: [
                      FormBuilderValidators.required(errorText: 'يرجى إدخال كلمة المرور'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Error message
                  Obx(() {
                    return _authController.error.value.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _authController.error.value,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink();
                  }),

                  // Login button
                  Obx(() {
                    return CustomButton(
                      label: 'تسجيل الدخول',
                      onPressed: _login,
                      isLoading: _authController.isLoading.value,
                      icon: Icons.login,
                    );
                  }),

                  const SizedBox(height: 16),

                  // Alternative login options
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: AppColors.border,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'أو',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: AppColors.border,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Phone login button (for workers)
                  CustomButton(
                    label: 'تسجيل الدخول برقم الهاتف',
                    onPressed: () {
                      // TODO: Implement phone login
                      Get.toNamed('/phone-login');
                    },
                    isOutlined: true,
                    icon: Icons.phone_android,
                  ),

                  const SizedBox(height: 24),

                  // Help text
                  Center(
                    child: Text(
                      'للمساعدة، يرجى التواصل مع المشرف',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quick login buttons for testing
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'تسجيل دخول سريع للاختبار',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _quickLogin('admin'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('مدير'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _quickLogin('worker'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('عامل'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'admin@inventory.sudan / worker@inventory.sudan',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
