import 'package:flutter/material.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/features/hrms_app/controllers/attendance_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class HistoryCard extends StatelessWidget {
  final AttendanceRecord record;
  const HistoryCard(this.record, {super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(AttendanceController());
     return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      borderRadius: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.date,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: PColor.primary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.login, size: 14, color: PColor.textColor),
                  const SizedBox(width: 4),
                  Text(
                    record.checkIn,
                    style: const TextStyle(fontSize: 13, color: PColor.textColor),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.logout, size: 14, color: PColor.textColor),
                  const SizedBox(width: 4),
                  Text(
                    record.checkOut,
                    style: const TextStyle(fontSize: 13, color: PColor.textColor),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PColor.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              record.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: PColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}