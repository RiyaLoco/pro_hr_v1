import 'package:flutter/material.dart';
import 'package:test_flutter/data/models/res/schedule_models.dart';
import 'package:test_flutter/utils/constants/colors.dart';

Color shiftStatusColor(ShiftRequestStatus status) {
  switch (status) {
    case ShiftRequestStatus.pending:
      return const Color(0xFFE0A93B);
    case ShiftRequestStatus.approved:
      return PColor.primary;
    case ShiftRequestStatus.rejected:
      return const Color(0xFFD9534F);
  }
}

/// Small coloured pill: Pending (yellow), Approved (primary), Rejected (red).
class ShiftStatusChip extends StatelessWidget {
  final ShiftRequestStatus status;

  const ShiftStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = shiftStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}