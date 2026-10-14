import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/features/hrms_app/controllers/report_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/reports/widgets/simple_bart_chart.dart';

class WeeklyChartCard extends StatelessWidget {
  const WeeklyChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();
    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SimpleBarChart(data: controller.weeklyHours, maxValue: 8);
      }),
    );
  }
}