import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/models/res/leave_request_models.dart';
import 'package:test_flutter/features/hrms_app/controllers/leave_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/leave_screen_detail.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/leaving_request_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/leave_req_title.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/tap_row.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

import '../../controllers/home_controller.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(LeaveController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: PColor.primary,
        onPressed: () => Get.to(() => const LeavingRequestScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: 'Leave',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: TapRow(),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final requests = controller.filteredRequests;
            if (requests.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final request = requests[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == requests.length - 1
                          ? 0
                          : Sizes.spaceBtwItems,
                    ),
                    child: GestureDetector(
                      onTap: ()=> Get.to(()=> LeaveScreenDetail(request: request)),
                      child: LeaveRequestTile(request: request),
                    ),
                  );
                }, childCount: requests.length),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---- Tabs ----

  // ---- Empty state ----
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 100,
            color: PColor.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No leaving request',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: PColor.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
