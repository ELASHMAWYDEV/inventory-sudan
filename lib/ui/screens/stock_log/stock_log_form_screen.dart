import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sudan/controllers/auth/auth_controller.dart';
import 'package:inventory_sudan/models/stock_log_model.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/ui/widgets/common/dynamic_dropdown_widget.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';

class StockLogFormScreen extends StatefulWidget {
  const StockLogFormScreen({Key? key}) : super(key: key);

  @override
  State<StockLogFormScreen> createState() => _StockLogFormScreenState();
}

class _StockLogFormScreenState extends State<StockLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataService = serviceLocator<DataService>();
  final _authController = Get.find<AuthController>();

  DateTime _selectedDate = DateTime.now();
  final _notesController = TextEditingController();
  List<InventoryItemForm> _inventoryItems = [];
  List<File> _images = [];
  bool _isLoading = false;

  // Stock type from arguments
  String? _stockType;

  // Available products - filtered based on stock type
  List<String> _availableProducts = [];

  // All products data - in real app, this would come from product database
  final Map<String, Map<String, String>> _allProducts = {
    // Raw Materials
    'فول سوداني': {'unit': 'kg', 'type': 'raw_material'},
    'سمسم': {'unit': 'kg', 'type': 'raw_material'},
    'ذرة': {'unit': 'kg', 'type': 'raw_material'},
    'لوز': {'unit': 'kg', 'type': 'raw_material'},
    'كاجو': {'unit': 'kg', 'type': 'raw_material'},

    // Packaged Products
    'عبوة فول سوداني 500g': {'unit': 'count', 'type': 'packaged_product'},
    'عبوة سمسم 250g': {'unit': 'count', 'type': 'packaged_product'},
    'عبوة ذرة 1kg': {'unit': 'count', 'type': 'packaged_product'},
    'علبة لوز 200g': {'unit': 'count', 'type': 'packaged_product'},
    'كيس مكسرات مشكلة 500g': {'unit': 'count', 'type': 'packaged_product'},

    // Empty Packages
    'أكياس بلاستيك 250g': {'unit': 'count', 'type': 'empty_package'},
    'أكياس بلاستيك 500g': {'unit': 'count', 'type': 'empty_package'},
    'أكياس بلاستيك 1kg': {'unit': 'count', 'type': 'empty_package'},
    'علب بلاستيك صغيرة': {'unit': 'count', 'type': 'empty_package'},
    'علب بلاستيك كبيرة': {'unit': 'count', 'type': 'empty_package'},
    'صناديق كرتون صغيرة': {'unit': 'count', 'type': 'empty_package'},
    'صناديق كرتون كبيرة': {'unit': 'count', 'type': 'empty_package'},
  };

  @override
  void initState() {
    super.initState();
    _initializeStockType();
  }

  void _initializeStockType() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    _stockType = arguments?['stockType'] ?? 'raw_material';
    _loadProductsForStockType();
  }

  void _loadProductsForStockType() {
    _availableProducts =
        _allProducts.entries.where((entry) => entry.value['type'] == _stockType).map((entry) => entry.key).toList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final item in _inventoryItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addInventoryItem() {
    setState(() {
      _inventoryItems.add(
        InventoryItemForm(
          actualQuantityController: TextEditingController(),
          reasonController: TextEditingController(),
          selectedProduct: null,
          unit: null,
          itemType: null,
        ),
      );
    });
  }

  void _removeInventoryItem(int index) {
    setState(() {
      final item = _inventoryItems.removeAt(index);
      item.dispose();
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<bool> _hasDiscrepancies() async {
    // For each item, get expected quantity from the system and compare with actual
    for (final item in _inventoryItems) {
      if (item.selectedProduct != null) {
        final actualQuantity = double.tryParse(item.actualQuantityController.text) ?? 0;
        // In real app, get expected quantity from database based on product name
        final expectedQuantity = await _getExpectedQuantity(item.selectedProduct!);
        if (actualQuantity != expectedQuantity) {
          return true;
        }
      }
    }
    return false;
  }

  Future<double> _getExpectedQuantity(String productName) async {
    // TODO: Get expected quantity from system/database
    // For now, return a mock value
    switch (productName) {
      case 'فول سوداني':
        return 100.0;
      case 'سمسم':
        return 50.0;
      case 'ذرة':
        return 80.0;
      case 'عبوة فول سوداني 500g':
        return 200.0;
      case 'عبوة سمسم 250g':
        return 150.0;
      default:
        return 0.0;
    }
  }

  Future<void> _saveStockLog() async {
    if (!_formKey.currentState!.validate()) return;
    if (_inventoryItems.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إضافة منتج واحد على الأقل',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check if all items have products selected
    for (int i = 0; i < _inventoryItems.length; i++) {
      if (_inventoryItems[i].selectedProduct == null) {
        Get.snackbar(
          'خطأ',
          'يجب اختيار منتج للعنصر رقم ${i + 1}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate differences for items
      final itemsWithDifferences = <InventoryItem>[];

      for (final item in _inventoryItems) {
        if (item.selectedProduct != null) {
          final actualQuantity = double.tryParse(item.actualQuantityController.text) ?? 0;
          final expectedQuantity = await _getExpectedQuantity(item.selectedProduct!);
          final difference = actualQuantity - expectedQuantity;

          itemsWithDifferences.add(InventoryItem(
            itemName: item.selectedProduct!,
            itemType: item.itemType ?? 'raw_material',
            expectedQuantity: expectedQuantity,
            actualQuantity: actualQuantity,
            unit: item.unit,
            difference: difference,
            reason: item.reasonController.text.trim().isEmpty ? null : item.reasonController.text.trim(),
          ));
        }
      }

      // TODO: Upload images and get URLs
      final imageUrls = <String>[];

      final stockLog = StockLogModel(
        logDate: _selectedDate,
        inventoryItems: itemsWithDifferences,
        hasDiscrepancies: await _hasDiscrepancies(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        imageUrls: imageUrls.isEmpty ? null : imageUrls,
        createdBy: _authController.user?.name ?? 'Unknown',
        createdAt: DateTime.now(),
      );

      await _dataService.addStockLogRecord(stockLog);

      Get.snackbar(
        'نجح',
        'تم حفظ جرد المخزون بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ البيانات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getStockTypeTitle()),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Type Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getStockTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStockTypeIcon(),
                          color: _getStockTypeColor(),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStockTypeTitle(),
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStockTypeDescription(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات عامة',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تاريخ الجرد',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Inventory Items Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'منتجات الجرد',
                            style: AppTextStyles.heading3,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _addInventoryItem,
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة منتج'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_inventoryItems.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'لم يتم إضافة أي منتجات بعد',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'اضغط على "إضافة منتج" لبدء الجرد',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...List.generate(_inventoryItems.length, (index) {
                        return _buildInventoryItemCard(index);
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملاحظات',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'ملاحظات إضافية',
                          hintText: 'أدخل أي ملاحظات حول عملية الجرد...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Images Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الصور',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 16),
                      if (_images.isNotEmpty) ...[
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _images.length) {
                                return _buildAddImageButton();
                              }
                              return _buildImagePreview(index);
                            },
                          ),
                        ),
                      ] else
                        _buildAddImageButton(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              CustomButton(
                label: 'حفظ جرد المخزون',
                onPressed: _isLoading ? null : _saveStockLog,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryItemCard(int index) {
    final item = _inventoryItems[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with remove button
            Row(
              children: [
                Text(
                  'المنتج ${index + 1}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _removeInventoryItem(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'حذف المنتج',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Product Selection Dropdown
            DynamicDropdownWidget(
              name: 'product_${index}',
              label: 'اختر المنتج',
              options: _availableProducts,
              prefixIcon: Icons.inventory,
              isRequired: true,
              value: item.selectedProduct,
              onChanged: (productName) {
                setState(() {
                  item.selectedProduct = productName;
                  item.unit = _allProducts[productName]?['unit'];
                  item.itemType = _allProducts[productName]?['type'];
                });
              },
              onNewOptionAdded: (newProduct) {
                setState(() {
                  _availableProducts.add(newProduct);
                  // Set default values for new products based on current stock type
                  final defaultUnit = _stockType == 'raw_material' ? 'kg' : 'count';
                  _allProducts[newProduct] = {
                    'unit': defaultUnit,
                    'type': _stockType!,
                  };
                });
              },
            ),

            const SizedBox(height: 12),

            // Show unit (read-only)
            if (item.unit != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.straighten, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'الوحدة: ${_getUnitLabel(item.unit!)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Actual Quantity Input
            TextFormField(
              controller: item.actualQuantityController,
              decoration: InputDecoration(
                labelText: 'الكمية المتوفرة ${item.unit != null ? '(${_getUnitLabel(item.unit!)})' : ''}',
                hintText: 'أدخل الكمية التي عددتها فعلياً',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يجب إدخال الكمية المتوفرة';
                }
                if (double.tryParse(value) == null) {
                  return 'يجب إدخال رقم صحيح';
                }
                if (double.parse(value) < 0) {
                  return 'الكمية لا يمكن أن تكون سالبة';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Reason field (always shown for any comments)
            TextFormField(
              controller: item.reasonController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'أي ملاحظات حول هذا المنتج...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: _addImage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: Colors.grey.shade400),
            const SizedBox(height: 4),
            Text(
              'إضافة صورة',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _images[index],
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => _removeImage(index),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addImage() async {
    // Simple image picker implementation
    // In a real app, you would use ImagePickerWidget properly
    Get.snackbar(
      'معلومة',
      'سيتم إضافة الصور في النسخة القادمة',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  String _getUnitLabel(String unit) {
    switch (unit) {
      case 'kg':
        return 'كيلوجرام';
      case 'count':
        return 'عدد';
      case 'liter':
        return 'لتر';
      case 'box':
        return 'صندوق';
      default:
        return unit;
    }
  }

  String _getStockTypeTitle() {
    switch (_stockType) {
      case 'raw_material':
        return 'جرد المواد الخام';
      case 'packaged_product':
        return 'جرد المنتجات المُعبأة';
      case 'empty_package':
        return 'جرد العبوات الفارغة';
      default:
        return 'جرد مخزون جديد';
    }
  }

  String _getStockTypeDescription() {
    switch (_stockType) {
      case 'raw_material':
        return 'جرد المواد الخام مثل الفول السوداني والسمسم';
      case 'packaged_product':
        return 'جرد المنتجات الجاهزة للبيع';
      case 'empty_package':
        return 'جرد العبوات والأكياس الفارغة';
      default:
        return 'جرد المخزون';
    }
  }

  Color _getStockTypeColor() {
    switch (_stockType) {
      case 'raw_material':
        return Colors.green;
      case 'packaged_product':
        return Colors.blue;
      case 'empty_package':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStockTypeIcon() {
    switch (_stockType) {
      case 'raw_material':
        return Icons.grass;
      case 'packaged_product':
        return Icons.inventory;
      case 'empty_package':
        return Icons.inventory_2_outlined;
      default:
        return Icons.inventory_2;
    }
  }
}

class InventoryItemForm {
  final TextEditingController actualQuantityController;
  final TextEditingController reasonController;
  String? selectedProduct;
  String? unit;
  String? itemType;

  InventoryItemForm({
    required this.actualQuantityController,
    required this.reasonController,
    this.selectedProduct,
    this.unit,
    this.itemType,
  });

  void dispose() {
    actualQuantityController.dispose();
    reasonController.dispose();
  }
}
