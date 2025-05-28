import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class FarmToDryingDetailsScreen extends StatefulWidget {
  const FarmToDryingDetailsScreen({super.key});

  @override
  State<FarmToDryingDetailsScreen> createState() => _FarmToDryingDetailsScreenState();
}

class _FarmToDryingDetailsScreenState extends State<FarmToDryingDetailsScreen> {
  final _dataService = serviceLocator<DataService>();
  FarmToDryingModel? _record;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    try {
      final arguments = Get.arguments as Map<String, dynamic>?;
      final recordId = arguments?['id'] as String?;

      if (recordId != null) {
        final records = await _dataService.getFarmToDryingRecords();
        _record = records.firstWhereOrNull((record) => record.id == recordId);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل البيانات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _record == null
              ? const Center(
                  child: Text(
                    'لم يتم العثور على البيانات',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 16),
                      _buildDetailsCard(),
                      const SizedBox(height: 16),
                      _buildFinancialCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getProductIcon(_record!.productName),
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _record!.productName,
                        style: AppTextStyles.heading2,
                      ),
                      if (_record!.productType != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _record!.productType!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
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
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل الشراء',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('تاريخ الشراء', DateFormat('yyyy/MM/dd').format(_record!.purchaseDate)),
            if (_record!.purchaseLocation != null) _buildDetailRow('مكان الشراء', _record!.purchaseLocation!),
            if (_record!.supplierName != null) _buildDetailRow('اسم المورد', _record!.supplierName!),
            _buildDetailRow('عدد الأكياس', _record!.sackCount.toString()),
            if (_record!.totalWeightBeforeDrying != null)
              _buildDetailRow('الوزن الكلي', '${_formatNumber(_record!.totalWeightBeforeDrying!)} كجم'),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التفاصيل المالية',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('تكلفة الشراء', '${_formatCurrency(_record!.productCost)} جنيه'),
            _buildDetailRow('التكلفة الإجمالية', '${_formatCurrency(_record!.totalCosts)} جنيه'),
            if (_record!.transportationCost != null)
              _buildDetailRow('تكلفة النقل', '${_formatCurrency(_record!.transportationCost!)} جنيه'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon(String productName) {
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
