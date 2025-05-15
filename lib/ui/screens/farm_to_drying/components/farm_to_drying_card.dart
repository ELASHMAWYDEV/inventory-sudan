// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:inventory_sudan/utils/app_router.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class FarmToDryingCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const FarmToDryingCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final purchaseDate = data['purchaseDate'] != null ? DateTime.parse(data['purchaseDate']) : DateTime.now();
    final formattedDate = DateFormat('yyyy/MM/dd').format(purchaseDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRouter.FARM_TO_DRYING_DETAILS,
            arguments: {'id': data['id']},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getProductIcon(data['productName']),
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['productName'] ?? 'منتج',
                    style: AppTextStyles.heading3,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data['productType'] ?? 'غير محدد',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    Icons.calendar_today,
                    formattedDate,
                    'تاريخ الشراء',
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    Icons.shopping_bag,
                    '${data['quantity'] ?? 0} ${data['quantityUnit'] ?? ''}',
                    'الكمية',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoItem(
                    Icons.location_on,
                    data['purchaseLocation'] ?? 'غير محدد',
                    'مكان الشراء',
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    Icons.agriculture,
                    data['supplierName'] ?? 'غير محدد',
                    'المورد',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التكلفة الإجمالية:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${_formatCurrency(data['totalCosts'] ?? 0)} جنيه',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الوزن الكلي:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${_formatNumber(data['wholeWeight'] ?? 0)} كجم',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon(String? productName) {
    if (productName == null) return Icons.category;

    switch (productName.toLowerCase()) {
      case 'فول سوداني':
        return Icons.eco;
      case 'سمسم':
        return Icons.grass;
      case 'ذرة':
        return Icons.agriculture;
      default:
        return Icons.category;
    }
  }

  String _formatCurrency(num amount) {
    return NumberFormat('#,###').format(amount);
  }

  String _formatNumber(num value) {
    return NumberFormat('#,##0.##').format(value);
  }
}
