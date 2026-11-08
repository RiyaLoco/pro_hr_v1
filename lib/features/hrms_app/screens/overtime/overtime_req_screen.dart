import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_request_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/leave_form.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class OvertimeRequestScreen extends StatelessWidget {
  const OvertimeRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.isRegistered<OvertimeRequestController>()
        ? Get.find<OvertimeRequestController>()
        : Get.put(OvertimeRequestController());
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: 'Overtime Request',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => LeaveFormField(
                      icon: Icons.calendar_today_outlined,
                      label: controller.dateLabel,
                      showDropdownIcon: false,
                      onTap: () => controller.pickDate(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => LeaveFormField(
                            icon: Icons.login,
                            label:
                                controller.startTime.value?.format(context) ??
                                'Start time',
                            showDropdownIcon: false,
                            onTap: () =>
                                controller.pickTime(context, start: true),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => LeaveFormField(
                            icon: Icons.logout,
                            label:
                                controller.endTime.value?.format(context) ??
                                'End time',
                            showDropdownIcon: false,
                            onTap: () =>
                                controller.pickTime(context, start: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => LeaveFormField(
                      icon: Icons.payments_outlined,
                      label:
                          controller.rate.value?.label ??
                          'Select overtime rate',
                      onTap: () => controller.pickRate(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LeaveTextAreaField(
                    controller: controller.reasonController,
                    hint: 'Reason for overtime',
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => controller.validationError.value == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              controller.validationError.value!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                  ),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PColor.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.submit,
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Submit request'),
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