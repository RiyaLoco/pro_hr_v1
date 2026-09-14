import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/features/hrms_app/controllers/leave_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/leaving_request_screen.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: _buildTabRow(controller),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredRequests.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredRequests.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: Sizes.spaceBtwItems),
                itemBuilder: (context, index) {
                  final request = controller.filteredRequests[index];
                  return _LeaveRequestTile(request: request);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ---- Tabs ----
  Widget _buildTabRow(LeaveController controller) {
    return Obx(
      () => Row(
        children: [
          for (final status in LeaveStatus.values) ...[
            Expanded(
              child: _TabPill(
                label: status.label,
                isSelected: controller.selectedTab.value == status,
                onTap: () => controller.changeTab(status),
              ),
            ),
            if (status != LeaveStatus.values.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

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

class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
 
  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? PColor.primary : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? PColor.primary : PColor.primary.withOpacity(0.4),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: PColor.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : PColor.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaveRequestTile extends StatelessWidget {
  final LeaveRequest request;

  const _LeaveRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.leaveType,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: PColor.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                  style: TextStyle(fontSize: 13, color: PColor.textColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PColor.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              request.status.label.toUpperCase(),
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

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}