// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:test_flutter/data/models/res/overtime_models.dart';
// import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
// import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';
// import 'package:test_flutter/utils/constants/colors.dart';

// class OvertimeRequestController extends GetxController {
//   OvertimeRequestController({OvertimeController? overtime})
//     : _overtime = overtime;
//   final OvertimeController? _overtime;
//   OvertimeController get overtime =>
//       _overtime ?? Get.find<OvertimeController>();

//   final reasonController = TextEditingController();
//   final Rxn<DateTime> date = Rxn<DateTime>();
//   final Rxn<TimeOfDay> startTime = Rxn<TimeOfDay>();
//   final Rxn<TimeOfDay> endTime = Rxn<TimeOfDay>();
//   final Rxn<OtRate> rate = Rxn<OtRate>();
//   final RxnString validationError = RxnString();

//   int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;
//   bool get endsNextDay =>
//       startTime.value != null &&
//       endTime.value != null &&
//       _minutes(endTime.value!) < _minutes(startTime.value!);
//   double? get hours {
//     final start = startTime.value;
//     final end = endTime.value;
//     if (start == null || end == null) return null;
//     var minutes = _minutes(end) - _minutes(start);
//     if (minutes < 0) minutes += 24 * 60;
//     return minutes / 60;
//   }

//   String get dateLabel => date.value == null
//       ? 'Overtime date'
//       : '${date.value!.day}/${date.value!.month}/${date.value!.year}';
//   String get hoursLabel => hours == null
//       ? 'Select start and end times'
//       : '${formatOtNumber(hours!)} ${hours == 1 ? 'hour' : 'hours'}';

//   Future<void> pickDate(BuildContext context) async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: date.value ?? now,
//       firstDate: DateTime(now.year - 1),
//       lastDate: DateTime(now.year + 1, 12, 31),
//       builder: _theme,
//     );
//     if (picked != null) date.value = picked;
//   }

//   Future<void> pickTime(BuildContext context, {required bool start}) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime:
//           (start ? startTime.value : endTime.value) ??
//           (start
//               ? const TimeOfDay(hour: 17, minute: 0)
//               : const TimeOfDay(hour: 19, minute: 0)),
//       builder: _theme,
//     );
//     if (picked != null) {
//       if (start) {
//         startTime.value = picked;
//       } else {
//         endTime.value = picked;
//       }
//     }
//   }

//   Future<void> pickRate(BuildContext context) async {
//     final selected = await SelectionBottomSheet.show(
//       context,
//       title: 'Overtime rate',
//       selectedValue: rate.value?.id.toString(),
//       options: overtime.rates
//           .map(
//             (r) => SelectionOption(
//               value: '${r.id}',
//               title: r.label,
//               subtitle: r.description,
//             ),
//           )
//           .toList(),
//     );
//     if (selected != null) {
//       rate.value = overtime.rates.firstWhere((r) => '${r.id}' == selected);
//     }
//   }

//   bool savePreview() {
//     if (date.value == null ||
//         startTime.value == null ||
//         endTime.value == null) {
//       validationError.value =
//           'Choose an overtime date, start time, and end time.';
//       return false;
//     }
//     if (hours == null || hours! <= 0) {
//       validationError.value = 'Start and end times must be different.';
//       return false;
//     }
//     if (rate.value == null) {
//       validationError.value = 'Choose an overtime rate.';
//       return false;
//     }
//     final reason = reasonController.text.trim();
//     if (reason.isEmpty) {
//       validationError.value = 'Enter a reason for overtime.';
//       return false;
//     }
//     validationError.value = null;
//     overtime.addEntry(
//       OtRequest(
//         id: overtime.nextPreviewId,
//         employeeId: 1,
//         date: date.value!,
//         startTime: _apiTime(startTime.value!),
//         endTime: _apiTime(endTime.value!),
//         hours: hours!,
//         otRateId: rate.value!.id,
//         rate: rate.value,
//         reason: reason,
//         status: OvertimeStatus.pending,
//         createdAt: DateTime.now(),
//       ),
//     );
//     overtime.resetFilters();
//     return true;
//   }

