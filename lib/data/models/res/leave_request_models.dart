/// Status shown on the Leave tabs.
enum LeaveStatus { pending, rejected, approved }

extension LeaveStatusX on LeaveStatus {
  /// Text shown on the tab and the status badge.
  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.rejected:
        return 'Reject';
      case LeaveStatus.approved:
        return 'Approved';
    }
  }

  List<String> get apiValues {
    switch (this) {
      case LeaveStatus.pending:
        return ['pending'];
      case LeaveStatus.rejected:
        return ['rejected'];
      case LeaveStatus.approved:
        return ['approved', 'acknowledge', 'acknowledged'];
    }
  }
}

LeaveStatus? parseLeaveStatus(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'pending':
    case 'waiting':
      return LeaveStatus.pending;
    case 'acknowledge':
    case 'acknowledged':
    case 'approved':
    case 'approve':
      return LeaveStatus.approved;
    case 'rejected':
    case 'reject':
    case 'declined':
      return LeaveStatus.rejected;
    default:
      return null;
  }
}

DateTime? _parseDate(dynamic raw) {
  final text = '${raw ?? ''}';
  if (text.length < 10) return null;
  return DateTime.tryParse(text.substring(0, 10));
}

DateTime? _parseDateTime(dynamic raw) {
  final text = '${raw ?? ''}'.trim();
  if (text.isEmpty || text == 'null') return null;
  final parsed = DateTime.tryParse(text);
  if (parsed == null) return null;
  return parsed.isUtc ? parsed.toLocal() : parsed;
}

/// One row from GET leave-types.
class LeaveType {
  final int id;
  final String name;
  final double daysPerYear;

  const LeaveType({
    required this.id,
    required this.name,
    required this.daysPerYear,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: int.tryParse('${json['id']}') ?? 0,
      name: '${json['name'] ?? ''}',
      daysPerYear: double.tryParse('${json['days_per_year']}') ?? 0,
    );
  }
}

/// One row from GET leave-requests.
String? _parseReviewer(dynamic value) {
  if (value is Map) value = value['name'];
  if (value is! String) return null;
  final text = value.trim();
  return text.isEmpty || num.tryParse(text) != null ? null : text;
}

String? _attachmentText(dynamic value) {
  if (value is! String) return null;
  final text = value.trim();
  return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
}

class LeaveRequest {
  final String id;
  final int leaveTypeId;
  final String leaveType; // leave type name
  final DateTime startDate;
  final DateTime endDate;
  final double days;
  final String reason;
  final LeaveStatus status;
  final String rawStatus;
  final String? attachmentUrl;
  final DateTime? requestedAt;
  final String? approvedBy;
  final String? rejectedBy;

  const LeaveRequest({
    required this.id,
    required this.leaveTypeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    this.rawStatus = '',
    this.attachmentUrl,
    this.requestedAt,
    this.approvedBy,
    this.rejectedBy,
  });

  String get statusLabel => status.label;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    final type = json['leave_type'] as Map<String, dynamic>?;
    final rawStatus = json['status'] ?? json['leave_status'];
    final statusValue = rawStatus is Map
        ? (rawStatus['name'] ?? rawStatus['value'] ?? rawStatus['status'])
        : rawStatus;
    final statusText = statusValue?.toString().trim().toLowerCase() ?? '';
    final attachment =
        _attachmentText(json['attachment_url']) ??
        _attachmentText(json['attachment']);
    return LeaveRequest(
      id: '${json['id']}',
      leaveTypeId: int.tryParse('${type?['id'] ?? json['leave_type_id']}') ?? 0,
      leaveType: '${type?['name'] ?? ''}',
      startDate: _parseDate(json['start_date']) ?? DateTime.now(),
      endDate: _parseDate(json['end_date']) ?? DateTime.now(),
      // decimal columns arrive as strings like "1.0"
      days: double.tryParse('${json['days']}') ?? 1,
      reason: '${json['reason'] ?? ''}',
      status: parseLeaveStatus(statusValue?.toString()) ?? LeaveStatus.pending,
      rawStatus: statusText,
      attachmentUrl: (attachment == null || attachment.isEmpty)
          ? null
          : attachment,
      requestedAt: _parseDateTime(json['requested_at'] ?? json['created_at']),
      approvedBy:
          _parseReviewer(json['approved_by_name']) ??
          _parseReviewer(json['approved_by']),
      rejectedBy:
          _parseReviewer(json['rejected_by_name']) ??
          _parseReviewer(json['rejected_by']),
    );
  }
}
