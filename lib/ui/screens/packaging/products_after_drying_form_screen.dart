import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/ui/widgets/common/dynamic_dropdown_widget.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ProductsAfterDryingFormScreen extends StatefulWidget {
  const ProductsAfterDryingFormScreen({super.key});

  @override
  State<ProductsAfterDryingFormScreen> createState() => _ProductsAfterDryingFormScreenState();
}

class _ProductsAfterDryingFormScreenState extends State<ProductsAfterDryingFormScreen> {
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
        final productsAfterDrying = ProductsAfterDryingModel(
          batchNumber: formData['batchNumber'],
          totalGeneratedWeight: double.parse(formData['totalGeneratedWeight'].toString()),
          notes: formData['notes'],
          createdBy: 'current_user', // Replace with actual user
          createdAt: DateTime.now(),
        );

        // Add to database (you'll need to implement this in your data service)
        await _dataService.addProductsAfterDrying(productsAfterDrying);

        Get.back();
        Get.snackbar(
          'نجاح',
          'تم إضافة منتجات ما بعد التجفيف بنجاح',
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
        title: const Text('منتجات ما بعد التجفيف'),
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
              name: 'totalGeneratedWeight',
              decoration: const InputDecoration(
                labelText: 'إجمالي الوزن المُنتج (كجم)',
                prefixIcon: Icon(Icons.scale),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                FormBuilderValidators.min(0, errorText: 'يجب أن يكون الرقم أكبر من صفر'),
              ]),
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
