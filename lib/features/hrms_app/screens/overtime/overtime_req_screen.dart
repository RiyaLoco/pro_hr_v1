import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_request_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/leave_form.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

import '../../controllers/home_controller.dart';

class OvertimeRequestScreen extends StatelessWidget {
  const OvertimeRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(OvertimeRequestController());

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LeaveFormField(
                            icon: Icons.calendar_today_outlined,
                            label: controller.startDateLabel,
                            showDropdownIcon: false,
                            onTap: () => controller.pickStartDate(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LeaveFormField(
                            icon: Icons.calendar_today_outlined,
                            label: controller.endDateLabel,
                            showDropdownIcon: false,
                            onTap: () => controller.pickEndDate(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    LeaveFormField(
                      icon: Icons.access_time,
                      label: controller.hoursWorkedLabel,
                      onTap: () => controller.pickHoursWorked(context),
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    LeaveFormField(
                      icon: Icons.hourglass_bottom,
                      label: controller.overtimeRateLabel,
                      onTap: () => controller.pickOvertimeRate(context),
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    LeaveFormField(
                      icon: Icons.verified_user_outlined,
                      label: controller.certifyAuthorizeLabel,
                      onTap: () => controller.pickCertifyAuthorize(context),
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    LeaveTextAreaField(controller: controller.reasonController),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value ? null : controller.submit,
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
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}