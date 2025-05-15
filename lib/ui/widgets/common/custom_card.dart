import 'package:flutter/material.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final Color? color;
  final double elevation;
  final VoidCallback? onTap;
  final bool hasBorder;
  final Color? borderColor;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 8.0,
    this.color,
    this.elevation = 1.0,
    this.onTap,
    this.hasBorder = false,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation * 3,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: Material(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: padding ?? const EdgeInsets.all(16.0),
            decoration: hasBorder
                ? BoxDecoration(
                    border: Border.all(
                      color: borderColor ?? AppColors.border,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                  )
                : null,
            child: child,
          ),
        ),
      ),
    );
  }
}
