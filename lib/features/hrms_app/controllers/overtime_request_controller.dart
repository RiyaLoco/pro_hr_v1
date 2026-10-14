import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';
import 'package:test_flutter/utils/constants/image_string.dart';

/// Controller backing the Overtime Request form screen.
class OvertimeRequestController extends GetxController {
  static const List<SelectionOption> hoursOptions = [
    SelectionOption(value: '1 Hour', title: '1 Hour'),
    SelectionOption(value: '2 Hours', title: '2 Hours'),
    SelectionOption(value: '3 Hours', title: '3 Hours'),
    SelectionOption(value: '4 Hours', title: '4 Hours'),
    SelectionOption(value: 'Custom', title: 'Custom'),
  ];

  static const List<SelectionOption> rateOptions = [
    SelectionOption(value: '1.5x', title: '1.5x — Weekday'),
    SelectionOption(value: '2x', title: '2x — Weekend'),
    SelectionOption(value: '3x', title: '3x — Public Holiday'),
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

  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxnString hoursWorked = RxnString();
  final RxnString overtimeRate = RxnString();
  final RxnString certifyAuthorize = RxnString();
  final RxBool isSubmitting = false.obs;

  String get startDateLabel =>
      startDate.value == null ? 'Start Date' : _formatDate(startDate.value!);

  String get endDateLabel =>
      endDate.value == null ? 'End Date' : _formatDate(endDate.value!);

  String get hoursWorkedLabel => hoursWorked.value ?? 'Hours Worked';

  String get overtimeRateLabel => overtimeRate.value ?? 'Overtime Rate';

  String get certifyAuthorizeLabel =>
      certifyAuthorize.value ?? 'Certify Authorize';

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

  Future<void> pickHoursWorked(BuildContext context) async {
    final result = await SelectionBottomSheet.show(
      context,
      title: 'Hours Worked',
      options: hoursOptions,
      selectedValue: hoursWorked.value,
    );
    if (result != null) hoursWorked.value = result;
  }

  Future<void> pickOvertimeRate(BuildContext context) async {
    final result = await SelectionBottomSheet.show(
      context,
      title: 'Overtime Rate',
      options: rateOptions,
      selectedValue: overtimeRate.value,
    );
    if (result != null) overtimeRate.value = result;
  }

  Future<void> pickCertifyAuthorize(BuildContext context) async {
    final result = await SelectionBottomSheet.show(
      context,
      title: 'Certify Authorize',
      options: authorizeOptions,
      selectedValue: certifyAuthorize.value,
    );
    if (result != null) certifyAuthorize.value = result;
  }

  Future<void> submit() async {
    if (startDate.value == null || endDate.value == null || hoursWorked.value == null) {
      Get.snackbar('Missing information', 'Please fill in all required fields.');
      return;
    }

    isSubmitting.value = true;
    try {
      // TODO: send the request to your API / repository here.
      final overtimeController = Get.find<OvertimeController>();
      overtimeController.addEntry(
        OvertimeEntry(
          date: _formatDate(startDate.value!),
          title: reasonController.text.isEmpty ? 'Overtime Request' : reasonController.text,
          hoursLabel: hoursWorked.value!,
          personLabel: 'Pending with : ${certifyAuthorize.value ?? '-'}',
          status: OvertimeStatus.pending,
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