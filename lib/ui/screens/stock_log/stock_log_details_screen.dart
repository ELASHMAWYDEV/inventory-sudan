import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sudan/models/stock_log_model.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';

class StockLogDetailsScreen extends StatefulWidget {
  const StockLogDetailsScreen({Key? key}) : super(key: key);

  @override
  State<StockLogDetailsScreen> createState() => _StockLogDetailsScreenState();
}

class _StockLogDetailsScreenState extends State<StockLogDetailsScreen> {
  final _dataService = serviceLocator<DataService>();
  late StockLogModel stockLog;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    stockLog = Get.arguments as StockLogModel;
  }

  Future<void> _deleteStockLog() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _dataService.deleteStockLogRecord(stockLog.id!);
      Get.snackbar(
        'نجح',
        'تم حذف جرد المخزون بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف البيانات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: const Text('هل أنت متأكد من رغبتك في حذف هذا الجرد؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل جرد المخزون'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteStockLog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'معلومات عامة',
                                      style: AppTextStyles.heading3,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(
                                      'تاريخ الجرد',
                                      dateFormatter.format(stockLog.logDate),
                                      Icons.calendar_today,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      'وقت الإنشاء',
                                      '${dateFormatter.format(stockLog.createdAt)} - ${timeFormatter.format(stockLog.createdAt)}',
                                      Icons.access_time,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      'تم بواسطة',
                                      stockLog.createdBy,
                                      Icons.person,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: stockLog.hasDiscrepancies
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      stockLog.hasDiscrepancies
                                          ? Icons.warning_amber_rounded
                                          : Icons.check_circle_rounded,
                                      size: 20,
                                      color: stockLog.hasDiscrepancies ? Colors.red : Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      stockLog.hasDiscrepancies ? 'يوجد تباين' : 'مطابق',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: stockLog.hasDiscrepancies ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Summary Statistics
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ملخص الجرد',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'إجمالي المنتجات',
                                  '${stockLog.inventoryItems.length}',
                                  Icons.inventory_2,
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatItem(
                                  'التباينات',
                                  '${_getDiscrepanciesCount()}',
                                  Icons.warning_amber,
                                  stockLog.hasDiscrepancies ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Inventory Items
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'منتجات الجرد',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 16),
                          ...stockLog.inventoryItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return _buildInventoryItemCard(item, index + 1);
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  // Notes Section
                  if (stockLog.notes != null && stockLog.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ملاحظات',
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                stockLog.notes!,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Images Section
                  if (stockLog.imageUrls != null && stockLog.imageUrls!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الصور المرفقة',
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: stockLog.imageUrls!.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    stockLog.imageUrls![index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
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
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.heading2.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItemCard(InventoryItem item, int index) {
    final difference = item.difference ?? 0;
    final hasDifference = difference != 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${index}. ${item.itemName}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getItemTypeColor(item.itemType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getItemTypeLabel(item.itemType),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getItemTypeColor(item.itemType),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Quantities
            Row(
              children: [
                Expanded(
                  child: _buildQuantityInfo(
                    'المتوقع',
                    '${item.expectedQuantity} ${item.unit}',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuantityInfo(
                    'الفعلي',
                    '${item.actualQuantity} ${item.unit}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuantityInfo(
                    'الفرق',
                    difference > 0
                        ? '+${difference.abs()} ${item.unit}'
                        : difference < 0
                            ? '-${difference.abs()} ${item.unit}'
                            : '0 ${item.unit}',
                    hasDifference ? (difference > 0 ? Colors.green : Colors.red) : Colors.grey,
                  ),
                ),
              ],
            ),

            // Reason for discrepancy
            if (hasDifference && item.reason != null && item.reason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          'سبب التباين:',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.reason!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getItemTypeColor(String itemType) {
    switch (itemType) {
      case 'raw_material':
        return Colors.green;
      case 'packaged_product':
        return Colors.blue;
      case 'empty_package':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getItemTypeLabel(String itemType) {
    switch (itemType) {
      case 'raw_material':
        return 'مواد خام';
      case 'packaged_product':
        return 'منتج معبأ';
      case 'empty_package':
        return 'عبوة فارغة';
      default:
        return 'غير محدد';
    }
  }

  int _getDiscrepanciesCount() {
    return stockLog.inventoryItems.where((item) => item.difference != null && item.difference != 0).length;
  }
}
