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

  // List for empty packages
  List<EmptyPackagesInventoryModel> _emptyPackages = [];
  bool _isLoadingPackages = true;

  @override
  void initState() {
    super.initState();
    _loadEmptyPackages();
  }

  Future<void> _loadEmptyPackages() async {
    try {
      final packages = await _dataService.getEmptyPackagesInventory();
      setState(() {
        _emptyPackages = packages.where((pkg) => pkg.stock > 0).toList(); // Only show packages with stock
        _isLoadingPackages = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPackages = false;
      });
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل العبوات الفارغة: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final formData = _formKey.currentState!.value;

        final finishedProducts = FinishedProductsModel(
          batchNumber: formData['batchNumber'],
          emptyPackageId: formData['emptyPackageId'],
          quantity: int.parse(formData['quantity'].toString()),
          notes: formData['notes'],
          createdBy: 'current_user', // Replace with actual user
          createdAt: DateTime.now(),
        );

        // Add to database and deduct from empty packages stock
        await _dataService.addFinishedProducts(finishedProducts);
        await _dataService.deductEmptyPackagesStock(formData['emptyPackageId'], finishedProducts.quantity);

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

            // Empty Packages Dropdown
            if (_isLoadingPackages)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_emptyPackages.isEmpty)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'لا توجد عبوات فارغة متاحة. يرجى إضافة عبوات فارغة أولاً.',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              FormBuilderDropdown<String>(
                name: 'emptyPackageId',
                decoration: const InputDecoration(
                  labelText: 'العبوة الفارغة المراد خصمها',
                  prefixIcon: Icon(Icons.inventory_2),
                  border: OutlineInputBorder(),
                  helperText: 'اختر نوع العبوة الفارغة التي سيتم خصمها من المخزون',
                ),
                validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                selectedItemBuilder: (BuildContext context) {
                  return _emptyPackages.map<Widget>((package) {
                    return Text(
                      '${package.productName} - ${package.packageType} (${package.stock})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    );
                  }).toList();
                },
                items: _emptyPackages
                    .map((package) => DropdownMenuItem(
                          value: package.id,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${package.productName} - ${package.packageType}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'الوزن: ${package.packageWeight} ${package.weightUnit} | المخزون: ${package.stock}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  _formKey.currentState?.fields['emptyPackageId']?.didChange(value);
                  // Update max quantity based on selected package
                  final selectedPackage = _emptyPackages.firstWhere((pkg) => pkg.id == value);
                  final quantityField = _formKey.currentState?.fields['quantity'];
                  if (quantityField != null && quantityField.value != null) {
                    final currentQuantity = int.tryParse(quantityField.value.toString()) ?? 0;
                    if (currentQuantity > selectedPackage.stock) {
                      quantityField.didChange('');
                      Get.snackbar(
                        'تنبيه',
                        'الكمية المدخلة تتجاوز المخزون المتاح (${selectedPackage.stock})',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                    }
                  }
                },
              ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'quantity',
              decoration: const InputDecoration(
                labelText: 'الكمية (سيتم خصمها من العبوة المختارة)',
                prefixIcon: Icon(Icons.production_quantity_limits),
                border: OutlineInputBorder(),
                helperText: 'هذه الكمية سيتم خصمها تلقائياً من مخزون العبوة الفارغة المختارة',
              ),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                FormBuilderValidators.min(1, errorText: 'يجب أن يكون الرقم أكبر من صفر'),
                (value) {
                  if (value == null || value.isEmpty) return null;
                  final quantity = int.tryParse(value.toString());
                  if (quantity == null) return 'يجب إدخال رقم صحيح';

                  final emptyPackageId = _formKey.currentState?.fields['emptyPackageId']?.value;
                  if (emptyPackageId != null) {
                    final selectedPackage = _emptyPackages.firstWhere((pkg) => pkg.id == emptyPackageId);
                    if (quantity > selectedPackage.stock) {
                      return 'الكمية تتجاوز المخزون المتاح (${selectedPackage.stock})';
                    }
                  }
                  return null;
                },
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
                        'ملاحظة: عند حفظ هذا النموذج، سيتم خصم الكمية المحددة تلقائياً من مخزون العبوة الفارغة المختارة. تأكد من اختيار العبوة الصحيحة.',
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
