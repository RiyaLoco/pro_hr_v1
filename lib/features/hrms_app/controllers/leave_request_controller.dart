import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/leave_request_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/leave_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';
import 'package:test_flutter/utils/constants/colors.dart';

enum LeaveDuration { fullDay, halfMorning, halfAfternoon }

extension LeaveDurationX on LeaveDuration {
  String get label {
    switch (this) {
      case LeaveDuration.fullDay:
        return 'Full Day';
      case LeaveDuration.halfMorning:
        return 'Half Morning';
      case LeaveDuration.halfAfternoon:
        return 'Half Afternoon';
    }
  }

  bool get isHalf => this != LeaveDuration.fullDay;

  String? get reasonPrefix {
    switch (this) {
      case LeaveDuration.fullDay:
        return null;
      case LeaveDuration.halfMorning:
        return '[Half day - Morning]';
      case LeaveDuration.halfAfternoon:
        return '[Half day - Afternoon]';
    }
  }
}

class LeaveRequestController extends GetxController {
  static const int _maxFileBytes = 10 * 1024 * 1024;
  static const List<String> _allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  final TextEditingController reasonController = TextEditingController();
  final Rx<LeaveDuration> duration = LeaveDuration.fullDay.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rxn<LeaveType> leaveType = Rxn<LeaveType>();
  final RxList<LeaveType> leaveTypes = <LeaveType>[].obs;
  final Rxn<PlatformFile> attachment = Rxn<PlatformFile>();
  final RxBool isSubmitting = false.obs;

  final ApiController _api = ApiController();

  String get durationLabel => duration.value.label;

  String get startDateLabel =>
      startDate.value == null ? 'Start Date' : _formatDate(startDate.value!);

  String get endDateLabel =>
      endDate.value == null ? 'End Date' : _formatDate(endDate.value!);

  String get leaveTypeLabel => leaveType.value?.name ?? 'Select leave type';

  String get attachmentLabel {
    final file = attachment.value;
    if (file == null) return 'Upload Attachment';
    return file.name.length <= 28
        ? file.name
        : '${file.name.substring(0, 18)}...${file.name.substring(file.name.length - 7)}';
  }

  double get days {
    final start = startDate.value;
    if (start == null) return 0;
    if (duration.value.isHalf) return 0.5;
    final end = endDate.value;
    if (end == null) return 0;

    final s = DateTime.utc(start.year, start.month, start.day);
    final e = DateTime.utc(end.year, end.month, end.day);
    return (e.difference(s).inDays + 1).toDouble();
  }

  String get daysLabel {
    final value = days;
    final text = value == value.roundToDouble() ? '${value.toInt()}' : '$value';
    return '$text ${value == 1 ? 'day' : 'days'}';
  }

  @override
  void onInit() {
    super.onInit();
    loadLeaveTypes();
  }

  Future<void> loadLeaveTypes() async {
    try {
      leaveTypes.assignAll(await _api.fetchLeaveTypes());
    } on ApiException catch (e) {
      Get.snackbar('Error', e.displayMessage);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final serverMessage = body is Map ? body['message']?.toString() : null;
      Get.snackbar(
        'Could not load leave types',
        serverMessage ??
            (status != null
                ? 'The server returned HTTP $status. Please try again.'
                : 'Cannot reach the server. Check your connection and try again.'),
      );
    } on FormatException {
      Get.snackbar(
        'Could not load leave types',
        'The server returned an unexpected leave type response.',
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Loading leave types failed: $error\n$stackTrace');
      }
      Get.snackbar(
        'Could not load leave types',
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<void> pickDuration(BuildContext context) async {
    final result = await SelectionBottomSheet.show(
      context,
      title: 'Select time',
      options: LeaveDuration.values
          .map((d) => SelectionOption(value: d.name, title: d.label))
          .toList(),
      selectedValue: duration.value.name,
    );
    if (result == null) return;
    duration.value = LeaveDuration.values.firstWhere((d) => d.name == result);
    if (duration.value.isHalf && startDate.value != null) {
      endDate.value = startDate.value;
    }
  }

  DateTime _tomorrow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> pickStartDate(BuildContext context) async {
    final tomorrow = _tomorrow();
    final result = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? tomorrow,
      firstDate: tomorrow,
      lastDate: tomorrow.add(const Duration(days: 365)),
      builder: _pickerTheme,
    );
    if (result == null) return;
    startDate.value = result;

    if (duration.value.isHalf) {
      endDate.value = result;
    } else if (endDate.value != null && endDate.value!.isBefore(result)) {
      endDate.value = null;
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    if (duration.value.isHalf) return;

    final first = startDate.value ?? _tomorrow();
    final result = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365)),
      builder: _pickerTheme,
    );
    if(result != null) endDate.value = result;
  }

