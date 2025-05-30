import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_sudan/models/farm_to_drying_model.dart';
import 'package:inventory_sudan/utils/app_router.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/service_locator.dart';
import 'package:inventory_sudan/ui/screens/farm_to_drying/components/farm_to_drying_card.dart';

class FarmToDryingScreen extends StatefulWidget {
  const FarmToDryingScreen({Key? key}) : super(key: key);

  @override
  State<FarmToDryingScreen> createState() => _FarmToDryingScreenState();
}

class _FarmToDryingScreenState extends State<FarmToDryingScreen> {
  final _dataService = serviceLocator<DataService>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _dataService.getFarmToDryingRecords();
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
        title: const Text('من المزرعة للتجفيف'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<FarmToDryingModel>>(
        stream: _dataService.farmToDryingStream,
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

          final farmToDryingData = snapshot.data ?? [];

          if (farmToDryingData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد بيانات من المزرعة للتجفيف',
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
            itemCount: farmToDryingData.length,
            itemBuilder: (context, index) {
              final item = farmToDryingData[index];
              return FarmToDryingCard(data: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRouter.FARM_TO_DRYING_FORM),
        child: const Icon(Icons.add),
      ),
    );
  }
}
