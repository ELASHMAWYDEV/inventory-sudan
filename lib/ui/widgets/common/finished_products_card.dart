import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class FinishedProductsCard extends StatelessWidget {
  final FinishedProductsModel item;
  final VoidCallback? onTap;
  final bool showPackageInfo;

  const FinishedProductsCard({
    super.key,
    required this.item,
    this.onTap,
    this.showPackageInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_shipping,
            color: Colors.orange,
          ),
        ),
        title: Text(
          'دفعة: ${item.batchNumber}',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الكمية: ${item.quantity}'),
            if (showPackageInfo)
              Text(
                'معرف العبوة: ${item.emptyPackageId}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            Text(
              DateFormat('yyyy-MM-dd').format(item.createdAt),
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: item.notes != null && item.notes!.isNotEmpty ? const Icon(Icons.note, color: Colors.blue) : null,
      ),
    );
  }
}