  Future<void> pickLeaveType(BuildContext context) async {
    if (leaveTypes.isEmpty) {
      await loadLeaveTypes();
      if (leaveTypes.isEmpty) return;
    }
 
    final result = await SelectionBottomSheet.show(
      context,
      title: 'Select leave type',
      options: leaveTypes
          .map((t) => SelectionOption(value: '${t.id}', title: t.name))
          .toList(),
      selectedValue: leaveType.value == null ? null : '${leaveType.value!.id}',
    );
    if (result != null) {
      leaveType.value = leaveTypes.firstWhere((t) => '${t.id}' == result);
    }
  }

  Future<void> pickAttachment() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    if (file == null) return;

    if (file.path == null) {
      Get.snackbar('Error', 'Could not read that file. Try another one.');
      return;
    }
    final fileSize = await file.length();
    if (fileSize == null) {
      Get.snackbar('Error', 'Could not read that file. Try another one.');
      return;
    }
    if (fileSize > _maxFileBytes) {
      Get.snackbar('File too large', 'Please choose a file under 10 MB.');
      return;
    }
    attachment.value = file;
  }
  String? _validate() {
    if (leaveType.value == null) return 'Please choose a leave type.';
    if (startDate.value == null) return 'Please choose a start date.';
    if (endDate.value == null) return 'Please choose an end date.';
    if (reasonController.text.trim().isEmpty) return 'Please enter a reason.';
    if (attachment.value == null) return 'Please attach a document or image.';
    return null;
  }

  Future<void> submit() async {
    final problem = _validate();
    if (problem != null) {
      Get.snackbar('Missing information', problem);
      return;
    }
 
    final file = attachment.value!;
    final prefix = duration.value.reasonPrefix;
    final reasonText = reasonController.text.trim();
 
    isSubmitting.value = true;
    try {
      await _api.submitLeaveRequest(
        leaveTypeId: leaveType.value!.id,
        startDate: _apiDate(startDate.value!),
        endDate: _apiDate(endDate.value!),
        days: days,
        reason: prefix == null ? reasonText : '$prefix $reasonText',
        attachmentPath: file.path!,
        attachmentName: file.name,
      );
 
      // Show the new request: jump to the Pending tab and reload it.
      if (Get.isRegistered<LeaveController>()) {
        final list = Get.find<LeaveController>();
        list.selectedTab.value = LeaveStatus.pending;
        await list.fetchLeaveRequests();
      }
 
      Get.back();
      Get.snackbar('Submitted', 'Your leave request was sent.');
    } on ApiException catch (e) {
      // Validation errors, overlaps, "today or a past date", etc.
      Get.snackbar('Could not submit', e.displayMessage);
    } catch (_) {
      Get.snackbar('Could not submit', 'Check your connection and try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}

Widget _pickerTheme(BuildContext context, Widget? child) {
  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: PColor.primary,
        onPrimary: Colors.white,
        onSurface: PColor.textColor,
      ),
      datePickerTheme: DatePickerThemeData(dividerColor: PColor.primary),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: PColor.primary),
      ),
    ),
    child: child!,
  );
}