//   String _apiTime(TimeOfDay time) =>
//       '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

//   Widget _theme(BuildContext context, Widget? child) => Theme(
//     data: Theme.of(context).copyWith(
//       colorScheme: ColorScheme.light(
//         primary: PColor.primary,
//         onPrimary: Colors.white,
//         onSurface: Colors.black87,
//       ),
//     ),
//     child: child!,
//   );

//   @override
//   void onClose() {
//     reasonController.dispose();
//     super.onClose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/overtime_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';
import 'package:test_flutter/utils/constants/colors.dart';

/// Overtime request form: date, start and end time, rate, reason.
class OvertimeRequestController extends GetxController {
  OvertimeRequestController({OvertimeController? overtime, ApiController? api})
    : _overtime = overtime,
      _api = api ?? ApiController();

  final OvertimeController? _overtime;
  final ApiController _api;
  OvertimeController get overtime =>
      _overtime ?? Get.find<OvertimeController>();

  final reasonController = TextEditingController();
  final Rxn<DateTime> date = Rxn<DateTime>();
  final Rxn<TimeOfDay> startTime = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> endTime = Rxn<TimeOfDay>();
  final Rxn<OtRate> rate = Rxn<OtRate>();
  final RxnString validationError = RxnString();
  final RxBool isSubmitting = false.obs;

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  bool get endsNextDay =>
      startTime.value != null &&
      endTime.value != null &&
      _minutes(endTime.value!) < _minutes(startTime.value!);

  /// Shown on screen. Goes past midnight when the end is before the start.
  double? get hours {
    final start = startTime.value;
    final end = endTime.value;
    if (start == null || end == null) return null;
    var minutes = _minutes(end) - _minutes(start);
    if (minutes < 0) minutes += 24 * 60;
    return minutes / 60;
  }

  /// What the API wants: end minus start on the same day, 2 decimals.
  double get _apiHours => double.parse(
    ((_minutes(endTime.value!) - _minutes(startTime.value!)) / 60)
        .toStringAsFixed(2),
  );

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
    await overtime.ensureRates();
    if (overtime.rates.isEmpty) return;
    if (!context.mounted) return;

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

  /// First problem with the form, or null when it is ready to send.
  String? _validate() {
    if (date.value == null ||
        startTime.value == null ||
        endTime.value == null) {
      return 'Choose an overtime date, start time, and end time.';
    }
    if (_minutes(endTime.value!) <= _minutes(startTime.value!)) {
      // The API compares times within one day, so it rejects this too.
      return 'The end time must be after the start time. '
          'Overtime cannot continue past midnight.';
    }
    if (rate.value == null) return 'Choose an overtime rate.';
    if (reasonController.text.trim().isEmpty) {
      return 'Enter a reason for overtime.';
    }
    return null;
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;

    final problem = _validate();
    validationError.value = problem;
    if (problem != null) return;

    isSubmitting.value = true;
    try {
      await _api.submitOvertimeRequest(
        date: _apiDate(date.value!),
        startTime: _apiTime(startTime.value!),
        endTime: _apiTime(endTime.value!),
        hours: _apiHours,
        otRateId: rate.value!.id,
        reason: reasonController.text,
      );

      // Show the new request (and refresh the stats) before leaving.
      await overtime.fetchEntries();
      overtime.resetFilters();

      Get.back();
      Get.snackbar('Submitted', 'Your overtime request was sent for approval.');
    } on ApiException catch (e) {
      validationError.value = e.displayMessage;
    } catch (_) {
      validationError.value =
          'Could not send your request. Check your connection and try again.';
    } finally {
      isSubmitting.value = false;
    }
  }

  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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