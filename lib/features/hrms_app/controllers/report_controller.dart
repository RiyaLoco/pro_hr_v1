import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

/// A single day's worked hours, used to draw the weekly attendance
/// mini bar-chart.
class DailyHours {
  final String dayLabel; // e.g. 'Mon'
  final double hours;

  const DailyHours({required this.dayLabel, required this.hours});
}

/// A downloadable report entry shown in the "My Reports" list.
class ReportItem {
  final String title;
  final String subtitle; // e.g. date range covered
  final IconData icon;

  const ReportItem({
    required this.title,
    required this.subtitle,
    this.icon = Icons.description_outlined,
  });
}

/// Controller for the employee Report screen — summary stats, the
/// weekly attendance chart data, and the list of downloadable reports.
class ReportController extends GetxController {
  final RxString attendanceRate = '92%'.obs;
  final RxString totalLeaveDays = '12d'.obs;
  final RxString totalOvertimeHours = '18h'.obs;

  final RxList<DailyHours> weeklyHours = <DailyHours>[].obs;
  final RxList<ReportItem> reports = <ReportItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReportData();
  }

  /// Loads summary stats, chart data, and the report list. Replace
  /// the body with a real API / repository call when ready.
  Future<void> fetchReportData() async {
    isLoading.value = true;
    try {
      // TODO: replace with real data source (API, local DB, etc.)
      weeklyHours.value = const [
        DailyHours(dayLabel: 'Mon', hours: 8),
        DailyHours(dayLabel: 'Tue', hours: 7.5),
        DailyHours(dayLabel: 'Wed', hours: 8),
        DailyHours(dayLabel: 'Thu', hours: 6),
        DailyHours(dayLabel: 'Fri', hours: 8),
        DailyHours(dayLabel: 'Sat', hours: 0),
        DailyHours(dayLabel: 'Sun', hours: 0),
      ];

      reports.value = const [
        ReportItem(
          title: 'Monthly Attendance Report',
          subtitle: 'June 2026',
          icon: Icons.event_available_outlined,
        ),
        ReportItem(
          title: 'Leave Summary',
          subtitle: 'Jan - Jun 2026',
          icon: Icons.beach_access_outlined,
        ),
        ReportItem(
          title: 'Overtime Summary',
          subtitle: 'June 2026',
          icon: Icons.access_time,
        ),
        ReportItem(
          title: 'Payslip',
          subtitle: 'June 2026',
          icon: Icons.receipt_long_outlined,
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  /// Hook up actual file generation/download here.
  Future<void> downloadReport(ReportItem report) async {
    // TODO: generate/download the report file.
  }
}