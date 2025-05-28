import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/ui/widgets/common/dynamic_dropdown_widget.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FinishedProductsFormScreen extends StatefulWidget {
  const FinishedProductsFormScreen({super.key});

  @override
  State<FinishedProductsFormScreen> createState() => _FinishedProductsFormScreenState();
}

class _FinishedProductsFormScreenState extends State<FinishedProductsFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _dataService = serviceLocator<DataService>();
  bool _isLoading = false;

  // Dynamic list for batch numbers
  List<String> _batchNumbers = ['Batch-001', 'Batch-002', 'Batch-003'];

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final formData = _formKey.currentState!.value;

        final finishedProducts = FinishedProductsModel(
          batchNumber: formData['batchNumber'],
          quantity: int.parse(formData['quantity'].toString()),
          notes: formData['notes'],
          createdBy: 'current_user', // Replace with actual user
          createdAt: DateTime.now(),
        );

        // Add to database and deduct from empty packages stock
        await _dataService.addFinishedProducts(finishedProducts);
        await _dataService.deductEmptyPackagesStock(formData['batchNumber'], finishedProducts.quantity);

        Get.back();
        Get.snackbar(
          'نجاح',
          'تم إضافة المنتجات المُعبأة بنجاح وتم خصم الكمية من مخزون العبوات الفارغة',
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
        title: const Text('المنتجات المُعبأة'),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Dynamic Batch Number Dropdown
            DynamicDropdownWidget(
              name: 'batchNumber',
              label: 'رقم الدفعة',
              options: _batchNumbers,
              prefixIcon: Icons.batch_prediction,
              isRequired: true,
              onChanged: (value) {
                _formKey.currentState?.fields['batchNumber']?.didChange(value);
              },
              onNewOptionAdded: (newOption) {
                setState(() {
                  _batchNumbers.add(newOption);
                });
              },
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'quantity',
              decoration: const InputDecoration(
                labelText: 'الكمية (سيتم خصمها من مخزون العبوات الفارغة)',
                prefixIcon: Icon(Icons.production_quantity_limits),
                border: OutlineInputBorder(),
                helperText: 'هذه الكمية سيتم خصمها تلقائياً من مخزون العبوات الفارغة للمنتج المحدد',
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                FormBuilderValidators.min(1, errorText: 'يجب أن يكون الرقم أكبر من صفر'),
              ]),
            ),
            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ملاحظة: عند حفظ هذا النموذج، سيتم خصم الكمية المحددة تلقائياً من مخزون العبوات الفارغة للمنتج المرتبط برقم الدفعة المحدد.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              label: 'حفظ وخصم من المخزون',
              onPressed: _handleSubmit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
