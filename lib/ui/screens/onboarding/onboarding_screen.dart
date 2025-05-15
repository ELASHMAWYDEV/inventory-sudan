import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/controllers/auth/auth_controller.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final AuthController _authController = Get.find<AuthController>();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'مرحباً بك في نظام المخزون',
      description: 'تطبيق سهل الاستخدام لتتبع المنتجات من المزرعة إلى التسويق',
      image: Icons.inventory_2,
      gradient: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    ),
    OnboardingItem(
      title: 'من المزرعة للتجفيف',
      description: 'تسجيل تفاصيل المنتجات من المزرعة وحتى مرحلة التجفيف بكل سهولة',
      image: Icons.agriculture,
      gradient: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    ),
    OnboardingItem(
      title: 'مرحلة التعبئة',
      description: 'تتبع المنتجات المعبأة وإدارة المخزون بطريقة بسيطة ومرئية',
      image: Icons.inventory,
      gradient: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    ),
    OnboardingItem(
      title: 'المبيعات',
      description: 'تسجيل المبيعات وتتبع الإيرادات بسهولة، مع إمكانية عرض التقارير',
      image: Icons.point_of_sale,
      gradient: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToNextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    _authController.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _buildPage(_items[index]);
            },
          ),

          // Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.9),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? AppColors.primary : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip Button
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'تخطي',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Next/Get Started Button
                        CustomButton(
                          label: _currentPage == _items.length - 1 ? 'ابدأ الآن' : 'التالي',
                          onPressed: _goToNextPage,
                          isFullWidth: false,
                          icon: _currentPage == _items.length - 1 ? Icons.check : Icons.arrow_forward,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: item.gradient,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.image,
                    size: 100,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 48),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    item.title,
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    item.description,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData image;
  final List<Color> gradient;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.gradient,
  });
}
