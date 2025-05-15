import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class PackagingFormScreen extends StatefulWidget {
  const PackagingFormScreen({Key? key}) : super(key: key);

  @override
  State<PackagingFormScreen> createState() => _PackagingFormScreenState();
}

class _PackagingFormScreenState extends State<PackagingFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _dataService = serviceLocator<DataService>();
  bool _isLoading = false;

  // Counters for dynamic form fields
  int _rawMaterialsCount = 1;
  int _packagedProductsCount = 1;
  int _emptyPackagesCount = 1;

  void _addRawMaterial() {
    setState(() {
      _rawMaterialsCount++;
    });
  }

  void _removeRawMaterial() {
    if (_rawMaterialsCount > 1) {
      setState(() {
        _rawMaterialsCount--;
      });
    }
  }

  void _addPackagedProduct() {
    setState(() {
      _packagedProductsCount++;
    });
  }

  void _removePackagedProduct() {
    if (_packagedProductsCount > 1) {
      setState(() {
        _packagedProductsCount--;
      });
    }
  }

  void _addEmptyPackage() {
    setState(() {
      _emptyPackagesCount++;
    });
  }

  void _removeEmptyPackage() {
    if (_emptyPackagesCount > 1) {
      setState(() {
        _emptyPackagesCount--;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final formValues = _formKey.currentState!.value;

        // Create raw materials list
        final rawMaterials = List.generate(_rawMaterialsCount, (index) {
          return {
            'name': formValues['raw_material_name_$index']?.toString() ?? '',
            'quantity': int.tryParse(formValues['raw_material_weight_$index']?.toString() ?? '0') ?? 0,
            'weight': double.tryParse(formValues['raw_material_weight_$index']?.toString() ?? '0') ?? 0.0,
          };
        });

        // Create packaged products list
        final packagedProducts = List.generate(_packagedProductsCount, (index) {
          return {
            'name': formValues['packaged_product_name_$index']?.toString() ?? '',
            'quantity': int.tryParse(formValues['packaged_product_count_$index']?.toString() ?? '0') ?? 0,
            'weight': double.tryParse(formValues['packaged_product_weight_$index']?.toString() ?? '0') ?? 0.0,
          };
        });

        // Create empty packages list
        final emptyPackages = List.generate(_emptyPackagesCount, (index) {
          return {
            'type': formValues['empty_package_type_$index']?.toString() ?? '',
            'size': formValues['empty_package_size_$index']?.toString() ?? '',
            'quantity': int.tryParse(formValues['empty_package_count_$index']?.toString() ?? '0') ?? 0,
          };
        });

        // Create data object for service
        final data = {
          'inventoryDate': DateTime.now().toIso8601String(),
          'rawMaterials': rawMaterials,
          'packagedProducts': packagedProducts,
          'emptyPackages': emptyPackages,
          'notes': formValues['notes']?.toString() ?? '',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await _dataService.addPackagingRecord(PackagingModel.fromMap(data));
        Get.back();
        Get.snackbar(
          'نجاح',
          'تم إضافة التعبئة بنجاح',
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
        title: const Text('تعبئة جديدة'),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Raw Materials Section
            Text(
              'المواد الخام',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            ...List.generate(_rawMaterialsCount, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'raw_material_name_$index',
                        decoration: const InputDecoration(
                          labelText: 'اسم المادة الخام',
                        ),
                        validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'raw_material_weight_$index',
                        decoration: const InputDecoration(
                          labelText: 'الوزن (كجم)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                          FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            }),
            CustomButton(
              label: 'إضافة مادة خام',
              onPressed: _addRawMaterial,
              icon: Icons.add,
            ),
            const SizedBox(height: 32),

            // Packaged Products Section
            Text(
              'المنتجات المعبأة',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            ...List.generate(_packagedProductsCount, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'packaged_product_name_$index',
                        decoration: const InputDecoration(
                          labelText: 'اسم المنتج',
                        ),
                        validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'packaged_product_count_$index',
                        decoration: const InputDecoration(
                          labelText: 'العدد',
                        ),
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                          FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'packaged_product_weight_$index',
                        decoration: const InputDecoration(
                          labelText: 'الوزن (كجم)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                          FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            }),
            CustomButton(
              label: 'إضافة منتج',
              onPressed: _addPackagedProduct,
              icon: Icons.add,
            ),
            const SizedBox(height: 32),

            // Empty Packages Section
            Text(
              'العبوات الفارغة',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            ...List.generate(_emptyPackagesCount, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'empty_package_type_$index',
                        decoration: const InputDecoration(
                          labelText: 'نوع العبوة',
                        ),
                        validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'empty_package_size_$index',
                        decoration: const InputDecoration(
                          labelText: 'حجم العبوة',
                        ),
                        validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'empty_package_count_$index',
                        decoration: const InputDecoration(
                          labelText: 'العدد',
                        ),
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                          FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            }),
            CustomButton(
              label: 'إضافة عبوات',
              onPressed: _addEmptyPackage,
              icon: Icons.add,
            ),
            const SizedBox(height: 32),

            // Notes Section
            FormBuilderTextField(
              name: 'notes',
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Submit Button
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
