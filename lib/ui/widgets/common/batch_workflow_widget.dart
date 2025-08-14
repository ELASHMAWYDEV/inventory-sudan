import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/models/sales_model.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class BatchWorkflowWidget extends StatefulWidget {
  const BatchWorkflowWidget({super.key});

  @override
  State<BatchWorkflowWidget> createState() => _BatchWorkflowWidgetState();
}

class _BatchWorkflowWidgetState extends State<BatchWorkflowWidget> {
  final _dataService = serviceLocator<DataService>();
  List<String> _batchNumbers = [];
  String? _selectedBatch;
  bool _isLoading = true;
  bool _isLoadingWorkflow = false;

  // Workflow data
  List<FarmToDryingModel> _farmToDryingRecords = [];
  List<ProductsAfterDryingModel> _productsAfterDrying = [];
  List<FinishedProductsModel> _finishedProducts = [];
  List<SalesModel> _salesRecords = [];

  @override
  void initState() {
    super.initState();
    _loadBatchNumbers();
  }

  Future<void> _loadBatchNumbers() async {
    try {
      final batches = await _dataService.getExistingBatchNumbers();
      setState(() {
        _batchNumbers = batches;
        _isLoading = false;
        // Auto-select the latest batch if available
        if (_batchNumbers.isNotEmpty) {
          _selectedBatch = _batchNumbers.first;
          _loadBatchWorkflow(_selectedBatch!);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الدفعات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadBatchWorkflow(String batchNumber) async {
    setState(() {
      _isLoadingWorkflow = true;
    });

    try {
      // Load all related records for this batch
      final farmToDryingRecords = await _dataService.getFarmToDryingRecords();
      final productsAfterDrying = await _dataService.getProductsAfterDrying();
      final finishedProducts = await _dataService.getFinishedProducts();
      final salesRecords = await _dataService.getSalesRecords();

      setState(() {
        _farmToDryingRecords = farmToDryingRecords.where((record) => record.batchNumber == batchNumber).toList();

        _productsAfterDrying = productsAfterDrying.where((record) => record.batchNumber == batchNumber).toList();

        _finishedProducts = finishedProducts.where((record) => record.batchNumber == batchNumber).toList();

        // For sales, we need to check if any sale items match products from this batch
        // Since each batch has only one product, we match by product name from the batch
        final batchProductName = _farmToDryingRecords.isNotEmpty ? _farmToDryingRecords.first.productName : '';

        _salesRecords = salesRecords.where((sale) {
          return sale.items.any((item) => item.productName == batchProductName);
        }).toList();

        _isLoadingWorkflow = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWorkflow = false;
      });
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل بيانات الدفعة: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.indigo,
                        Colors.indigo.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timeline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تتبع مسار الدفعات',
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        'تابع رحلة المنتج من المزرعة إلى البيع',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isLoading && _batchNumbers.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _showBatchWorkflowDetails(),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('عرض التفاصيل'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.indigo,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Batch Selection
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_batchNumbers.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'لا توجد دفعات متاحة. قم بإضافة دفعة جديدة أولاً.',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Batch Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBatch,
                decoration: InputDecoration(
                  labelText: 'اختر الدفعة',
                  prefixIcon: const Icon(Icons.batch_prediction),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _batchNumbers
                    .map((batch) => DropdownMenuItem(
                          value: batch,
                          child: Text(batch),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBatch = value;
                  });
                  if (value != null) {
                    _loadBatchWorkflow(value);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Workflow Progress
              if (_isLoadingWorkflow)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_selectedBatch != null)
                _buildWorkflowProgress(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مسار الدفعة: $_selectedBatch',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Progress Steps
        Row(
          children: [
            _buildProgressStep(
              'المزرعة',
              Icons.agriculture,
              Colors.green,
              _farmToDryingRecords.isNotEmpty,
              true,
            ),
            Expanded(child: _buildProgressLine(_farmToDryingRecords.isNotEmpty)),
            _buildProgressStep(
              'التجفيف',
              Icons.local_fire_department,
              Colors.orange,
              _productsAfterDrying.isNotEmpty,
              _farmToDryingRecords.isNotEmpty,
            ),
            Expanded(child: _buildProgressLine(_productsAfterDrying.isNotEmpty)),
            _buildProgressStep(
              'التعبئة',
              Icons.inventory,
              Colors.blue,
              _finishedProducts.isNotEmpty,
              _productsAfterDrying.isNotEmpty,
            ),
            Expanded(child: _buildProgressLine(_finishedProducts.isNotEmpty)),
            _buildProgressStep(
              'البيع',
              Icons.point_of_sale,
              Colors.purple,
              _salesRecords.isNotEmpty,
              _finishedProducts.isNotEmpty,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick Summary
        _buildQuickSummary(),
      ],
    );
  }

  Widget _buildProgressStep(
    String label,
    IconData icon,
    Color color,
    bool isCompleted,
    bool isEnabled,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? color
                : isEnabled
                    ? color.withOpacity(0.3)
                    : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isEnabled ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isCompleted
                ? color
                : isEnabled
                    ? color.withOpacity(0.7)
                    : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildQuickSummary() {
    // Calculate totals
    double totalInputWeight = _farmToDryingRecords.fold(
      0.0,
      (sum, record) => sum + (record.totalWeightBeforeDrying ?? 0.0),
    );

    double totalOutputWeight = _productsAfterDrying.fold(
      0.0,
      (sum, record) => sum + record.totalGeneratedWeight,
    );

    int totalPackages = _finishedProducts.fold(
      0,
      (sum, record) => sum + record.quantity,
    );

    double totalRevenue = _salesRecords.fold(
      0.0,
      (sum, record) => sum + record.totalAmount,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.indigo.shade700, size: 16),
              const SizedBox(width: 8),
              Text(
                'ملخص الدفعة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.indigo.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'الوزن المدخل',
                  '${totalInputWeight.toStringAsFixed(1)} كجم',
                  Icons.input,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'بعد التجفيف',
                  '${totalOutputWeight.toStringAsFixed(1)} كجم',
                  Icons.output,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'العبوات المنتجة',
                  '$totalPackages عبوة',
                  Icons.inventory_2,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'الإيرادات',
                  '${totalRevenue.toStringAsFixed(0)} ج.س',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.indigo.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.indigo.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBatchWorkflowDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _buildDetailedWorkflow(scrollController),
      ),
    );
  }

  Widget _buildDetailedWorkflow(ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'تفاصيل مسار الدفعة: $_selectedBatch',
                  style: AppTextStyles.heading2,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Detailed workflow
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                _buildDetailedStage(
                  'المزرعة إلى التجفيف',
                  Icons.agriculture,
                  Colors.green,
                  _farmToDryingRecords.isNotEmpty,
                  _buildFarmToDryingDetails(),
                ),
                _buildDetailedStage(
                  'المنتجات بعد التجفيف',
                  Icons.local_fire_department,
                  Colors.orange,
                  _productsAfterDrying.isNotEmpty,
                  _buildProductsAfterDryingDetails(),
                ),
                _buildDetailedStage(
                  'المنتجات المُعبأة',
                  Icons.inventory,
                  Colors.blue,
                  _finishedProducts.isNotEmpty,
                  _buildFinishedProductsDetails(),
                ),
                _buildDetailedStage(
                  'المبيعات',
                  Icons.point_of_sale,
                  Colors.purple,
                  _salesRecords.isNotEmpty,
                  _buildSalesDetails(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStage(
    String title,
    IconData icon,
    Color color,
    bool isCompleted,
    Widget content,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 1,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted ? color.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: isCompleted ? color : Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? color : Colors.grey,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCompleted ? 'مُكتمل' : 'غير مُكتمل',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.all(12),
                child: content,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmToDryingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _farmToDryingRecords
          .map((record) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.productName,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'المورد: ${record.supplierName ?? "غير محدد"}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${record.totalWeightBeforeDrying} كجم',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildProductsAfterDryingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _productsAfterDrying
          .map((record) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'المنتجات بعد التجفيف',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${record.totalGeneratedWeight} كجم',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildFinishedProductsDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _finishedProducts
          .map((record) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'عبوات منتجة',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${record.quantity} عبوة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSalesDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _salesRecords
          .map((record) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.buyerName,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${record.items.length} صنف',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${record.totalAmount.toStringAsFixed(0)} ج.س',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
