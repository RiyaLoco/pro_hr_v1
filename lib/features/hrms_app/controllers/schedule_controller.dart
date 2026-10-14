import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

/// A single event shown under "Today Events" for the selected date.
class ScheduleEvent {
  final String title;
  final String timeLabel; // e.g. 'Today, 10:00 AM'
  final String relativeLabel; // e.g. 'In 2 hours'

  const ScheduleEvent({
    required this.title,
    required this.timeLabel,
    required this.relativeLabel,
  });
}

/// Controller for the Schedule screen — holds the visible month, the
/// selected date, and that date's events.
class ScheduleController extends GetxController {
  final Rx<DateTime> currentMonth =
      DateTime(DateTime.now().year, DateTime.now().month).obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxMap<DateTime, List<ScheduleEvent>> eventsByDate =
      <DateTime, List<ScheduleEvent>>{}.obs;
  final RxBool isLoading = false.obs;

  List<ScheduleEvent> get selectedDateEvents =>
      eventsByDate[_dateKey(selectedDate.value)] ?? [];

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  /// Loads the events map. Replace the body with a real API /
  /// repository call when ready.
  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      // TODO: replace with real data source (API, local DB, etc.)
      eventsByDate.value = {};
    } finally {
      isLoading.value = false;
    }
  }

  void selectDate(DateTime date) => selectedDate.value = date;

  void nextMonth() {
    final month = currentMonth.value;
    currentMonth.value = DateTime(month.year, month.month + 1, 1);
  }

  void previousMonth() {
    final month = currentMonth.value;
    currentMonth.value = DateTime(month.year, month.month - 1, 1);
  }

  DateTime _dateKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}