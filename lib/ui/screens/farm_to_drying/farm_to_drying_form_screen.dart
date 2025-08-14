import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/ui/widgets/common/dynamic_dropdown_widget.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class FarmToDryingFormScreen extends StatefulWidget {
  const FarmToDryingFormScreen({super.key});

  @override
  State<FarmToDryingFormScreen> createState() => _FarmToDryingFormScreenState();
}

class _FarmToDryingFormScreenState extends State<FarmToDryingFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _dataService = serviceLocator<DataService>();
  bool _isLoading = false;
  bool _isLoadingBatchData = true;

  // Dynamic lists that can be expanded
  List<String> _productNames = ['فول سوداني', 'سمسم', 'ذرة'];
  List<String> _purchaseLocations = ['الخرطوم', 'كسلا', 'الجزيرة', 'سنار'];
  List<String> _supplierNames = ['محمد أحمد', 'علي محمد', 'فاطمة عبدالله'];

  // Batch management
  List<String> _existingBatchNumbers = [];
  String? _selectedBatchNumber;
  bool _createNewBatch = true;

  // Controllers for cost calculation
  final TextEditingController _productCostController = TextEditingController();
  final TextEditingController _logisticsCostController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productCostController.addListener(_calculateTotalCost);
    _logisticsCostController.addListener(_calculateTotalCost);
    _loadBatchData();
  }

  Future<void> _loadBatchData() async {
    try {
      final existingBatches = await _dataService.getExistingBatchNumbers();
      setState(() {
        _existingBatchNumbers = existingBatches;
        _isLoadingBatchData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBatchData = false;
      });
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل بيانات الدفعات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _productCostController.dispose();
    _logisticsCostController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  void _calculateTotalCost() {
    final productCost = double.tryParse(_productCostController.text) ?? 0.0;
    final logisticsCost = double.tryParse(_logisticsCostController.text) ?? 0.0;
    final totalCost = productCost + logisticsCost;
    _totalCostController.text = totalCost.toStringAsFixed(2);
  }

  Future<void> _submitForm() async {
    // Validate batch selection first
    if (!_createNewBatch && (_selectedBatchNumber == null || _selectedBatchNumber!.isEmpty)) {
      Get.snackbar(
        'خطأ في التحقق',
        'يرجى اختيار دفعة موجودة أو إنشاء دفعة جديدة',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final formData = _formKey.currentState!.value;

        final productCost = double.tryParse(_productCostController.text) ?? 0.0;
        final logisticsCost = double.tryParse(_logisticsCostController.text) ?? 0.0;
        final totalCost = productCost + logisticsCost;

        // Determine batch number
        String batchNumber;
        if (_createNewBatch) {
          batchNumber = await _dataService.generateNewBatchNumber();
        } else {
          batchNumber = _selectedBatchNumber ?? await _dataService.generateNewBatchNumber();
        }

        // Convert form data to the format expected by the service
        final data = {
          'batchNumber': batchNumber,
          'productName': formData['productName'],
          'productType': formData['productType'],
          'purchaseDate': (formData['purchaseDate'] as DateTime).toIso8601String(),
          'sackCount': int.parse(formData['quantity'].toString()),
          'totalWeightBeforeDrying': double.parse(formData['wholeWeight'].toString()),
          'purchaseLocation': formData['purchaseLocation'],
          'supplierName': formData['supplierName'],
          'productCost': productCost,
          'logisticsCost': logisticsCost,
          'totalCosts': totalCost,
          'notes': formData['notes'],
          'createdAt': DateTime.now().toIso8601String(),
        };

        await _dataService.addFarmToDryingRecord(FarmToDryingModel.fromMap(data));
        Get.back();
        Get.snackbar(
          'نجاح',
          'تم إضافة المنتج بنجاح للدفعة: $batchNumber',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء حفظ البيانات: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSubmit() {
    if (!_isLoading) {
      _submitForm();
    }
  }

  Widget _buildBatchSelectionWidget() {
    if (_isLoadingBatchData) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('جاري تحميل بيانات الدفعات...'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.batch_prediction, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'إدارة الدفعة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('إنشاء دفعة جديدة'),
                    value: true,
                    groupValue: _createNewBatch,
                    onChanged: (value) {
                      setState(() {
                        _createNewBatch = value ?? true;
                        if (_createNewBatch) {
                          _selectedBatchNumber = null;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_existingBatchNumbers.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('إضافة لدفعة موجودة'),
                      value: false,
                      groupValue: _createNewBatch,
                      onChanged: (value) {
                        setState(() {
                          _createNewBatch = value ?? true;
                          if (!_createNewBatch && _existingBatchNumbers.isNotEmpty) {
                            _selectedBatchNumber = _existingBatchNumbers.first;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            if (!_createNewBatch && _existingBatchNumbers.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBatchNumber,
                decoration: const InputDecoration(
                  labelText: 'اختر الدفعة',
                  prefixIcon: Icon(Icons.list),
                  border: OutlineInputBorder(),
                ),
                items: _existingBatchNumbers
                    .map((batch) => DropdownMenuItem(
                          value: batch,
                          child: Text(batch),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBatchNumber = value;
                  });
                },
                validator: (value) {
                  if (!_createNewBatch && (value == null || value.isEmpty)) {
                    return 'يرجى اختيار دفعة';
                  }
                  return null;
                },
              ),
            ],
            if (_createNewBatch) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم إنشاء رقم دفعة جديد تلقائياً',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اضافة دفعة جديدة'),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Batch Selection Widget
            _buildBatchSelectionWidget(),
            const SizedBox(height: 16),

            // Dynamic Product Name Dropdown
            DynamicDropdownWidget(
              name: 'productName',
              label: 'اسم المنتج',
              options: _productNames,
              prefixIcon: Icons.inventory,
              isRequired: true,
              onChanged: (value) {
                _formKey.currentState?.fields['productName']?.didChange(value);
              },
              onNewOptionAdded: (newOption) {
                setState(() {
                  _productNames.add(newOption);
                });
              },
            ),
            const SizedBox(height: 16),

            FormBuilderDateTimePicker(
              name: 'purchaseDate',
              inputType: InputType.date,
              format: DateFormat('yyyy-MM-dd'),
              decoration: const InputDecoration(
                labelText: 'تاريخ الشراء',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
            ),
            const SizedBox(height: 16),

            // Dynamic Purchase Location Dropdown
            DynamicDropdownWidget(
              name: 'purchaseLocation',
              label: 'مكان الشراء',
              options: _purchaseLocations,
              prefixIcon: Icons.location_on,
              isRequired: true,
              onChanged: (value) {
                _formKey.currentState?.fields['purchaseLocation']?.didChange(value);
              },
              onNewOptionAdded: (newOption) {
                setState(() {
                  _purchaseLocations.add(newOption);
                });
              },
            ),
            const SizedBox(height: 16),

            // Dynamic Supplier Name Dropdown
            DynamicDropdownWidget(
              name: 'supplierName',
              label: 'اسم المورد',
              options: _supplierNames,
              prefixIcon: Icons.person,
              isRequired: true,
              onChanged: (value) {
                _formKey.currentState?.fields['supplierName']?.didChange(value);
              },
              onNewOptionAdded: (newOption) {
                setState(() {
                  _supplierNames.add(newOption);
                });
              },
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'quantity',
              decoration: const InputDecoration(
                labelText: 'عدد الأكياس',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
              ]),
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'wholeWeight',
              decoration: const InputDecoration(
                labelText: 'الوزن الكلي (كجم)',
                prefixIcon: Icon(Icons.scale),
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
              ]),
            ),
            const SizedBox(height: 16),

            // Product Cost Field
            TextFormField(
              controller: _productCostController,
              decoration: const InputDecoration(
                labelText: 'تكلفة المنتج',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'هذا الحقل مطلوب';
                }
                if (double.tryParse(value) == null) {
                  return 'يجب إدخال رقم صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Logistics Cost Field
            TextFormField(
              controller: _logisticsCostController,
              decoration: const InputDecoration(
                labelText: 'تكلفة اللوجستيات',
                prefixIcon: Icon(Icons.local_shipping),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                  return 'يجب إدخال رقم صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Total Cost Display (Read-only)
            TextFormField(
              controller: _totalCostController,
              decoration: const InputDecoration(
                labelText: 'إجمالي التكلفة',
                prefixIcon: Icon(Icons.calculate),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Notes Field
            FormBuilderTextField(
              name: 'notes',
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            CustomButton(
              label: 'حفظ',
              onPressed: _handleSubmit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
