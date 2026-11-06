import 'package:flutter/material.dart';
import 'package:test_flutter/data/models/res/attendance_summary_models.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class AttendanceStatsRow extends StatelessWidget {
  const AttendanceStatsRow({super.key, required this.summary});

  final AttendanceSummary summary;

  String _value(double? value, String unit) =>
      value == null ? '—' : '${formatAttendanceNumber(value)}$unit';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _statCard(_value(summary.totalHours, 'h'), 'TOTAL HOURS'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(_value(summary.onTimePercentage, '%'), 'ON TIME'),
        ),
        const SizedBox(width: 12),
        Expanded(child: _statCard(_value(summary.leaveDays, 'd'), 'LEAVE')),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return AppContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: 10,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: PColor.primary,
            ),
          ),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: PColor.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
