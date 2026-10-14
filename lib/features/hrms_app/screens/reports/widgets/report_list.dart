import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/features/hrms_app/controllers/report_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

class ReportList extends StatelessWidget {
  const ReportList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.reports.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('No reports available yet.', style: TextStyle(color: PColor.textColor)),
          ),
        );
      }

      return Column(
        children: controller.reports
            .map(
              (report) => Padding(
                padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
                child: _ReportTile(
                  report: report,
                  onDownload: () => controller.downloadReport(report),
                ),
              ),
            )
            .toList(),
      );
    });
  }
}
class _ReportTile extends StatelessWidget {
  final ReportItem report;
  final VoidCallback onDownload;

  const _ReportTile({required this.report, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: PColor.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(report.icon, color: PColor.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PColor.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  report.subtitle,
                  style: TextStyle(fontSize: 12, color: PColor.textColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDownload,
            icon: Icon(Icons.file_download_outlined, color: PColor.primary),
          ),
        ],
      ),
    );
  }
}