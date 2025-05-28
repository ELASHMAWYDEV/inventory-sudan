import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/ui/widgets/common/dynamic_dropdown_widget.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class EmptyPackagesInventoryFormScreen extends StatefulWidget {
  const EmptyPackagesInventoryFormScreen({super.key});

  @override
  State<EmptyPackagesInventoryFormScreen> createState() => _EmptyPackagesInventoryFormScreenState();
}

class _EmptyPackagesInventoryFormScreenState extends State<EmptyPackagesInventoryFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _dataService = serviceLocator<DataService>();
  bool _isLoading = false;

  // Dynamic lists
  List<String> _productNames = ['فول سوداني', 'سمسم', 'ذرة'];
  final List<String> _packageTypes = ['B2B Wholesale', 'B2C Retail'];
  final List<String> _weightUnits = ['kg', 'g'];

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final formData = _formKey.currentState!.value;

        final emptyPackagesInventory = EmptyPackagesInventoryModel(
          productName: formData['productName'],
          stock: int.parse(formData['stock'].toString()),
          totalCost: double.parse(formData['totalCost'].toString()),
          packageType: formData['packageType'],
          packageWeight: double.parse(formData['packageWeight'].toString()),
          weightUnit: formData['weightUnit'],
          notes: formData['notes'],
          createdBy: 'current_user', // Replace with actual user
          createdAt: DateTime.now(),
        );

        // Add to database (you'll need to implement this in your data service)
        await _dataService.addEmptyPackagesInventory(emptyPackagesInventory);

        Get.back();
        Get.snackbar(
          'نجاح',
          'تم إضافة مخزون العبوات الفارغة بنجاح',
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
        title: const Text('مخزون العبوات الفارغة'),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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

            FormBuilderTextField(
              name: 'stock',
              decoration: const InputDecoration(
                labelText: 'المخزون',
                prefixIcon: Icon(Icons.storage),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                FormBuilderValidators.min(0, errorText: 'يجب أن يكون الرقم أكبر من أو يساوي صفر'),
              ]),
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'totalCost',
              decoration: const InputDecoration(
                labelText: 'إجمالي التكلفة',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                FormBuilderValidators.min(0, errorText: 'يجب أن يكون الرقم أكبر من أو يساوي صفر'),
              ]),
            ),
            const SizedBox(height: 16),

            FormBuilderDropdown<String>(
              name: 'packageType',
              decoration: const InputDecoration(
                labelText: 'نوع العبوة',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
              items: _packageTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FormBuilderTextField(
                    name: 'packageWeight',
                    decoration: const InputDecoration(
                      labelText: 'وزن العبوة',
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: FormBuilderDropdown<String>(
                    name: 'weightUnit',
                    decoration: const InputDecoration(
                      labelText: 'الوحدة',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(errorText: 'مطلوب'),
                    items: _weightUnits
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ))
                        .toList(),
                    initialValue: 'kg',
                  ),
                ),
              ],
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
