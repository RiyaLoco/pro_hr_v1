import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/data/models/res/overtime_models.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/overtime_detail_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/overtime_status_chip.dart';
import 'package:test_flutter/utils/constants/colors.dart';

/// Sliver list so history stays lazy inside the screen's scroll view.
class EntryList extends StatelessWidget {
  const EntryList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OvertimeController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final entries = controller.filteredEntries;
      if (entries.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: Text('No overtime requests match your search.',style: TextStyle(color: PColor.textColor),),
            ),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: OvertimeEntryCard(entry: entries[index]),
            ),
            childCount: entries.length,
          ),
        ),
      );
    });
  }
}

class OvertimeEntryCard extends StatelessWidget {
  const OvertimeEntryCard({super.key, required this.entry});
  final OtRequest entry;

  @override
  Widget build(BuildContext context) => AppContainer(
    padding: const EdgeInsets.all(16),
    onTap: () => Get.to(() => OvertimeDetailScreen(request: entry)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.dateLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: PColor.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OvertimeStatusChip(status: entry.status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.reason,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: PColor.textColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              entry.timeLabel,
              style: const TextStyle(color: PColor.textColor, fontSize: 13),
            ),
            Text(
              entry.hoursLabel,
              style: const TextStyle(
                color: PColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        Text(
          entry.rateLabel,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,color: PColor.primary),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                entry.reviewerLabel,
                style: const TextStyle(fontSize: 12, color: PColor.textColor),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: PColor.primary),
          ],
        ),
      ],
    ),
  );
}
