import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';

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
                  // const AttendanceCard(),
                  // const SizedBox(height: 20),
                  // const MenuGrid(),
                  // const SizedBox(height: 24),
                  // const RecruitmentSection(),
                  // const SizedBox(height: 24),
                  // const RecruitmentSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
