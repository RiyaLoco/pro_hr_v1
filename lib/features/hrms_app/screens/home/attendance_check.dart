import 'package:test_flutter/features/hrms_app/controllers/punch_countroller.dart';
import 'package:test_flutter/common/widgets/app_refresh_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/attendance_card.dart';
import 'package:test_flutter/utils/helpers/location_helpers.dart';

class AttendanceCheck extends StatelessWidget {
  const AttendanceCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppRefreshScrollView(
        onRefresh: Get.find<PunchController>().fetchToday,
        slivers: [
          CustomSliverAppBar(
            title: 'Attendance Check',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Stack(
              children: [
                LocationHelpers(
                  userLatLong: '11.5568,104.9285',
                  officeLatLong: '11.5564,104.9282',
                  allowedRadiusMeters: 100,
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 40,
                  child: AttendanceCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
