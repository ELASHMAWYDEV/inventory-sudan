import 'package:flutter/material.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

enum StatisticsPeriod {
  thisMonth,
  lastMonth,
  last3Months,
  last6Months,
  thisYear,
  lastYear,
  allTime,
  custom,
}

extension StatisticsPeriodExtension on StatisticsPeriod {
  String get displayName {
    switch (this) {
      case StatisticsPeriod.thisMonth:
        return 'هذا الشهر';
      case StatisticsPeriod.lastMonth:
        return 'الشهر الماضي';
      case StatisticsPeriod.last3Months:
        return 'آخر 3 أشهر';
      case StatisticsPeriod.last6Months:
        return 'آخر 6 أشهر';
      case StatisticsPeriod.thisYear:
        return 'هذا العام';
      case StatisticsPeriod.lastYear:
        return 'العام الماضي';
      case StatisticsPeriod.allTime:
        return 'كل الفترات';
      case StatisticsPeriod.custom:
        return 'فترة مخصصة';
    }
  }

  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case StatisticsPeriod.thisMonth:
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: firstDayOfMonth, end: lastDayOfMonth);

      case StatisticsPeriod.lastMonth:
        final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(start: firstDayOfLastMonth, end: lastDayOfLastMonth);

      case StatisticsPeriod.last3Months:
        final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
        return DateTimeRange(start: threeMonthsAgo, end: today);

      case StatisticsPeriod.last6Months:
        final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);
        return DateTimeRange(start: sixMonthsAgo, end: today);

      case StatisticsPeriod.thisYear:
        final firstDayOfYear = DateTime(now.year, 1, 1);
        final lastDayOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: firstDayOfYear, end: lastDayOfYear);

      case StatisticsPeriod.lastYear:
        final firstDayOfLastYear = DateTime(now.year - 1, 1, 1);
        final lastDayOfLastYear = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        return DateTimeRange(start: firstDayOfLastYear, end: lastDayOfLastYear);

      case StatisticsPeriod.allTime:
        return DateTimeRange(
          start: DateTime(2020, 1, 1), // Reasonable start date
          end: today,
        );

      case StatisticsPeriod.custom:
        // Default to this month for custom, will be overridden
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: firstDayOfMonth, end: today);
    }
  }
}

class PeriodSelector extends StatelessWidget {
  final StatisticsPeriod selectedPeriod;
  final DateTimeRange? customDateRange;
  final Function(StatisticsPeriod) onPeriodChanged;
  final Function(DateTimeRange) onCustomDateRangeChanged;
  final String title;

  const PeriodSelector({
    Key? key,
    required this.selectedPeriod,
    this.customDateRange,
    required this.onPeriodChanged,
    required this.onCustomDateRangeChanged,
    this.title = 'فترة الإحصائيات',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Icon(
                  Icons.date_range,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.heading3,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Period chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StatisticsPeriod.values.map((period) {
                final isSelected = selectedPeriod == period;
                return FilterChip(
                  label: Text(
                    period.displayName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      if (period == StatisticsPeriod.custom) {
                        _showCustomDatePicker(context);
                      } else {
                        onPeriodChanged(period);
                      }
                    }
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              }).toList(),
            ),

            // Custom date range display
            if (selectedPeriod == StatisticsPeriod.custom && customDateRange != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateRange(customDateRange!),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _showCustomDatePicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'تغيير',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final initialDateRange = customDateRange ?? selectedPeriod.getDateRange();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      locale: const Locale('ar', 'SD'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onPeriodChanged(StatisticsPeriod.custom);
      onCustomDateRangeChanged(picked);
    }
  }

  String _formatDateRange(DateTimeRange range) {
    final startFormatted = '${range.start.day}/${range.start.month}/${range.start.year}';
    final endFormatted = '${range.end.day}/${range.end.month}/${range.end.year}';
    return '$startFormatted - $endFormatted';
  }
}
