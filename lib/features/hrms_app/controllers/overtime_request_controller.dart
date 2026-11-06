import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/overtime_models.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class OvertimeRequestController extends GetxController {
  OvertimeRequestController({OvertimeController? overtime})
    : _overtime = overtime;
  final OvertimeController? _overtime;
  OvertimeController get overtime =>
      _overtime ?? Get.find<OvertimeController>();

  final reasonController = TextEditingController();
  final Rxn<DateTime> date = Rxn<DateTime>();
  final Rxn<TimeOfDay> startTime = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> endTime = Rxn<TimeOfDay>();
  final Rxn<OtRate> rate = Rxn<OtRate>();
  final RxnString validationError = RxnString();

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;
  bool get endsNextDay =>
      startTime.value != null &&
      endTime.value != null &&
      _minutes(endTime.value!) < _minutes(startTime.value!);
  double? get hours {
    final start = startTime.value;
    final end = endTime.value;
    if (start == null || end == null) return null;
    var minutes = _minutes(end) - _minutes(start);
    if (minutes < 0) minutes += 24 * 60;
    return minutes / 60;
  }

  String get dateLabel => date.value == null
      ? 'Overtime date'
      : '${date.value!.day}/${date.value!.month}/${date.value!.year}';
  String get hoursLabel => hours == null
      ? 'Select start and end times'
      : '${formatOtNumber(hours!)} ${hours == 1 ? 'hour' : 'hours'}';

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date.value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      builder: _theme,
    );
    if (picked != null) date.value = picked;
  }

  Future<void> pickTime(BuildContext context, {required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (start ? startTime.value : endTime.value) ??
          (start
              ? const TimeOfDay(hour: 17, minute: 0)
              : const TimeOfDay(hour: 19, minute: 0)),
      builder: _theme,
    );
    if (picked != null) {
      if (start) {
        startTime.value = picked;
      } else {
        endTime.value = picked;
      }
    }
  }

  Future<void> pickRate(BuildContext context) async {
    final selected = await SelectionBottomSheet.show(
      context,
      title: 'Overtime rate',
      selectedValue: rate.value?.id.toString(),
      options: overtime.rates
          .map(
            (r) => SelectionOption(
              value: '${r.id}',
              title: r.label,
              subtitle: r.description,
            ),
          )
          .toList(),
    );
    if (selected != null) {
      rate.value = overtime.rates.firstWhere((r) => '${r.id}' == selected);
    }
  }

  bool savePreview() {
    if (date.value == null ||
        startTime.value == null ||
        endTime.value == null) {
      validationError.value =
          'Choose an overtime date, start time, and end time.';
      return false;
    }
    if (hours == null || hours! <= 0) {
      validationError.value = 'Start and end times must be different.';
      return false;
    }
    if (rate.value == null) {
      validationError.value = 'Choose an overtime rate.';
      return false;
    }
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      validationError.value = 'Enter a reason for overtime.';
      return false;
    }
    validationError.value = null;
    overtime.addEntry(
      OtRequest(
        id: overtime.nextPreviewId,
        employeeId: 1,
        date: date.value!,
        startTime: _apiTime(startTime.value!),
        endTime: _apiTime(endTime.value!),
        hours: hours!,
        otRateId: rate.value!.id,
        rate: rate.value,
        reason: reason,
        status: OvertimeStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    overtime.resetFilters();
    return true;
  }

  String _apiTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  Widget _theme(BuildContext context, Widget? child) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: PColor.primary,
        onPrimary: Colors.white,
        onSurface: Colors.black87,
      ),
    ),
    child: child!,
  );

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}
