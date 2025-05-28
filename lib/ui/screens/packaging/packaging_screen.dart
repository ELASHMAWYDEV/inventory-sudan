import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/utils/app_router.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:inventory_sudan/models/packaging_model.dart';
import 'package:intl/intl.dart';

class PackagingScreen extends StatefulWidget {
  const PackagingScreen({Key? key}) : super(key: key);

  @override
  State<PackagingScreen> createState() => _PackagingScreenState();
}

class _PackagingScreenState extends State<PackagingScreen> with SingleTickerProviderStateMixin {
  final _dataService = serviceLocator<DataService>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFormSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'اختر نوع النموذج',
              style: AppTextStyles.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Products after drying option
            _buildFormOption(
              title: 'منتجات ما بعد التجفيف',
              subtitle: 'رقم الدفعة وإجمالي الوزن المُنتج',
              icon: Icons.agriculture,
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(AppRouter.PACKAGING_PRODUCTS_AFTER_DRYING_FORM);
              },
            ),
            const SizedBox(height: 16),

            // Empty packages inventory option
            _buildFormOption(
              title: 'مخزون العبوات الفارغة',
              subtitle: 'اسم المنتج، المخزون، التكلفة، نوع العبوة',
              icon: Icons.inventory_2,
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(AppRouter.PACKAGING_EMPTY_PACKAGES_INVENTORY_FORM);
              },
            ),
            const SizedBox(height: 16),

            // Finished products option
            _buildFormOption(
              title: 'المنتجات المُعبأة',
              subtitle: 'رقم الدفعة والكمية (يخصم من المخزون)',
              icon: Icons.local_shipping,
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(AppRouter.PACKAGING_FINISHED_PRODUCTS_FORM);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsAfterDryingTab() {
    return StreamBuilder<List<ProductsAfterDryingModel>>(
      stream: _dataService.productsAfterDryingStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'حدث خطأ: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sunny,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد منتجات ما بعد التجفيف',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.green,
                  ),
                ),
                title: Text(
                  'دفعة: ${item.batchNumber}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الوزن: ${item.totalGeneratedWeight.toStringAsFixed(2)} كجم'),
                    Text(
                      DateFormat('yyyy-MM-dd').format(item.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing:
                    item.notes != null && item.notes!.isNotEmpty ? const Icon(Icons.note, color: Colors.blue) : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyPackagesInventoryTab() {
    return StreamBuilder<List<EmptyPackagesInventoryModel>>(
      stream: _dataService.emptyPackagesInventoryStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'حدث خطأ: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد عبوات فارغة في المخزون',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  item.productName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المخزون: ${item.stock}'),
                    Text('التكلفة: ${item.totalCost.toStringAsFixed(2)}'),
                    Text('النوع: ${item.packageType}'),
                    Text('الوزن: ${item.packageWeight} ${item.weightUnit}'),
                    Text(
                      DateFormat('yyyy-MM-dd').format(item.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing:
                    item.notes != null && item.notes!.isNotEmpty ? const Icon(Icons.note, color: Colors.blue) : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFinishedProductsTab() {
    return StreamBuilder<List<FinishedProductsModel>>(
      stream: _dataService.finishedProductsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'حدث خطأ: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد منتجات مُعبأة',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.orange,
                  ),
                ),
                title: Text(
                  'دفعة: ${item.batchNumber}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الكمية: ${item.quantity}'),
                    Text(
                      DateFormat('yyyy-MM-dd').format(item.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing:
                    item.notes != null && item.notes!.isNotEmpty ? const Icon(Icons.note, color: Colors.blue) : null,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التعبئة'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.sunny),
              text: 'ما بعد التجفيف',
            ),
            Tab(
              icon: Icon(Icons.inventory_2),
              text: 'العبوات الفارغة',
            ),
            Tab(
              icon: Icon(Icons.local_shipping),
              text: 'المنتجات المُعبأة',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsAfterDryingTab(),
          _buildEmptyPackagesInventoryTab(),
          _buildFinishedProductsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFormSelectionBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
