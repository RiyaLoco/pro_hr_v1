String formatAttendanceNumber(double value) =>
    value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

double? _number(dynamic value) {
  final result = double.tryParse('${value ?? ''}');
  return result != null && result.isFinite ? result : null;
}

class AttendanceSummary {
  const AttendanceSummary({
    this.totalHours,
    this.onTimePercentage,
    this.leaveDays,
    this.weeklyProgress,
  });

  final double? totalHours;
  final double? onTimePercentage;
  final double? leaveDays;
  final WeeklyAttendanceProgress? weeklyProgress;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    final weekly = json['weekly_progress'];
    return AttendanceSummary(
      totalHours: _number(json['total_hours']),
      onTimePercentage: _number(json['on_time_percentage']),
      leaveDays: _number(json['leave_days']),
      weeklyProgress: weekly is Map<String, dynamic>
          ? WeeklyAttendanceProgress.fromJson(weekly)
          : null,
    );
  }
}

class WeeklyAttendanceProgress {
  const WeeklyAttendanceProgress({
    this.from,
    this.to,
    this.workedHours,
    this.targetHours,
    this.percentage,
  });

  final DateTime? from;
  final DateTime? to;
  final double? workedHours;
  final double? targetHours;
  final double? percentage;

  double get progress {
    if (percentage != null) return (percentage! / 100).clamp(0.0, 1.0);
    if (workedHours == null || targetHours == null || targetHours! <= 0) {
      return 0;
    }
    return (workedHours! / targetHours!).clamp(0.0, 1.0);
  }

  String get hoursLabel =>
      '${workedHours == null ? '—' : formatAttendanceNumber(workedHours!)}/'
      '${targetHours == null ? '—' : formatAttendanceNumber(targetHours!)}';

  String get message {
    if (targetHours == null || workedHours == null) {
      return 'Weekly progress is unavailable.';
    }
    if (targetHours! <= 0) return 'No scheduled hours this week.';
    final remaining = targetHours! - workedHours!;
    if (remaining <= 0) return 'You have reached your weekly goal.';
    return '${formatAttendanceNumber(remaining)} hours remaining this week.';
  }

  factory WeeklyAttendanceProgress.fromJson(Map<String, dynamic> json) =>
      WeeklyAttendanceProgress(
        from: DateTime.tryParse('${json['from'] ?? ''}'),
        to: DateTime.tryParse('${json['to'] ?? ''}'),
        workedHours: _number(json['worked_hours']),
        targetHours: _number(json['target_hours']),
        percentage: _number(json['percentage']),
      );
}
