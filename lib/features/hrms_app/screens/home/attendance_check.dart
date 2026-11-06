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
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final remainingHeight =
                  constraints.viewportMainAxisExtent -
                  constraints.precedingScrollExtent;

              return SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: remainingHeight > 0 ? remainingHeight : 0,
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Branch coordinates and policy radius come from Laravel;
                      // sample coordinates must not claim the user is in range.
                      const Positioned.fill(child: LocationHelpers()),
                      SafeArea(
                        top: false,
                        minimum: const EdgeInsets.fromLTRB(16, 180, 16, 24),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: const AttendanceCard(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
