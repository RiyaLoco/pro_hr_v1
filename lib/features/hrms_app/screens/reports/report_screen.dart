import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/features/hrms_app/controllers/report_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/reports/widgets/report_list.dart';
import 'package:test_flutter/features/hrms_app/screens/reports/widgets/weekly_chart_card.dart';
import 'package:test_flutter/utils/constants/colors.dart';

import '../../controllers/home_controller.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(ReportController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: 'Report',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(controller),
                  const SizedBox(height: 24),
                  Text(
                    'This Week',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PColor.primary),
                  ),
                  const SizedBox(height: 12),
                  WeeklyChartCard(),
                  const SizedBox(height: 24),
                  Text(
                    'My Reports',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PColor.primary),
                  ),
                  const SizedBox(height: 12),
                  ReportList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ReportController controller) {
    return Obx(
      () => Row(
        children: [
          Expanded(child: _StatBox(label: 'ATTENDANCE', value: controller.attendanceRate.value)),
          const SizedBox(width: 12),
          Expanded(child: _StatBox(label: 'LEAVE TAKEN', value: controller.totalLeaveDays.value)),
          const SizedBox(width: 12),
          Expanded(child: _StatBox(label: 'OVERTIME', value: controller.totalOvertimeHours.value)),
        ],
      ),
    );
  }


}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColor.primary.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: PColor.primary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: PColor.textColor, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

