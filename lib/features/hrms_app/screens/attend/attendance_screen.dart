import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_refresh_scroll_view.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/common/widgets/section_header.dart';
import 'package:test_flutter/features/hrms_app/controllers/attendance_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/widgets/history_card.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/widgets/attend_stats_row.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/widgets/weekly_progress_card.dart';
import 'package:test_flutter/utils/constants/size.dart';

import '../../controllers/home_controller.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final controller = Get.put(AttendanceController());
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AppRefreshScrollView(
        onRefresh: controller.fetchAttendance,
        slivers: [
          Obx(
            () => CustomSliverAppBar(
              title: 'Attendance',
              subtitle: home.currentDate.value,
              isShowProfile: false,
            ),
          ),
          Obx(() {
            final summary = controller.summary.value;
            if (summary == null) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            final weekly = summary.weeklyProgress;
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (weekly != null) ...[
                      WeeklyProgressCard(progress: weekly),
                      const SizedBox(height: Sizes.spaceBtwItems),
                    ],
                    AttendanceStatsRow(summary: summary),
                  ],
                ),
              ),
            );
          }),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'My Attendance History',
                showAction: false,
              ),
            ),
          ),
          Obx(() {
            final error = controller.errorMessage.value;
            if (controller.isLoading.value && controller.records.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (error != null) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(error, textAlign: TextAlign.center),
                      TextButton.icon(
                        onPressed: controller.fetchAttendance,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }),
          Obx(() {
            if (controller.records.isEmpty) {
              if (controller.isLoading.value ||
                  controller.errorMessage.value != null) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No attendance records found')),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
                    child: HistoryCard(controller.records[index]),
                  ),
                  childCount: controller.records.length,
                ),
              ),
            );
          }),
          Obx(() {
            if (!controller.hasMore.value) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    if (controller.loadMoreError.value != null)
                      Text(
                        controller.loadMoreError.value!,
                        textAlign: TextAlign.center,
                      ),
                    if (controller.isLoadingMore.value)
                      const CircularProgressIndicator()
                    else
                      TextButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.loadMore,
                        child: Text(
                          controller.loadMoreError.value == null
                              ? 'Load more'
                              : 'Retry',
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
