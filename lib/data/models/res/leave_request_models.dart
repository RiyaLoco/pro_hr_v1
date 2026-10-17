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

}

LeaveStatus? parseLeaveStatus(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'pending':
    case 'waiting':
      return LeaveStatus.pending;
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
class LeaveRequest {
  final String id;
  final int leaveTypeId;
  final String leaveType; // leave type name
  final DateTime startDate;
  final DateTime endDate;
  final double days;
  final String reason;
  final LeaveStatus status;

  const LeaveRequest({
    required this.id,
    required this.leaveTypeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    final type = json['leave_type'] as Map<String, dynamic>?;
    final rawStatus = json['status'] ?? json['leave_status'];
    final statusValue = rawStatus is Map
        ? (rawStatus['name'] ?? rawStatus['value'] ?? rawStatus['status'])
        : rawStatus;
    return LeaveRequest(
      id: '${json['id']}',
      leaveTypeId: int.tryParse('${type?['id'] ?? json['leave_type_id']}') ?? 0,
      leaveType: '${type?['name'] ?? ''}',
      startDate: DateTime.parse('${json['start_date']}'),
      endDate: DateTime.parse('${json['end_date']}'),
      // decimal columns arrive as strings like "1.0"
      days: double.tryParse('${json['days']}') ?? 1,
      reason: '${json['reason'] ?? ''}',
      status: parseLeaveStatus(statusValue?.toString()) ?? LeaveStatus.pending,
    );
  }
}
