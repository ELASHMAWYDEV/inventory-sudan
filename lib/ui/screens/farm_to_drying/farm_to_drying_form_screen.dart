import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
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

  final List<String> _productTypes = ['خام', 'مجفف'];
  final List<String> _productNames = ['فول سوداني', 'سمسم', 'ذرة'];
  final List<String> _quantityUnits = ['شوال', 'كيلوجرام', 'طن'];

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final formData = _formKey.currentState!.value;

        // Convert form data to the format expected by the service
        final data = {
          'productName': formData['productName'],
          'productType': formData['productType'],
          'purchaseDate': (formData['purchaseDate'] as DateTime).toIso8601String(),
          'quantity': int.parse(formData['quantity'].toString()),
          'quantityUnit': formData['quantityUnit'],
          'wholeWeight': double.parse(formData['wholeWeight'].toString()),
          'purchaseLocation': formData['purchaseLocation'],
          'supplierName': formData['supplierName'],
          'totalCosts': double.parse(formData['totalCosts'].toString()),
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
            FormBuilderDropdown<String>(
              name: 'productName',
              decoration: const InputDecoration(
                labelText: 'اسم المنتج',
              ),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
              items: _productNames
                  .map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            FormBuilderDateTimePicker(
              name: 'purchaseDate',
              inputType: InputType.date,
              format: DateFormat('yyyy-MM-dd'),
              decoration: const InputDecoration(
                labelText: 'تاريخ الشراء',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'quantity',
              decoration: const InputDecoration(
                labelText: 'الكمية',
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
              ]),
            ),
            const SizedBox(height: 16),
            FormBuilderDropdown<String>(
              name: 'quantityUnit',
              decoration: const InputDecoration(
                labelText: 'وحدة القياس',
              ),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
              items: _quantityUnits
                  .map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'wholeWeight',
              decoration: const InputDecoration(
                labelText: 'الوزن الكلي (كجم)',
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
              ]),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'purchaseLocation',
              decoration: const InputDecoration(
                labelText: 'مكان الشراء',
              ),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'supplierName',
              decoration: const InputDecoration(
                labelText: 'اسم المورد',
              ),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'totalCosts',
              decoration: const InputDecoration(
                labelText: 'التكاليف الكلية',
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
              ]),
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
