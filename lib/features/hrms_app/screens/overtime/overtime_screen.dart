import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_refresh_scroll_view.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/common/widgets/section_header.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/overtime_req_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/entry_list.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/ot_stats_row.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/searchfiled.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/overtime_status_tabs.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class OvertimeScreen extends StatelessWidget {
  const OvertimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final controller = Get.isRegistered<OvertimeController>()
        ? Get.find<OvertimeController>()
        : Get.put(OvertimeController());
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: PColor.primary,
        onPressed: () => Get.to(() => const OvertimeRequestScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: AppRefreshScrollView(
        onRefresh: controller.fetchEntries,
        slivers: [
          Obx(
            () => CustomSliverAppBar(
              title: 'Overtime',
              subtitle: home.currentDate.value,
              isShowProfile: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OvertimeStatsRow(),
                  const SizedBox(height: 20),
                  const SearchField(),
                  const SizedBox(height: 16),
                  const OvertimeStatusTabs(),
                  const SizedBox(height: 20),
                  Obx(
                    () => SectionHeader(
                      title: 'Overtime history',
                      trailing: Text(
                        '${controller.filteredEntries.length} ${controller.filteredEntries.length == 1 ? 'request' : 'requests'}',
                        style: const TextStyle(
                          color: PColor.textColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const EntryList(),
        ],
      ),
    );
  }
}
