import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/utils/app_router.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/ui/widgets/common/custom_button.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:intl/intl.dart';

class PackagingScreen extends StatefulWidget {
  const PackagingScreen({Key? key}) : super(key: key);

  @override
  State<PackagingScreen> createState() => _PackagingScreenState();
}

class _PackagingScreenState extends State<PackagingScreen> {
  final _dataService = serviceLocator<DataService>();
  bool _isLoading = true;
  List<Map<String, dynamic>> _packagingData = [];
  late final Stream<List<Map<String, dynamic>>> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = _dataService.packagingStream.map((data) => data.map((record) => record.toMap()).toList());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dataService.getPackagingRecords();
      setState(() {
        _packagingData = data.map((record) => record.toMap()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل البيانات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _navigateToForm() {
    Get.toNamed(AppRouter.PACKAGING_FORM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التعبئة'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dataStream,
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
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد تعبئة بعد',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'إضافة تعبئة جديدة',
                    onPressed: _navigateToForm,
                    icon: Icons.add,
                    isFullWidth: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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
                child: ListTile(
                  title: Text(item['productName'] ?? ''),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd').format(
                      DateTime.parse(item['createdAt']),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
