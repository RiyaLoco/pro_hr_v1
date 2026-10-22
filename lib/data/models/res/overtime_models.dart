

enum OvertimeStatus {
  pending,
  approved,
  reject,
}

extension OvertimeStatusLabel on OvertimeStatus {
  String get label {
    switch (this) {
      case OvertimeStatus.pending:
        return 'Pending';
      case OvertimeStatus.approved:
        return 'Approved';
      case OvertimeStatus.reject:
        return 'Rejected';
    }
  }
}

OvertimeStatus? parseOvertimeStatus(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'approve':
    case 'approved':
      return OvertimeStatus.approved;
    case 'reject':
    case 'rejected':
      return OvertimeStatus.reject;
    case 'cancelled':
    case 'canceled':
      return null;
    default:
      return OvertimeStatus.pending;
  }
}