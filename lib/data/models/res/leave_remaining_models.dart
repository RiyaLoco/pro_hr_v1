class LeaveBalance {
  const LeaveBalance({
    required this.year,
    required this.daysEntitled,
    required this.daysUsed,
    required this.daysRemaining,
    this.leaveTypeId,
  });

  final int year;
  final int? leaveTypeId;
  final double daysEntitled;
  final double daysUsed;
  final double daysRemaining;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    final year = int.tryParse('${json['year']}');
    if (year == null) {
      throw const FormatException('Expected a year for the leave balance.');
    }
    return LeaveBalance(
      year: year,
      leaveTypeId: int.tryParse('${json['leave_type_id']}'),
      daysEntitled: _days(json['days_entitled']),
      daysUsed: _days(json['days_used']),
      daysRemaining: _days(json['days_remaining']),
    );
  }

  static double _days(dynamic value) {
    final days = double.tryParse('$value');
    if (days == null || !days.isFinite) {
      throw const FormatException('Expected a numeric leave balance.');
    }
    return days;
  }
}
