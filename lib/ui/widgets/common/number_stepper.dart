import 'package:flutter/material.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class NumberStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String label;
  final String? unit;
  final double iconSize;
  final double height;
  final double width;

  const NumberStepper({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    required this.label,
    this.unit,
    this.iconSize = 32,
    this.height = 48,
    this.width = 140,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrement button
              _buildIconButton(
                icon: Icons.remove,
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              
              // Value display
              Text(
                unit != null ? '$value $unit' : '$value',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Increment button
              _buildIconButton(
                icon: Icons.add,
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({required IconData icon, VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: height,
          width: height,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: onPressed == null ? Colors.grey : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class LargeNumberStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String label;
  final String? unit;

  const LargeNumberStepper({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    required this.label,
    this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.heading3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLargeButton(
              icon: Icons.remove,
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            SizedBox(
              width: 100,
              child: Text(
                unit != null ? '$value $unit' : '$value',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
            ),
            _buildLargeButton(
              icon: Icons.add,
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      height: 60,
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: onPressed == null ? Colors.grey.shade300 : AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            icon,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
