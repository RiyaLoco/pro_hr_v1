import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/common/widgets/app_refresh_scroll_view.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/models/res/recruitment_models.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/features/hrms_app/controllers/recruitment_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/home/recruitment_screen_detail.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class RecruitmentListScreen extends StatelessWidget {
  const RecruitmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecruitmentController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AppRefreshScrollView(
        onRefresh: controller.fetchRecruitments,
        slivers: [
          const CustomSliverAppBar(
            title: 'Recruitment',
            subtitle: 'Explore all job openings',
            isShowProfile: false,
          ),
          Obx(() {
            if (controller.recruitments.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : controller.hasError.value
                      ? TextButton.icon(
                          onPressed: controller.fetchRecruitments,
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            'Could not load recruitment. Retry',
                          ),
                        )
                      : const Text('No job openings available'),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _RecruitmentTile(
                    recruitment: controller.recruitments[index],
                  ),
                  childCount: controller.recruitments.length,
                ),
              ),
            );
          }),
          Obx(
            () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: controller.isLoadingMore.value
                      ? const CircularProgressIndicator()
                      : controller.hasError.value &&
                            controller.recruitments.isNotEmpty
                      ? TextButton(
                          onPressed: controller.fetchRecruitments,
                          child: const Text('Refresh failed. Retry'),
                        )
                      : controller.hasMore.value
                      ? TextButton(
                          onPressed: controller.loadMore,
                          child: Text(
                            controller.loadMoreFailed.value
                                ? 'Could not load more. Retry'
                                : 'Load more',
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecruitmentTile extends StatelessWidget {
  const _RecruitmentTile({required this.recruitment});

  final Recruitment recruitment;

  @override
  Widget build(BuildContext context) {
    final job = recruitment;
    final details = [
      job.department,
      job.branch,
      job.employmentType,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' • ');
    final fallback = Container(
      color: PColor.primary.withValues(alpha: 0.1),
      child: Icon(Icons.work_outline, color: PColor.primary),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppContainer(
        padding: const EdgeInsets.all(16),
        onTap: () => Get.to(() => RecruitmentDetailScreen(recruitment: job)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 100,
                height: 120,
                child: job.posterUrl == null
                    ? fallback
                    : Image.network(
                        AppUrlService.fileUrl(job.posterUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => fallback,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PColor.primary,
                    ),
                  ),
                  if (details.isNotEmpty) Text(details, style: const TextStyle(color: PColor.textColor, fontSize: 12)),
                  // if (job.salaryLabel != null) Text(job.salaryLabel!),
                  // if (job.deadlineLabel != null)
                  //   Text('Deadline: ${job.deadlineLabel}'),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: PColor.primary,),
          ],
        ),
      ),
    );
  }
}
