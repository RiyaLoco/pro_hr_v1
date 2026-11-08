import 'package:intl/intl.dart';

import 'attendance_summary_models.dart';
import 'punch_models.dart';

/// One daily entry from `history`, rather than an individual punch event.
class AttendanceRecord {
  const AttendanceRecord({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.workedHours,
    this.lateMinutes,
    this.earlyMinutes,
    this.events = const [],
  });

  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final double? workedHours;
  final int? lateMinutes;
  final int? earlyMinutes;
  final List<PunchRecord> events;

  String get dateLabel {
    final parsed = DateTime.tryParse(date);
    return parsed == null ? date : DateFormat('MMM d, yyyy').format(parsed);
  }

  String get checkInLabel => formatTime(checkIn);
  String get checkOutLabel => formatTime(checkOut);
  String get statusLabel => status.replaceAll('_', ' ').toUpperCase();

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final date = json['date'];
    if (date is! String || DateTime.tryParse(date) == null) {
      throw const FormatException(
        'Attendance history must include a valid date.',
      );
    }
    final minutes = _number(json['worked_minutes']);
    return AttendanceRecord(
      date: date,
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      status: json['status']?.toString().trim().isNotEmpty == true
          ? json['status'].toString().trim()
          : 'unknown',
      workedHours:
          _number(json['worked_hours']) ??
          (minutes == null ? null : minutes / 60),
      lateMinutes: int.tryParse('${json['late_minutes']}'),
      earlyMinutes: int.tryParse('${json['early_minutes']}'),
      events: json['events'] is List
          ? List<PunchRecord>.unmodifiable(
              (json['events'] as List).whereType<Map<String, dynamic>>().map(
                PunchRecord.fromJson,
              ),
            )
          : const [],
    );
  }

  static double? _number(dynamic value) {
    final number = double.tryParse('${value ?? ''}');
    return number != null && number.isFinite ? number : null;
  }

  static String formatTime(String? time) {
    if (time == null || time.trim().isEmpty) return '—';
    final parts = time.trim().split(':');
    final hour = int.tryParse(parts.first);
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return time;
    }
    return DateFormat('hh:mm a').format(DateTime(2000, 1, 1, hour, minute));
  }
}

class AttendanceHistoryPage {
  const AttendanceHistoryPage({
    required this.records,
    required this.currentPage,
    required this.lastPage,
    this.summary,
  });

  final List<AttendanceRecord> records;
  final AttendanceSummary? summary;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;

  factory AttendanceHistoryPage.fromJson(Map<String, dynamic> json) {
    final history = json['history'];
    if (history is! List ||
        history.any((row) => row is! Map<String, dynamic>)) {
      throw const FormatException('Expected a daily attendance history list.');
    }
    // `meta` paginates raw events; daily history has its own pagination.
    final meta = json['history_meta'];
    final current = meta is Map
        ? int.tryParse('${meta['current_page']}')
        : null;
    final last = meta is Map ? int.tryParse('${meta['last_page']}') : null;
    if (current == null || last == null || current < 1 || last < current) {
      throw const FormatException(
        'Expected valid attendance history pagination.',
      );
    }
    final summary = json['summary'];
    return AttendanceHistoryPage(
      records: history
          .map((row) => AttendanceRecord.fromJson(row as Map<String, dynamic>))
          .where((record) {
            final status = record.status.trim().toLowerCase();
            return status == 'on_time' || status == 'late';
          })
          .toList(),
      summary: summary is Map<String, dynamic>
          ? AttendanceSummary.fromJson(summary)
          : null,
      currentPage: current,
      lastPage: last,
    );
  }
}
