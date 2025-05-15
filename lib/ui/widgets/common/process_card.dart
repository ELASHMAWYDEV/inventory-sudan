import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class ProcessCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final String? svgIcon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const ProcessCard({
    Key? key,
    required this.title,
    required this.description,
    this.icon,
    this.svgIcon,
    this.iconColor = AppColors.primary,
    this.backgroundColor = AppColors.surface,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _buildIcon(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (svgIcon != null) {
      return SvgPicture.asset(
        svgIcon!,
        width: 36,
        height: 36,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else if (icon != null) {
      return Icon(
        icon,
        size: 36,
        color: iconColor,
      );
    } else {
      return const Icon(
        Icons.error,
        size: 36,
        color: AppColors.error,
      );
    }
  }
}
