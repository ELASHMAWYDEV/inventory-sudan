import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/models/sales_model.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_text_field.dart';
import 'package:inventory_sudan/ui/widgets/common/dynamic_dropdown_widget.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class SalesFormScreen extends StatefulWidget {
  const SalesFormScreen({super.key});

  @override
  State<SalesFormScreen> createState() => _SalesFormScreenState();
}

class _SalesFormScreenState extends State<SalesFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _dataService = serviceLocator<DataService>();
  bool _isLoading = false;

  // Dynamic lists
  List<String> _productNames = ['فول سوداني', 'سمسم', 'ذرة'];
  List<String> _buyerNames = [];
  List<String> _buyerLocations = [];

  final List<String> _buyerTypes = ['Supermarket', 'Individual', 'Online Client'];
  final List<String> _packageTypes = ['B2B', 'B2C'];

  // Sale items list
  List<SaleItem> _saleItems = [];

  @override
  void initState() {
    super.initState();
    _updateBuyerOptions('Individual'); // Default buyer type
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateBuyerOptions(String buyerType) {
    setState(() {
      switch (buyerType) {
        case 'Supermarket':
          _buyerNames = ['كارفور', 'سبينيز', 'لولو هايبر ماركت', 'الراشد مول'];
          _buyerLocations = ['الخرطوم', 'الخرطوم بحري', 'أم درمان', 'مدني'];
          break;
        case 'Individual':
          _buyerNames = ['أحمد محمد', 'فاطمة علي', 'محمد عبدالله', 'عائشة أحمد'];
          _buyerLocations = ['الخرطوم', 'كسلا', 'بورتسودان', 'عطبرة'];
          break;
        case 'Online Client':
          _buyerNames = ['عميل أونلاين 1', 'عميل أونلاين 2', 'عميل أونلاين 3'];
          _buyerLocations = ['توصيل الخرطوم', 'توصيل الولايات', 'استلام من المخزن'];
          break;
        default:
          _buyerNames = [];
          _buyerLocations = [];
      }
    });
  }

  void _addSaleItem() {
    if (_formKey.currentState == null) return;

    if (_formKey.currentState?.fields['productName']?.value != null &&
        _formKey.currentState?.fields['packageType']?.value != null &&
        _formKey.currentState?.fields['quantityOfPackages']?.value != null &&
        _formKey.currentState?.fields['pricePerPackage']?.value != null) {
      final quantity = int.tryParse(_formKey.currentState?.fields['quantityOfPackages']?.value ?? '0') ?? 0;
      final price = double.tryParse(_formKey.currentState?.fields['pricePerPackage']?.value ?? '0.0') ?? 0.0;
      final totalPrice = quantity * price;

      final saleItem = SaleItem(
        productName: _formKey.currentState?.fields['productName']?.value ?? '',
        quantityOfPackages: quantity,
        pricePerPackage: price,
        packageType: _formKey.currentState?.fields['packageType']?.value ?? '',
        totalPrice: totalPrice,
      );

      setState(() {
        _saleItems.add(saleItem);
        _calculateTotalAmount();

        // Clear current item fields
        _formKey.currentState?.fields['productName']?.didChange(null);
        _formKey.currentState?.fields['packageType']?.didChange(null);
        _formKey.currentState?.fields['quantityOfPackages']?.didChange(null);
        _formKey.currentState?.fields['pricePerPackage']?.didChange(null);
      });
    } else {
      Get.snackbar(
        'خطأ',
        'يرجى ملء جميع حقول المنتج',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _removeSaleItem(int index) {
    setState(() {
      _saleItems.removeAt(index);
      _calculateTotalAmount();
    });
  }

  void _calculateTotalAmount() {
    if (_formKey.currentState == null) return;

    final total = _saleItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    _formKey.currentState?.fields['totalAmount']?.didChange(total.toStringAsFixed(2));
    _calculateRemainingAmount();
  }

  void _calculateRemainingAmount() {
    if (_formKey.currentState == null) return;

    final totalAmount = double.tryParse(_formKey.currentState?.fields['totalAmount']?.value ?? '0.0') ?? 0.0;
    final collectedAmount = double.tryParse(_formKey.currentState?.fields['collectedAmount']?.value ?? '0.0') ?? 0.0;
    final remainingAmount = totalAmount - collectedAmount;
    _formKey.currentState?.fields['remainingAmount']?.didChange(remainingAmount.toStringAsFixed(2));
  }

  void _fillFullAmount() {
    if (_formKey.currentState == null) return;

    _formKey.currentState?.fields['collectedAmount']?.didChange(_formKey.currentState?.fields['totalAmount']?.value);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (_saleItems.isEmpty) {
        Get.snackbar(
          'خطأ',
          'يرجى إضافة منتج واحد على الأقل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final formData = _formKey.currentState?.value;

        if (formData == null) {
          throw Exception('Form data is null');
        }

        final totalAmount = double.tryParse(formData['totalAmount'] ?? '0.0') ?? 0.0;
        final collectedAmount = double.tryParse(formData['collectedAmount'] ?? '0.0') ?? 0.0;
        final remainingAmount = totalAmount - collectedAmount;

        String paymentStatus;
        if (collectedAmount >= totalAmount) {
          paymentStatus = 'paid';
        } else if (collectedAmount > 0) {
          paymentStatus = 'partial';
        } else {
          paymentStatus = 'unpaid';
        }

        final salesModel = SalesModel(
          saleDate: formData['saleDate'] ?? DateTime.now(),
          items: _saleItems,
          buyerType: formData['buyerType'],
          buyerName: formData['buyerName'],
          buyerLocation: formData['buyerLocation'],
          totalAmount: totalAmount,
          collectedAmount: collectedAmount,
          remainingAmount: remainingAmount,
          paymentStatus: paymentStatus,
          notes: formData['notes'],
          createdBy: 'current_user', // Replace with actual user
          createdAt: DateTime.now(),
        );

        // Add to database
        await _dataService.addSale(salesModel);

        Get.back();
        Get.snackbar(
          'نجاح',
          'تم إضافة عملية البيع بنجاح',
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
        title: const Text('إضافة عملية بيع'),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FormBuilderDateTimePicker(
              name: 'saleDate',
              inputType: InputType.date,
              format: DateFormat('yyyy-MM-dd'),
              decoration: const InputDecoration(
                labelText: 'تاريخ البيع',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              initialValue: DateTime.now(),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
            ),
            const SizedBox(height: 16),

            // Products Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إضافة المنتجات',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Product Selection
                    DynamicDropdownWidget(
                      name: 'productName',
                      label: 'اسم المنتج',
                      options: _productNames,
                      prefixIcon: Icons.inventory,
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

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            name: 'quantityOfPackages',
                            label: 'عدد العبوات',
                            prefixIcon: Icon(Icons.numbers),
                            keyboardType: TextInputType.number,
                            validators: [
                              FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                              FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            name: 'pricePerPackage',
                            label: 'سعر العبوة',
                            prefixIcon: Icon(Icons.attach_money),
                            keyboardType: TextInputType.number,
                            validators: [
                              FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                              FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    FormBuilderDropdown<String>(
                      name: 'packageType',
                      decoration: const InputDecoration(
                        labelText: 'نوع العبوة',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _packageTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        _formKey.currentState?.fields['packageType']?.didChange(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _addSaleItem,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة المنتج'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sale Items List
            if (_saleItems.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المنتجات المضافة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _saleItems.length,
                        itemBuilder: (context, index) {
                          final item = _saleItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.productName),
                              subtitle: Text(
                                '${item.quantityOfPackages} عبوة × ${item.pricePerPackage} = ${item.totalPrice}\n'
                                'نوع العبوة: ${item.packageType}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeSaleItem(index),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Buyer Information
            FormBuilderDropdown<String>(
              name: 'buyerType',
              decoration: const InputDecoration(
                labelText: 'نوع المشتري',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
              items: _buyerTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateBuyerOptions(value);
                  // Clear buyer name and location when type changes
                  _formKey.currentState?.fields['buyerName']?.didChange(null);
                  _formKey.currentState?.fields['buyerLocation']?.didChange(null);
                }
              },
            ),
            const SizedBox(height: 16),

            // Dynamic Buyer Name Dropdown
            DynamicDropdownWidget(
              name: 'buyerName',
              label: 'اسم المشتري',
              options: _buyerNames,
              prefixIcon: Icons.person,
              isRequired: true,
              onChanged: (value) {
                _formKey.currentState?.fields['buyerName']?.didChange(value);
              },
              onNewOptionAdded: (newOption) {
                setState(() {
                  _buyerNames.add(newOption);
                });
              },
            ),
            const SizedBox(height: 16),

            // Dynamic Buyer Location Dropdown
            DynamicDropdownWidget(
              name: 'buyerLocation',
              label: 'موقع المشتري',
              options: _buyerLocations,
              prefixIcon: Icons.location_on,
              isRequired: true,
              onChanged: (value) {
                _formKey.currentState?.fields['buyerLocation']?.didChange(value);
              },
              onNewOptionAdded: (newOption) {
                setState(() {
                  _buyerLocations.add(newOption);
                });
              },
            ),
            const SizedBox(height: 16),

            // Amount Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المبالغ المالية',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Total Amount (Read-only)
                    CustomTextField(
                      name: 'totalAmount',
                      label: 'إجمالي المبلغ',
                      prefixIcon: const Icon(Icons.calculate),
                      readOnly: true,
                      validators: [
                        FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                        FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Collected Amount
                    CustomTextField(
                      name: 'collectedAmount',
                      label: 'المبلغ المحصل',
                      prefixIcon: const Icon(Icons.payments),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateRemainingAmount(),
                      validators: [
                        FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                        FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fillFullAmount,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('المبلغ كاملاً'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Remaining Amount (Read-only)
                    CustomTextField(
                      name: 'remainingAmount',
                      label: 'المبلغ المتبقي',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      readOnly: true,
                      validators: [
                        FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                        FormBuilderValidators.numeric(errorText: 'يجب إدخال رقم'),
                      ],
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
              label: 'حفظ عملية البيع',
              onPressed: _handleSubmit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
