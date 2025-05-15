import 'package:flutter/material.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool disabled;

  const CustomButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: disabled || isLoading ? null : onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : (backgroundColor ?? AppColors.primary),
          foregroundColor: textColor ?? (isOutlined ? AppColors.primary : Colors.white),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
            side: isOutlined
                ? BorderSide(
                    color: borderColor ?? AppColors.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          elevation: isOutlined ? 0 : 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOutlined ? AppColors.primary : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: disabled ? Colors.grey.shade400 : (textColor ?? (isOutlined ? AppColors.primary : Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
