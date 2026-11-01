// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';

// /// A single event shown under "Today Events" for the selected date.
// class ScheduleEvent {
//   final String title;
//   final String timeLabel; // e.g. 'Today, 10:00 AM'
//   final String relativeLabel; // e.g. 'In 2 hours'

//   const ScheduleEvent({
//     required this.title,
//     required this.timeLabel,
//     required this.relativeLabel,
//   });
// }

// /// Controller for the Schedule screen — holds the visible month, the
// /// selected date, and that date's events.
// class ScheduleController extends GetxController {
//   final Rx<DateTime> currentMonth =
//       DateTime(DateTime.now().year, DateTime.now().month).obs;
//   final Rx<DateTime> selectedDate = DateTime.now().obs;
//   final RxMap<DateTime, List<ScheduleEvent>> eventsByDate =
//       <DateTime, List<ScheduleEvent>>{}.obs;
//   final RxBool isLoading = false.obs;

//   List<ScheduleEvent> get selectedDateEvents =>
//       eventsByDate[_dateKey(selectedDate.value)] ?? [];

//   @override
//   void onInit() {
//     super.onInit();
//     fetchEvents();
//   }

//   /// Loads the events map. Replace the body with a real API /
//   /// repository call when ready.
//   Future<void> fetchEvents() async {
//     isLoading.value = true;
//     try {
//       // TODO: replace with real data source (API, local DB, etc.)
//       eventsByDate.value = {};
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void selectDate(DateTime date) => selectedDate.value = date;

//   void nextMonth() {
//     final month = currentMonth.value;
//     currentMonth.value = DateTime(month.year, month.month + 1, 1);
//   }

//   void previousMonth() {
//     final month = currentMonth.value;
//     currentMonth.value = DateTime(month.year, month.month - 1, 1);
//   }

//   DateTime _dateKey(DateTime date) =>
//       DateTime(date.year, date.month, date.day);
// }


import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/schedule_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/shift_request_controller.dart';


DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The employee's working schedule: the visible month, the selected day,
/// and the shifts assigned on each day.
class ScheduleController extends GetxController {
  final Rx<DateTime> currentMonth =
      DateTime(DateTime.now().year, DateTime.now().month).obs;
  final Rx<DateTime> selectedDate = _dateOnly(DateTime.now()).obs;
  final RxMap<DateTime, List<WorkSchedule>> schedulesByDate =
      <DateTime, List<WorkSchedule>>{}.obs;
  final RxBool isLoading = false.obs;

  final ApiController _api = ApiController();

  /// First cell of the 6x7 calendar grid for [month] (the Sunday on or
  /// before the 1st). The calendar widget uses the same function.
  static DateTime gridStart(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    return first.subtract(Duration(days: first.weekday % 7));
  }

  List<WorkSchedule> get selectedDaySchedules =>
      schedulesByDate[_dateOnly(selectedDate.value)] ?? const [];

  bool hasSchedule(DateTime day) => schedulesByDate.containsKey(_dateOnly(day));

  bool get isSelectedToday => _dateOnly(selectedDate.value) == _dateOnly(DateTime.now());

  String get selectedDateTitle =>
      isSelectedToday ? 'Today Schedule' : formatWeekdayDate(selectedDate.value);

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
  }

  /// Loads every working day shown in the calendar grid.
  Future<void> fetchSchedules() async {
    final month = currentMonth.value;
    final start = gridStart(month);
    final end = start.add(const Duration(days: 41));

    isLoading.value = true;
    try {
      final list = await _api.fetchSchedules(from: _apiDate(start), to: _apiDate(end));
      if (month != currentMonth.value) return; // user moved to another month

      final grouped = <DateTime, List<WorkSchedule>>{};
      for (final schedule in list) {
        grouped.putIfAbsent(_dateOnly(schedule.date), () => []).add(schedule);
      }
      for (final day in grouped.values) {
        day.sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));
      }
      schedulesByDate.assignAll(grouped);
    } on ApiException catch (e) {
      Get.snackbar('Schedule', e.displayMessage);
    } catch (_) {
      Get.snackbar('Schedule', 'Could not load your schedule. Check your connection.');
    } finally {
      if (month == currentMonth.value) isLoading.value = false;
    }
  }

  /// Pull-to-refresh: schedule and shift requests together.
  Future<void> refreshAll() async {
    await Future.wait([
      fetchSchedules(),
      if (Get.isRegistered<ShiftRequestController>())
        Get.find<ShiftRequestController>().fetchRequests(),
    ]);
  }

  void selectDate(DateTime date) {
    final day = _dateOnly(date);
    selectedDate.value = day;

    // Tapping a grey day from the next/previous month moves the calendar there.
    final month = DateTime(day.year, day.month);
    if (month != currentMonth.value) {
      currentMonth.value = month;
      fetchSchedules();
    }
  }

  void nextMonth() =>
      _goToMonth(DateTime(currentMonth.value.year, currentMonth.value.month + 1));

  void previousMonth() =>
      _goToMonth(DateTime(currentMonth.value.year, currentMonth.value.month - 1));

  void _goToMonth(DateTime month) {
    currentMonth.value = month;
    final now = DateTime.now();
    final isThisMonth = month.year == now.year && month.month == now.month;
    selectedDate.value = isThisMonth ? _dateOnly(now) : month;
    fetchSchedules();
  }

  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}