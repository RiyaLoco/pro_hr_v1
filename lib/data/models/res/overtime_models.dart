import 'package:intl/intl.dart';

enum OvertimeStatus { pending, approved, reject, unknown }

extension OvertimeStatusLabel on OvertimeStatus {
  String get label => switch (this) {
    OvertimeStatus.pending => 'Pending',
    OvertimeStatus.approved => 'Approved',
    OvertimeStatus.reject => 'Rejected',
    OvertimeStatus.unknown => 'Unknown',
  };
}

OvertimeStatus parseOvertimeStatus(String? value) =>
    switch (value?.trim().toLowerCase()) {
      'pending' => OvertimeStatus.pending,
      'approved' || 'approve' => OvertimeStatus.approved,
      'rejected' || 'reject' => OvertimeStatus.reject,
      _ => OvertimeStatus.unknown,
    };

String formatOtNumber(double value) =>
    value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

int? _id(dynamic value) => int.tryParse('${value ?? ''}');
double? _number(dynamic value) {
  final number = double.tryParse('${value ?? ''}');
  return number != null && number.isFinite ? number : null;
}

String? _name(dynamic value) => value is Map ? value['name']?.toString() : null;

/// Matches the web application's OtRate model.
class OtRate {
  const OtRate({
    required this.id,
    required this.name,
    required this.multiplier,
    this.description = '',
    this.createdBy,
  });

  final int id;
  final String name;
  final double multiplier;
  final String description;
  final int? createdBy;

  String get label => '$name · ${formatOtNumber(multiplier)}×';

  factory OtRate.fromJson(Map<String, dynamic> json) {
    final id = _id(json['id']);
    final multiplier = _number(json['multiplier']);
    if (id == null || multiplier == null || multiplier <= 0) {
      throw const FormatException(
        'An overtime rate needs an ID and positive multiplier.',
      );
    }
    return OtRate(
      id: id,
      name: '${json['name'] ?? ''}',
      multiplier: multiplier,
      description: '${json['description'] ?? ''}',
      createdBy: _id(json['created_by']),
    );
  }
}

/// One request with its optional Eloquent relations (ot_rate, approvedby, createdby).
class OtRequest {
  const OtRequest({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.hours,
    required this.otRateId,
    required this.reason,
    required this.status,
    this.rate,
    this.approvedBy,
    this.createdBy,
    this.approverName,
    this.creatorName,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int employeeId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double hours;
  final int otRateId;
  final String reason;
  final OvertimeStatus status;
  final OtRate? rate;
  final int? approvedBy;
  final int? createdBy;
  final String? approverName;
  final String? creatorName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get dateLabel => DateFormat('MMM d, yyyy').format(date);
  String get hoursLabel =>
      '${formatOtNumber(hours)} ${hours == 1 ? 'hour' : 'hours'}';
  String get timeLabel => '${_clock(startTime)} – ${_clock(endTime)}';
  String get rateLabel => rate?.label ?? 'Rate #$otRateId';
  String get reviewerLabel =>
      approverName == null || approverName!.trim().isEmpty
      ? (status == OvertimeStatus.pending
            ? 'Awaiting review'
            : 'Reviewer unavailable')
      : 'Reviewed by $approverName';

  factory OtRequest.fromJson(Map<String, dynamic> json) {
    final id = _id(json['id']);
    final employeeId = _id(json['employee_id']);
    final date = DateTime.tryParse('${json['date'] ?? ''}');
    final rateJson = json['ot_rate'];
    final rate = rateJson is Map<String, dynamic>
        ? OtRate.fromJson(rateJson)
        : null;
    final rateId = _id(json['ot_rate_id']) ?? rate?.id;
    final hours = _number(json['hours']);
    if (id == null ||
        employeeId == null ||
        date == null ||
        rateId == null ||
        hours == null ||
        hours < 0) {
      throw const FormatException('Invalid overtime request.');
    }
    return OtRequest(
      id: id,
      employeeId: employeeId,
      date: date,
      startTime: '${json['start_time'] ?? ''}',
      endTime: '${json['end_time'] ?? ''}',
      hours: hours,
      otRateId: rateId,
      reason: '${json['reason'] ?? ''}',
      status: parseOvertimeStatus(json['status']?.toString()),
      rate: rate,
      approvedBy: _id(json['approved_by']),
      createdBy: _id(json['created_by']),
      approverName: _name(json['approvedby']),
      creatorName: _name(json['createdby']),
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}'),
    );
  }

  static String _clock(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first);
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return time.isEmpty ? '—' : time;
    }
    return DateFormat('h:mm a').format(DateTime(2000, 1, 1, hour, minute));
  }
}
