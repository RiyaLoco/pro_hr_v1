import 'package:flutter/material.dart';
import 'package:test_flutter/features/hrms_app/screens/home/recruitment_list_screen.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/section_header.dart';
import 'package:test_flutter/data/models/res/recruitment_models.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/features/hrms_app/controllers/recruitment_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/home/recruitment_screen_detail.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class RecruitmentSection extends StatelessWidget {
  const RecruitmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecruitmentController());

    return Obx(() {
      final isEmpty = controller.recruitments.isEmpty;
      if (isEmpty &&
          !controller.isLoading.value &&
          !controller.hasError.value) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recruitment',
            onActionTap: () => Get.to(() => const RecruitmentListScreen()),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 160, child: _buildBody(controller)),
        ],
      );
    });
  }

  Widget _buildBody(RecruitmentController controller) {
    final items = controller.recruitments;

    if (items.isEmpty && controller.isLoading.value) {
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => Container(
          width: 140,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    if (items.isEmpty && controller.hasError.value) {
      return Center(
        child: TextButton.icon(
          onPressed: controller.fetchRecruitments,
          icon: Icon(Icons.refresh, color: PColor.primary),
          label: Text(
            'Could not load recruitment. Tap to retry',
            style: TextStyle(color: PColor.primary),
          ),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) => _PosterCard(recruitment: items[index]),
    );
  }
}

class _PosterCard extends StatelessWidget {
  final Recruitment recruitment;

  const _PosterCard({required this.recruitment});

  @override
  Widget build(BuildContext context) {
    final url = recruitment.posterUrl;

    return Hero(
      tag: 'recruitment-${recruitment.uuid}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 140,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url == null)
                _PosterFallback(title: recruitment.title)
              else
                Image.network(
                  AppUrlService.fileUrl(url),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) =>
                      _PosterFallback(title: recruitment.title),
                ),
              // Sits on top of the image so the tap shows a ripple.
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.to(
                      () => RecruitmentDetailScreen(recruitment: recruitment),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when a job has no poster, or the poster fails to load.
class _PosterFallback extends StatelessWidget {
  final String title;

  const _PosterFallback({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PColor.primary,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.work_outline, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
