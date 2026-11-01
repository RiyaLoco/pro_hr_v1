/// 'Check In' / 'check_in' / 'IN' -> 'in',  'Check Out' / 'OUT' -> 'out'.
/// Same normalisation the Laravel controller uses.
String? _directionFromName(String? name) {
  final normalized = (name ?? '').trim().toLowerCase().replaceAll(
    RegExp(r'[\s_-]+'),
    '',
  );
  switch (normalized) {
    case 'punchin':
    case 'checkin':
    case 'in':
      return 'in';
    case 'punchout':
    case 'checkout':
    case 'out':
      return 'out';
    default:
      return null;
  }
}

/// '350 m' / '1.25 km'
String formatMeters(double meters) => meters < 1000
    ? '${meters.round()} m'
    : '${(meters / 1000).toStringAsFixed(2)} km';

/// One row from the attendance types list.
class PunchType {
  final int id;
  final String name;

  const PunchType({required this.id, required this.name});

  /// 'in', 'out', or null when the name isn't clearly one of them.
  String? get direction => _directionFromName(name);

  factory PunchType.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id'] ?? json['attendance_type_id']}');
    if (id == null || id <= 0) {
      throw const FormatException(
        'Attendance type must have a positive integer ID.',
      );
    }
    return PunchType(
      id: id,
      name: '${json['name'] ?? json['type_name'] ?? ''}',
    );
  }
}

/// One punch from today's attendance list.
class PunchRecord {
  final String time; // 'HH:mm:ss' as stored by the server
  final String status;
  final String? direction; // 'in' | 'out'

  const PunchRecord({required this.time, required this.status, this.direction});

  /// The same statuses the API counts as a real punch.
  bool get accepted => const {
    'success',
    'pending',
    'success(via approval)',
  }.contains(status.trim().toLowerCase());

  factory PunchRecord.fromJson(Map<String, dynamic> json) {
    final compared = json['compared_values'];
    final type = json['type'];

    String? direction;
    if (compared is Map) {
      direction = _directionFromName('${compared['Check Direction'] ?? ''}');
    }
    direction ??= type is Map
        ? _directionFromName('${type['name'] ?? ''}')
        : null;

    return PunchRecord(
      time: '${json['time'] ?? ''}',
      status: '${json['status'] ?? ''}',
      direction: direction,
    );
  }
}

/// Response of GET attendance/today.
class TodayAttendance {
  final List<PunchRecord> records;
  final bool checkedIn;
  final bool checkedOut;

  const TodayAttendance({
    required this.records,
    required this.checkedIn,
    required this.checkedOut,
  });

  /// First accepted check-in time ('HH:mm:ss'), if any.
  String? get checkInTime =>
      records.where((r) => r.accepted && r.direction == 'in').firstOrNull?.time;

  /// Last accepted check-out time ('HH:mm:ss'), if any.
  String? get checkOutTime =>
      records.where((r) => r.accepted && r.direction == 'out').lastOrNull?.time;

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return TodayAttendance(
      records: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(PunchRecord.fromJson)
                .toList()
          : const [],
      checkedIn: json['checked_in'] == true,
      checkedOut: json['checked_out'] == true,
    );
  }
}

class PunchResult {
  final bool success;
  final String message;
  final String status; // 'Success' | 'Pending' | 'Failed'
  final double? distanceMeters;
  final double? radiusMeters;

  const PunchResult({
    required this.success,
    required this.message,
    required this.status,
    this.distanceMeters,
    this.radiusMeters,
  });

  /// "You are 350 m from the office. You must be within 100 m to punch."
  String get outOfRangeMessage {
    final distance = distanceMeters;
    final radius = radiusMeters;
    if (distance == null || radius == null) return message;
    return 'You are ${formatMeters(distance)} from the office. '
        'You must be within ${formatMeters(radius)} to punch.';
  }

  factory PunchResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final record = data is Map ? data : const {};

    return PunchResult(
      success: json['success'] == true,
      message: '${json['message'] ?? ''}',
      status: '${record['status'] ?? ''}',
      // accuracy_meter holds the distance to the nearest allowed branch.
      distanceMeters:
          double.tryParse('${record['accuracy_meter']}') ??
          double.tryParse('${json['WithPrimary']}'),
      radiusMeters: double.tryParse('${json['policyRadius']}'),
    );
  }
}
