import 'package:test_flutter/common/widgets/app_refresh_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/common/widgets/section_header.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/overtime_req_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/entry_list.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/ot_stats_row.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/searchfiled.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

import '../../controllers/home_controller.dart';

class OvertimeScreen extends StatelessWidget {
  const OvertimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(OvertimeController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: PColor.primary,
        onPressed: () => Get.to(() => const OvertimeRequestScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Stack(
        children: [
          AppRefreshScrollView(
            onRefresh: controller.fetchEntries,
            slivers: [
              CustomSliverAppBar(
                title: 'Overtime',
                subtitle: homeController.currentDate.value,
                isShowProfile: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OvertimeStatsRow(),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      SearchField(),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'My Overtime History',
                        showAction: true,
                        actionIcon: Icons.file_download_outlined,
                      ),
                      const SizedBox(height: 12),
                      EntryList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
