import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/common/widgets/section_header.dart';
import 'package:test_flutter/features/hrms_app/controllers/attendance_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/widgets/history_card.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/widgets/stats_row.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/widgets/weekly_progress_card.dart';
import 'package:test_flutter/utils/constants/size.dart';

import '../../controllers/home_controller.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: 'Attendance',
            subtitle: controller.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WeeklyProgressCard(),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      StatsRow(),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      SectionHeader(title: 'My Attendance History'),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      HistoryCard(
                        AttendanceRecord(
                          date: 'June 10, 2024',
                          checkIn: '09:00 AM',
                          checkOut: '05:00 PM',
                          status: 'ON TIME',
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      HistoryCard(
                        AttendanceRecord(
                          date: 'June 10, 2024',
                          checkIn: '09:00 AM',
                          checkOut: '05:00 PM',
                          status: 'ON TIME',
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      HistoryCard(
                        AttendanceRecord(
                          date: 'June 10, 2024',
                          checkIn: '09:00 AM',
                          checkOut: '05:00 PM',
                          status: 'ON TIME',
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      HistoryCard(
                        AttendanceRecord(
                          date: 'June 10, 2024',
                          checkIn: '09:00 AM',
                          checkOut: '05:00 PM',
                          status: 'ON TIME',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
