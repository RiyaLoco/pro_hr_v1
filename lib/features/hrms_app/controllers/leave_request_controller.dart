import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:test_flutter/features/hrms_app/controllers/leave_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';
import 'package:test_flutter/utils/constants/image_string.dart';

/// Controller backing the Leaving Request form screen.
class LeaveRequestController extends GetxController {
  static const List<SelectionOption> timeOptions = [
    SelectionOption(value: 'Full Day', title: 'Full Day'),
    SelectionOption(value: 'Half Morning', title: 'Half Morning'),
    SelectionOption(value: 'Half Afternoon', title: 'Half Afternoon'),
    SelectionOption(value: 'Customize', title: 'Customize'),
  ];

  static const List<SelectionOption> leaveTypeOptions = [
    SelectionOption(value: 'Annual', title: 'Annual'),
    SelectionOption(value: 'Sick', title: 'Sick'),
    SelectionOption(value: 'Spacial', title: 'Spacial'),
    SelectionOption(value: 'Unpaid Leave', title: 'Unpaid Leave'),
  ];

  // TODO: replace with real approvers (e.g. fetched from an API),
  // including their actual avatar images instead of the placeholder.
  static const List<SelectionOption> authorizeOptions = [
    SelectionOption(
      value: 'Mr Khiev Sovan',
      title: 'Mr Khiev Sovan',
      subtitle: 'HR Supervisor',
      avatar: AssetImage(ImageString.profile1),
    ),
    SelectionOption(
      value: 'Mr Sok chankungkea',
      title: 'Mr Sok chankungkea',
      subtitle: 'Chief Information Technology',
      avatar: AssetImage(ImageString.profile1),
    ),
    SelectionOption(
      value: 'Mr Reth Vathanak',
      title: 'Mr Reth Vathanak',
      subtitle: 'Information Technology Officer',
      avatar: AssetImage(ImageString.profile1),
    ),
  ];

  final TextEditingController reasonController = TextEditingController();

  final RxnString selectedTime = RxnString();
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxnString leaveType = RxnString();
  final RxnString certifyAuthorize = RxnString();
  final RxnString uploadedImagePath = RxnString();
  final RxBool isSubmitting = false.obs;

  String get timeLabel => selectedTime.value ?? 'Select time';

  String get startDateLabel =>
      startDate.value == null ? 'Start Date' : _formatDate(startDate.value!);

  String get endDateLabel =>
      endDate.value == null ? 'End Date' : _formatDate(endDate.value!);

  String get leaveTypeLabel => leaveType.value ?? 'Select leave type';

  String get certifyAuthorizeLabel =>
      certifyAuthorize.value ?? 'Certify Authorize';

  Future<void> pickTime(BuildContext context) async {
    final result = await SelectionBottomSheet.show(
      context,
      title: 'Select time',
      options: timeOptions,
      selectedValue: selectedTime.value,
    );
    if (result != null) selectedTime.value = result;
  }

  Future<void> pickStartDate(BuildContext context) async {
    final result = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) startDate.value = result;
  }

  Future<void> pickEndDate(BuildContext context) async {
    final result = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? startDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) endDate.value = result;
  }

  Future<void> pickLeaveType(BuildContext context) async {
    final result = await SelectionBottomSheet.show(
      context,
      title: 'Select  leave type',
      options: leaveTypeOptions,
      selectedValue: leaveType.value,
    );
    if (result != null) leaveType.value = result;
  }

  Future<void> pickCertifyAuthorize(BuildContext context) async {
    final result = await SelectionBottomSheet.show(
      context,
      title: 'Choose Certify Authorize',
      options: authorizeOptions,
      selectedValue: certifyAuthorize.value,
    );
    if (result != null) certifyAuthorize.value = result;
  }

  /// Hook up an image picker package (e.g. image_picker) here.
  Future<void> pickImage() async {
    // TODO: integrate an image picker package and store the file path.
  }

  Future<void> submit() async {
    if (startDate.value == null || endDate.value == null || leaveType.value == null) {
      Get.snackbar('Missing information', 'Please fill in all required fields.');
      return;
    }

    isSubmitting.value = true;
    try {
      // TODO: send the request to your API / repository here.
      final leaveController = Get.find<LeaveController>();
      leaveController.addRequest(
        LeaveRequest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          leaveType: leaveType.value!,
          startDate: startDate.value!,
          endDate: endDate.value!,
          reason: reasonController.text,
          status: LeaveStatus.pending,
        ),
      );
      Get.back();
    } finally {
      isSubmitting.value = false;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}