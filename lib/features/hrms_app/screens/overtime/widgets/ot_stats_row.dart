import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class OvertimeStatsRow extends StatelessWidget {
  const OvertimeStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OvertimeController>();
    return Obx(
      () => Row(
        children: [
          Expanded(child: _StatBox(label: 'Total Approved', value: controller.totalApprovedHours.value,)),
          const SizedBox(width: 12),
          Expanded(child: _StatBox(label: 'This Month', value: controller.thisMonthHours.value)),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PColor.primary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: PColor.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: PColor.primary)),
        ],
      ),
    );
  }
}