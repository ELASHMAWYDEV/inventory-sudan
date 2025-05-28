import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sudan/models/sales_model.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class SalesDetailsScreen extends StatefulWidget {
  const SalesDetailsScreen({Key? key}) : super(key: key);

  @override
  State<SalesDetailsScreen> createState() => _SalesDetailsScreenState();
}

class _SalesDetailsScreenState extends State<SalesDetailsScreen> {
  final _dataService = serviceLocator<DataService>();
  SalesModel? _salesData;
  bool _isLoading = true;
  String? _salesId;

  @override
  void initState() {
    super.initState();
    _salesId = Get.arguments?['id'];
    if (_salesId != null) {
      _loadSalesData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSalesData() async {
    try {
      final salesData = await _dataService.getSalesRecord(_salesId!);
      setState(() {
        _salesData = salesData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل البيانات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل البيع'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _salesData == null
              ? const Center(
                  child: Text(
                    'لم يتم العثور على بيانات البيع',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 16),
                      _buildBuyerInfoCard(),
                      const SizedBox(height: 16),
                      _buildItemsCard(),
                      const SizedBox(height: 16),
                      _buildPaymentCard(),
                      if (_salesData!.notes != null && _salesData!.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildNotesCard(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderCard() {
    final formattedDate = DateFormat('yyyy/MM/dd - HH:mm').format(_salesData!.saleDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.point_of_sale,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'معلومات البيع',
                  style: AppTextStyles.heading3,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(_salesData!.paymentStatus).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getPaymentStatusText(_salesData!.paymentStatus),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getPaymentStatusColor(_salesData!.paymentStatus),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow('تاريخ البيع:', formattedDate),
            const SizedBox(height: 8),
            _buildDetailRow('رقم البيع:', _salesData!.id ?? 'غير محدد'),
            const SizedBox(height: 8),
            _buildDetailRow('تم الإنشاء بواسطة:', _salesData!.createdBy),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getBuyerTypeIcon(_salesData!.buyerType),
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'معلومات المشتري',
                  style: AppTextStyles.heading3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow('اسم المشتري:', _salesData!.buyerName),
            const SizedBox(height: 8),
            _buildDetailRow('نوع المشتري:', _salesData!.buyerType),
            const SizedBox(height: 8),
            _buildDetailRow('موقع المشتري:', _salesData!.buyerLocation),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'المنتجات المباعة',
                  style: AppTextStyles.heading3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _salesData!.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _salesData!.items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.packageType,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الكمية: ${item.quantityOfPackages} عبوة',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            'السعر: ${_formatCurrency(item.pricePerPackage)} جنيه',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الإجمالي:',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_formatCurrency(item.totalPrice)} جنيه',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'معلومات الدفع',
                  style: AppTextStyles.heading3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow(
              'إجمالي المبلغ:',
              '${_formatCurrency(_salesData!.totalAmount)} جنيه',
              valueColor: AppColors.primary,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'المبلغ المحصل:',
              '${_formatCurrency(_salesData!.collectedAmount)} جنيه',
              valueColor: Colors.green,
            ),
            if (_salesData!.remainingAmount > 0) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'المبلغ المتبقي:',
                '${_formatCurrency(_salesData!.remainingAmount)} جنيه',
                valueColor: Colors.red,
              ),
            ],
            const SizedBox(height: 8),
            _buildDetailRow(
              'حالة الدفع:',
              _getPaymentStatusText(_salesData!.paymentStatus),
              valueColor: _getPaymentStatusColor(_salesData!.paymentStatus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'ملاحظات',
                  style: AppTextStyles.heading3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              _salesData!.notes!,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getBuyerTypeIcon(String buyerType) {
    switch (buyerType.toLowerCase()) {
      case 'supermarket':
        return Icons.store;
      case 'individual':
        return Icons.person;
      case 'online client':
        return Icons.computer;
      default:
        return Icons.business;
    }
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentStatusText(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return 'مدفوع';
      case 'partial':
        return 'مدفوع جزئياً';
      case 'unpaid':
        return 'غير مدفوع';
      default:
        return 'غير محدد';
    }
  }

  String _formatCurrency(num amount) {
    return NumberFormat('#,###').format(amount);
  }
}
