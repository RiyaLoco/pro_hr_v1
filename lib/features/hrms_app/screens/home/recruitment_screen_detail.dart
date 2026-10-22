import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/models/res/recruitment_models.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

import '../../controllers/home_controller.dart';

class RecruitmentDetailScreen extends StatelessWidget {
  final Recruitment recruitment;

  const RecruitmentDetailScreen({super.key, required this.recruitment});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final r = recruitment;
    final posterUrl = r.posterUrl == null ? null : AppUrlService.fileUrl(r.posterUrl!);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: 'Recruitment',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (posterUrl != null) ...[
                    _buildPoster(context, posterUrl),
                    const SizedBox(height: Sizes.spaceBtwItems),
                  ],
                  _buildSummaryCard(),
                  if (r.education.isNotEmpty) ...[
                    const SizedBox(height: Sizes.spaceBtwItems),
                    _TextSection(title: 'Education', body: r.education),
                  ],
                  if (r.experience.isNotEmpty) ...[
                    const SizedBox(height: Sizes.spaceBtwItems),
                    _TextSection(title: 'Experience', body: r.experience),
                  ],
                  if (r.description.isNotEmpty) ...[
                    const SizedBox(height: Sizes.spaceBtwItems),
                    _TextSection(title: 'About this job', body: r.description),
                  ],
                  if (r.jobDescription.isNotEmpty) ...[
                    const SizedBox(height: Sizes.spaceBtwItems),
                    _TextSection(title: 'Job description', body: r.jobDescription),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(BuildContext context, String url) {
    return Hero(
      tag: 'recruitment-${recruitment.uuid}',
      child: GestureDetector(
        onTap: () => _openFullscreen(context, url),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(child: Image.network(url, fit: BoxFit.contain)),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final r = recruitment;

    final tags = [r.department, r.position, r.branch, r.employmentType, r.shift]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();

    final facts = <_Fact>[
      if (r.requiredCount != null)
        _Fact(Icons.groups_outlined, 'Openings', '${r.requiredCount}'),
      if (r.salaryLabel != null)
        _Fact(Icons.payments_outlined, 'Salary', r.salaryLabel!),
      if (r.openDateLabel != null)
        _Fact(Icons.event_available_outlined, 'Open date', r.openDateLabel!),
      if (r.deadlineLabel != null)
        _Fact(Icons.event_busy_outlined, 'Deadline', r.deadlineLabel!),
    ];

    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  r.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: PColor.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: PColor.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: PColor.primary,
                  ),
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((t) => _TagChip(label: t)).toList(),
            ),
          ],
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.grey[200], height: 1),
            ...facts.map((f) => _FactRow(fact: f)),
          ],
        ],
      ),
    );
  }
}

class _Fact {
  final IconData icon;
  final String label;
  final String value;

  const _Fact(this.icon, this.label, this.value);
}

class _FactRow extends StatelessWidget {
  final _Fact fact;

  const _FactRow({required this.fact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(fact.icon, size: 18, color: PColor.primary),
          const SizedBox(width: 10),
          Text(fact.label, style: TextStyle(fontSize: 13, color: PColor.textColor)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              fact.value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: PColor.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: PColor.primary,
        ),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  final String title;
  final String body;

  const _TextSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final lines = body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PColor.primary,
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < lines.length; index++) ...[
            if (index > 0) const SizedBox(height: 8),
            _buildBodyLine(lines[index]),
          ],
        ],
      ),
    );
  }

  Widget _buildBodyLine(String line) {
    final isBullet = line.startsWith('•') || line.startsWith('-');
    final text = isBullet ? line.substring(1).trim() : line;
    const style = TextStyle(fontSize: 14, height: 1.5, color: Colors.black87);

    if (!isBullet) return Text(text, style: style);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 10),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: PColor.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
