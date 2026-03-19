import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Attendance Check',
                style: TextStyle(
                    color: PColor.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.currentTime.value,
                            style: TextStyle(
                                color: PColor.primary,
                                fontSize: 36,
                                fontWeight: FontWeight.bold)),
                        Text(controller.currentDate.value,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _TimeInfo(time: '9:00 AM', label: 'Check in'),
                            _TimeInfo(time: '9:00 AM', label: 'Check out'),
                            _TimeInfo(time: '9:00 AM', label: 'Times Working'),
                          ],
                        ),
                      ],
                    )),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: PColor.primary.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PColor.primary.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('Punch In',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final String time;
  final String label;
  const _TimeInfo({required this.time, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }
}
