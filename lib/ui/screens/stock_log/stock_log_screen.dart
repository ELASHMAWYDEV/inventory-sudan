import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/models/stock_log_model.dart';
import 'package:inventory_sudan/utils/app_router.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:inventory_sudan/ui/screens/stock_log/components/stock_log_card.dart';

class StockLogScreen extends StatefulWidget {
  const StockLogScreen({Key? key}) : super(key: key);

  @override
  State<StockLogScreen> createState() => _StockLogScreenState();
}

class _StockLogScreenState extends State<StockLogScreen> {
  final _dataService = serviceLocator<DataService>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _dataService.getStockLogRecords();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل البيانات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جرد المخزون'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<StockLogModel>>(
        stream: _dataService.stockLogStream,
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

          final stockLogData = snapshot.data ?? [];

          if (stockLogData.isEmpty) {
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
                    'لا توجد جرود مخزون',
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
            itemCount: stockLogData.length,
            itemBuilder: (context, index) {
              final stockLog = stockLogData[index];
              return StockLogCard(data: stockLog);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showStockTypeSelection,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showStockTypeSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'اختر نوع الجرد',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'حدد نوع المخزون المراد جرده',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Stock Type Options
            _buildStockTypeOption(
              title: 'جرد المواد الخام',
              subtitle: 'فول سوداني، سمسم، ذرة، إلخ',
              icon: Icons.grass,
              color: Colors.green,
              stockType: 'raw_material',
            ),
            const SizedBox(height: 12),
            _buildStockTypeOption(
              title: 'جرد المنتجات المُعبأة',
              subtitle: 'منتجات جاهزة للبيع',
              icon: Icons.inventory,
              color: Colors.blue,
              stockType: 'packaged_product',
            ),
            const SizedBox(height: 12),
            _buildStockTypeOption(
              title: 'جرد العبوات الفارغة',
              subtitle: 'أكياس، علب، صناديق فارغة',
              icon: Icons.inventory_2_outlined,
              color: Colors.orange,
              stockType: 'empty_package',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStockTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String stockType,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Get.toNamed(AppRouter.STOCK_LOG_FORM, arguments: {
          'stockType': stockType,
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
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
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
