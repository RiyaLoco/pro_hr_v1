const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String? _clean(dynamic value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty || text == 'null') ? null : text;
}

DateTime? _parseDay(dynamic raw) {
  final text = _clean(raw);
  if (text == null || text.length < 10) return null;
  return DateTime.tryParse(text.substring(0, 10));
}

DateTime? _parseDateTime(dynamic raw) {
  final text = _clean(raw);
  if (text == null) return null;
  final parsed = DateTime.tryParse(text);
  if (parsed == null) return null;
  return parsed.isUtc ? parsed.toLocal() : parsed; // Laravel sends UTC
}

/// '08:00:00' -> '8:00 AM'
String formatShiftClock(String? hms) {
  if (hms == null) return '';
  final parts = hms.split(':');
  if (parts.length < 2) return '';
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return '';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
}

/// '8:00 AM - 5:00 PM'
String formatShiftRange(String? start, String? end) {
  final s = formatShiftClock(start);
  final e = formatShiftClock(end);
  if (s.isEmpty) return e;
  if (e.isEmpty) return s;
  return '$s - $e';
}

/// 'Mon, 26 Oct 2026'
String formatWeekdayDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

/// '26 Oct 2026, 8:42 AM'
String formatRequestedAt(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_months[d.month - 1]} ${d.year}, $h12:$minute ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// One working day assigned to the employee (a schedule_details row).
class WorkSchedule {
  final int id;
  final int scheduleId;
  final DateTime date;
  final String? startTime; // 'HH:mm:ss' (the day's own time, else the shift's)
  final String? endTime;
  final int shiftId;
  final String shiftName;
  final String scheduleName;

  const WorkSchedule({
    required this.id,
    required this.scheduleId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.shiftId,
    required this.shiftName,
    required this.scheduleName,
  });

  String get timeLabel => formatShiftRange(startTime, endTime);

  /// Today or later (a past day can't be changed).
  bool get isTodayOrLater {
    final now = DateTime.now();
    return !date.isBefore(DateTime(now.year, now.month, now.day));
  }

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    final shift = json['shift'] is Map ? json['shift'] as Map : const {};
    final schedule = json['schedule'] is Map ? json['schedule'] as Map : const {};

    return WorkSchedule(
      id: int.tryParse('${json['id']}') ?? 0,
      scheduleId: int.tryParse('${json['schedule_id']}') ?? 0,
      date: _parseDay(json['date']) ?? DateTime.now(),
      startTime: _clean(json['start_time']) ?? _clean(shift['start_time']),
      endTime: _clean(json['end_time']) ?? _clean(shift['end_time']),
      shiftId: int.tryParse('${json['shift_id']}') ?? 0,
      shiftName: _clean(shift['shift_name']) ?? 'Shift',
      scheduleName: _clean(schedule['name']) ?? '',
    );
  }
}

/// A shift type the employee can ask to move to.
class ShiftOption {
  final int id;
  final String name;
  final String? startTime;
  final String? endTime;

  const ShiftOption({
    required this.id,
    required this.name,
    this.startTime,
    this.endTime,
  });

  String get timeLabel => formatShiftRange(startTime, endTime);

  factory ShiftOption.fromJson(Map<String, dynamic> json) {
    return ShiftOption(
      id: int.tryParse('${json['id']}') ?? 0,
      name: _clean(json['shift_name']) ?? 'Shift',
      startTime: _clean(json['start_time']),
      endTime: _clean(json['end_time']),
    );
  }
}

enum ShiftRequestStatus { pending, approved, rejected }

extension ShiftRequestStatusX on ShiftRequestStatus {
  String get label {
    switch (this) {
      case ShiftRequestStatus.pending:
        return 'Pending';
      case ShiftRequestStatus.approved:
        return 'Approved';
      case ShiftRequestStatus.rejected:
        return 'Rejected';
    }
  }
}

ShiftRequestStatus parseShiftRequestStatus(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'approved':
    case 'approve':
      return ShiftRequestStatus.approved;
    case 'rejected':
    case 'reject':
    case 'declined':
      return ShiftRequestStatus.rejected;
    default:
      return ShiftRequestStatus.pending;
  }
}

/// One of the employee's shift change requests.
class ShiftRequestItem {
  final int id;
  final int scheduleDetailId;
  final DateTime? date;
  final String oldShiftName;
  final String oldTime;
  final String newShiftName;
  final String newTime;
  final String reason;
  final ShiftRequestStatus status;
  final DateTime? requestedAt;
  final String? approvedBy;

  const ShiftRequestItem({
    required this.id,
    required this.scheduleDetailId,
    required this.date,
    required this.oldShiftName,
    required this.oldTime,
    required this.newShiftName,
    required this.newTime,
    required this.reason,
    required this.status,
    required this.requestedAt,
    required this.approvedBy,
  });

  factory ShiftRequestItem.fromJson(Map<String, dynamic> json) {
    final oldShift = json['old_shift'] is Map ? json['old_shift'] as Map : const {};
    final newShift = json['new_shift'] is Map ? json['new_shift'] as Map : const {};

    return ShiftRequestItem(
      id: int.tryParse('${json['id']}') ?? 0,
      scheduleDetailId: int.tryParse('${json['schedule_detail']}') ?? 0,
      date: _parseDay(json['date']),
      oldShiftName: _clean(oldShift['name']) ?? '-',
      oldTime: formatShiftRange(_clean(oldShift['start_time']), _clean(oldShift['end_time'])),
      newShiftName: _clean(newShift['name']) ?? '-',
      newTime: formatShiftRange(_clean(newShift['start_time']), _clean(newShift['end_time'])),
      reason: _clean(json['reason']) ?? '',
      status: parseShiftRequestStatus(json['status']?.toString()),
      requestedAt: _parseDateTime(json['requested_at']),
      approvedBy: _clean(json['approved_by']),
    );
  }
}