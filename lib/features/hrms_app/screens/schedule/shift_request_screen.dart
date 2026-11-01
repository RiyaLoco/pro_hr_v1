import 'package:test_flutter/common/widgets/app_refresh_scroll_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/models/res/schedule_models.dart';
import 'package:test_flutter/features/hrms_app/controllers/shift_request_form_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/leave_form.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

import '../../controllers/home_controller.dart';

/// Ask to change the shift of one working day.
class ShiftRequestScreen extends StatelessWidget {
  final WorkSchedule schedule;

  const ShiftRequestScreen({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(ShiftRequestFormController(schedule));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AppRefreshScrollView(
        onRefresh: controller.loadShifts,
        slivers: [
          CustomSliverAppBar(
            title: 'Request Shift',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Current shift ----
                  AppContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current shift',
                          style: TextStyle(
                            fontSize: 13,
                            color: PColor.textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          schedule.shiftName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: PColor.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatWeekdayDate(schedule.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: PColor.textColor,
                          ),
                        ),
                        if (schedule.timeLabel.isNotEmpty)
                          Text(
                            schedule.timeLabel,
                            style: TextStyle(
                              fontSize: 14,
                              color: PColor.textColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),

                  // ---- Form ----
                  Obx(
                    () => LeaveFormField(
                      icon: Icons.swap_horiz,
                      label: controller.newShiftLabel,
                      onTap: () => controller.pickShift(context),
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  LeaveTextAreaField(controller: controller.reasonController),
                  const SizedBox(height: 32),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PColor.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
