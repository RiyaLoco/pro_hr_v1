import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

class EntryList extends StatelessWidget {
  const EntryList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OvertimeController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final entries = controller.filteredEntries;
      if (entries.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'No overtime entries found.',
              style: TextStyle(color: PColor.textColor),
            ),
          ),
        );
      }

      return Column(
        children: entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
                child: _EntryTile(entry: entry),
              ),
            )
            .toList(),
      );
    });
  }
}
class _EntryTile extends StatelessWidget {
  final OvertimeEntry entry;

  const _EntryTile({required this.entry});

  Color get _statusColor {
    switch (entry.status) {
      case OvertimeStatus.pending:
        return const Color(0xFFE0A93B);
      case OvertimeStatus.reject:
        return const Color(0xFFD9534F);
      case OvertimeStatus.approved:
        return PColor.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.date, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PColor.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  entry.status.label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(entry.title, style: TextStyle(fontSize: 14, color: PColor.textColor)),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: PColor.primary),
                  const SizedBox(width: 4),
                  Text(entry.hoursLabel, style: TextStyle(fontSize: 13, color: PColor.primary, fontWeight: FontWeight.w600)),
                ],
              ),
              Text(entry.personLabel, style: TextStyle(fontSize: 13, color: PColor.textColor)),
            ],
          ),
        ],
      ),
    );
  }
}