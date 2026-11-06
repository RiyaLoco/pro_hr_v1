import 'package:flutter/material.dart';
import 'package:test_flutter/data/models/res/overtime_models.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class OvertimeStatusChip extends StatelessWidget {
  const OvertimeStatusChip({super.key, required this.status});
  final OvertimeStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OvertimeStatus.approved => PColor.primary,
      OvertimeStatus.pending => PColor.pendingColor,
      OvertimeStatus.reject => PColor.rejectedColor,
      OvertimeStatus.unknown => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
