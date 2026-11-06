import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
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
          Expanded(
            child: _StatBox(
              label: 'Total approved hours',
              value: controller.totalApprovedHours,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatBox(
              label: 'Requested this month',
              value: controller.thisMonthHours,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => AppContainer(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: PColor.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: PColor.textColor),
        ),
      ],
    ),
  );
}
