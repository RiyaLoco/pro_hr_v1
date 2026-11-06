import 'package:flutter/material.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/data/models/res/attendance_history_models.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class HistoryCard extends StatelessWidget {
  final AttendanceRecord record;
  const HistoryCard(this.record, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  record.dateLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: PColor.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: PColor.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    record.statusLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PColor.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _time(Icons.login, 'Check in', record.checkInLabel),
              _time(Icons.logout, 'Check out', record.checkOutLabel),
              // if (record.workedHours != null)
              //   Text('${formatAttendanceNumber(record.workedHours!)}h worked'),
              // if ((record.lateMinutes ?? 0) > 0)
              //   Text('${record.lateMinutes} min late'),
              // if ((record.earlyMinutes ?? 0) > 0)
              //   Text('${record.earlyMinutes} min early'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _time(IconData icon, String label, String value) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: PColor.textColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: PColor.textColor),
        ),
      ],
    ),
  );
}
