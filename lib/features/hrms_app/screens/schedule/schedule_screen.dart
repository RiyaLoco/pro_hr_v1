import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/features/hrms_app/controllers/schedule_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/schedule/widgets/month_calender.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

import '../../controllers/home_controller.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(ScheduleController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: 'Schedule',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: const MonthCalendar(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Today Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PColor.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final events = controller.selectedDateEvents;
                    if (events.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: events
                          .map(
                            (event) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Sizes.spaceBtwItems),
                              child: _EventTile(event: event),
                            ),
                          )
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 72,
              color: PColor.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No Events Today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PColor.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final ScheduleEvent event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  event.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: PColor.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.timeLabel,
                  style: TextStyle(fontSize: 13, color: PColor.textColor),
                ),
              ],
            ),
          ),
          Text(
            event.relativeLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}