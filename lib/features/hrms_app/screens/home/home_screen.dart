import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/attendance_card.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/collapsed_title.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/expanded_appbar.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/home_menu_grid.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/recruitment_section.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          Obx(() => SliverAppBar(
                backgroundColor: PColor.primary,
                expandedHeight: controller.expandedHeight,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,

                title: controller.isCollapsed.value
                    ? CollapsedTitle()
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  background: ExpandedAppBar(),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(controller.bottomCurveHeight),
                  child: Container(
                    height: controller.bottomCurveHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
              )),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AttendanceCard(),
                  const SizedBox(height: 20),
                  const MenuGrid(),
                  const SizedBox(height: 24),
                  const RecruitmentSection(),
                  const SizedBox(height: 24),
                  const RecruitmentSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}