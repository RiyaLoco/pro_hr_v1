import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/overtime_req_screen.dart';
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
          CustomScrollView(
            slivers: [
              CustomSliverAppBar(
                title: 'Overtime',
                subtitle: homeController.currentDate.value,
                isShowProfile: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(controller),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      _buildSearchField(controller),
                      const SizedBox(height: 24),
                      _buildSectionHeader(),
                      const SizedBox(height: 12),
                      _buildEntryList(controller),
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

  // ---- Stats row ----
  Widget _buildStatsRow(OvertimeController controller) {
    return Obx(
      () => Row(
        children: [
          Expanded(child: _StatBox(label: 'Total Approved', value: controller.totalApprovedHours.value,)),
          const SizedBox(width: 12),
          Expanded(child: _StatBox(label: 'This Month', value: controller.thisMonthHours.value)),
        ],
      ),
    );
  }

  // ---- Search field ----
  Widget _buildSearchField(OvertimeController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PColor.primary.withOpacity(0.4)),
      ),
      child: TextField(
        onChanged: controller.updateSearch,
        style: TextStyle(fontSize: 14, color: PColor.primary),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: PColor.primary, size: 20),
          hintText: 'Search by date or Manager...',
          hintStyle: TextStyle(color: PColor.primary.withOpacity(0.7)),
        ),
      ),
    );
  }

  // ---- Section header ----
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Entries',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PColor.primary),
        ),
        IconButton(
          onPressed: () {
            // TODO: export / download recent entries.
          },
          icon: Icon(Icons.file_download_outlined, color: PColor.primary),
        ),
      ],
    );
  }

  // ---- Entry list ----
  Widget _buildEntryList(OvertimeController controller) {
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PColor.primary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: PColor.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: PColor.primary)),
        ],
      ),
    );
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