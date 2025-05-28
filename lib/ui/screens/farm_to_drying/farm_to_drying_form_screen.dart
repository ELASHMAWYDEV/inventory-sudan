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

  // Dynamic lists that can be expanded
  List<String> _productNames = ['فول سوداني', 'سمسم', 'ذرة'];
  List<String> _purchaseLocations = ['الخرطوم', 'كسلا', 'الجزيرة', 'سنار'];
  List<String> _supplierNames = ['محمد أحمد', 'علي محمد', 'فاطمة عبدالله'];

  final List<String> _productTypes = ['خام', 'مجفف'];

  // Controllers for cost calculation
  final TextEditingController _productCostController = TextEditingController();
  final TextEditingController _logisticsCostController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productCostController.addListener(_calculateTotalCost);
    _logisticsCostController.addListener(_calculateTotalCost);
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
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final formData = _formKey.currentState!.value;

        final productCost = double.tryParse(_productCostController.text) ?? 0.0;
        final logisticsCost = double.tryParse(_logisticsCostController.text) ?? 0.0;
        final totalCost = productCost + logisticsCost;

        // Convert form data to the format expected by the service
        final data = {
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
          'تم إضافة المنتج بنجاح',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد'),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FormBuilderDropdown<String>(
              name: 'productType',
              decoration: const InputDecoration(
                labelText: 'نوع المنتج',
                prefixIcon: Icon(Icons.category),
              ),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
              items: _productTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
            ),
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
