import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:test_flutter/features/hrms_app/controllers/leave_controller.dart';

/// Controller backing the Leaving Request form screen.
class LeaveRequestController extends GetxController {
  static const List<String> leaveTypeOptions = [
    'Sick Leave',
    'Casual Leave',
    'Annual Leave',
    'Unpaid Leave',
  ];

  static const List<String> authorizeOptions = [
    'Team Lead',
    'Project Manager',
    'HR Manager',
  ];

  final TextEditingController reasonController = TextEditingController();

  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxnString leaveType = RxnString();
  final RxnString certifyAuthorize = RxnString();
  final RxnString uploadedImagePath = RxnString();
  final RxBool isSubmitting = false.obs;

  String get timeLabel =>
      selectedTime.value == null ? 'Select time' : selectedTime.value!.format(Get.context!);

  String get startDateLabel =>
      startDate.value == null ? 'Start Date' : _formatDate(startDate.value!);

  String get endDateLabel =>
      endDate.value == null ? 'End Date' : _formatDate(endDate.value!);

  String get leaveTypeLabel => leaveType.value ?? 'Select leave type';

  String get certifyAuthorizeLabel => certifyAuthorize.value ?? 'Certify Authorize';

  Future<void> pickTime(BuildContext context) async {
    final result = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
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
    final result = await _showOptionsSheet(context, 'Select leave type', leaveTypeOptions);
    if (result != null) leaveType.value = result;
  }

  Future<void> pickCertifyAuthorize(BuildContext context) async {
    final result = await _showOptionsSheet(context, 'Certify Authorize', authorizeOptions);
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

  Future<String?> _showOptionsSheet(
    BuildContext context,
    String title,
    List<String> options,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...options.map(
              (option) => ListTile(
                title: Text(option),
                onTap: () => Navigator.of(context).pop(option),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}