/// 'Check In' / 'check_in' / 'IN' -> 'in',  'Check Out' / 'OUT' -> 'out'.
/// Same normalisation the Laravel controller uses.
String? _directionFromName(String? name) {
  final normalized = (name ?? '').trim().toLowerCase().replaceAll(
    RegExp(r'[\s_-]+'),
    '',
  );
  switch (normalized) {
    case 'checkin':
    case 'in':
      return 'in';
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

/// Location evidence returned by the employee attendance API.
/// Work schedules and time allowances are evaluated by Laravel.
class AttendanceLocationPolicy {
  final bool? isInRange;
  final double? distanceMeters;
  final double? radiusMeters;

  const AttendanceLocationPolicy({
    this.isInRange,
    this.distanceMeters,
    this.radiusMeters,
  });

  factory AttendanceLocationPolicy.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final record = data is Map ? data : json;
    final rawCompared = record['compared_values'];
    final compared = rawCompared is Map ? rawCompared : const {};
    final rawSummary = compared['Location Summary'];
    final summary = rawSummary is Map ? rawSummary : const {};
    final rawMatched = compared['Matched Branch'];
    final matched = rawMatched is Map ? rawMatched : const {};

    double? number(dynamic value) {
      final parsed = double.tryParse('$value');
      return parsed != null && parsed.isFinite && parsed >= 0 ? parsed : null;
    }

    final rawRadius =
        json['policyRadius'] ??
        summary['policyRadius'] ??
        compared['Radius Allowance(M)'];
    final radius = number(rawRadius);
    // accuracy_meter is the nearest allowed branch distance in this API.
    // WithPrimary alone must not reject an allowed secondary branch.
    final rawDistance = record['accuracy_meter'] ?? matched['distance'];
    var distance = number(rawDistance);
    if (distance == null) {
      final primary = number(json['WithPrimary'] ?? summary['WithPrimary']);
      final distances = <double>[?primary];
      final conditional =
          json['conditionalLocation'] ?? summary['conditionalLocation'];
      if (conditional is List) {
        for (final branch in conditional.whereType<Map>()) {
          final value = number(branch['distance']);
          if (value != null) distances.add(value);
        }
      }
      if (distances.isNotEmpty) {
        distance = distances.reduce((a, b) => a < b ? a : b);
      }
    }
    final flags = [json['isCheckinRange'], summary['isCheckinRange']];
    final invalidRadius = rawRadius != null && radius == null;
    final invalidDistance = rawDistance != null && number(rawDistance) == null;
    final outside =
        invalidRadius ||
        invalidDistance ||
        flags.contains(false) ||
        (distance != null && radius != null && distance > radius);
    final inside =
        flags.contains(true) ||
        (distance != null && radius != null && distance <= radius);
    return AttendanceLocationPolicy(
      isInRange: outside ? false : (inside ? true : null),
      distanceMeters: distance,
      radiusMeters: radius,
    );
  }
}

/// One row from the attendance types list.
class PunchType {
  final int id;
  final String name;
  final String? shortName;

  const PunchType({required this.id, required this.name, this.shortName});

  /// 'in', 'out', or null when the name isn't clearly one of them.
  String? get direction =>
      _directionFromName(name) ?? _directionFromName(shortName);

  static PunchType forDirection(
    List<PunchType> types, {
    required bool isCheckIn,
  }) {
    final wanted = isCheckIn ? 'in' : 'out';
    final match = types.where((type) => type.direction == wanted).firstOrNull;
    if (match == null) {
      throw StateError(
        'No attendance type identifies check-$wanted in its name or short name. '
        'Please contact your administrator.',
      );
    }
    return match;
  }

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
      shortName: json['short_name']?.toString(),
    );
  }
}

/// One punch from today's attendance list.
class PunchRecord {
  final int? id;
  final int? employeeId;
  final String time; // 'HH:mm:ss' as stored by the server
  final String status;
  final String? direction; // 'in' | 'out'
  final AttendanceLocationPolicy locationPolicy;

  const PunchRecord({
    this.id,
    this.employeeId,
    required this.time,
    required this.status,
    this.direction,
    this.locationPolicy = const AttendanceLocationPolicy(),
  });

  /// An explicit approval can accept a previously failed attempt. A new scan
  /// must still pass the current radius check in [PunchResult].
  bool get accepted {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'success(via approval)') return true;
    return locationPolicy.isInRange != false &&
        const {'success', 'pending'}.contains(normalized);
  }

  bool get isPending => accepted && status.trim().toLowerCase() == 'pending';

  factory PunchRecord.fromJson(Map<String, dynamic> json) {
    final compared = json['compared_values'];
    final type = json['type'];

    String? direction;
    if (compared is Map) {
      direction = _directionFromName('${compared['Check Direction'] ?? ''}');
    }
    if (type is Map) {
      direction ??=
          _directionFromName('${type['name'] ?? ''}') ??
          _directionFromName('${type['short_name'] ?? ''}');
    }

    return PunchRecord(
      id: int.tryParse('${json['id']}'),
      employeeId: int.tryParse('${json['employee_id']}'),
      time: '${json['time'] ?? ''}',
      status: '${json['status'] ?? ''}',
      direction: direction,
      locationPolicy: AttendanceLocationPolicy.fromJson(json),
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

  /// First check-in accepted by both attendance status and location policy.
  PunchRecord? get checkInRecord =>
      records.where((r) => r.accepted && r.direction == 'in').firstOrNull;

  String? get checkInTime => checkedIn ? checkInRecord?.time : null;

  PunchRecord? get checkOutRecord =>
      records.where((r) => r.accepted && r.direction == 'out').lastOrNull;

  /// Last accepted check-out time ('HH:mm:ss'), if any.
  String? get checkOutTime => checkedOut ? checkOutRecord?.time : null;

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final records = data is List
        ? data
              .whereType<Map<String, dynamic>>()
              .map(PunchRecord.fromJson)
              .toList()
        : <PunchRecord>[];
    final checkedIn =
        json['checked_in'] == true &&
        records.any((r) => r.accepted && r.direction == 'in');
    final checkedOut =
        checkedIn &&
        json['checked_out'] == true &&
        records.any((r) => r.accepted && r.direction == 'out');
    return TodayAttendance(
      records: records,
      checkedIn: checkedIn,
      checkedOut: checkedOut,
    );
  }
}

class PunchResult {
  final bool success;
  final String message;
  final String status; // 'Success' | 'Pending' | 'Failed'
  final double? distanceMeters;
  final double? radiusMeters;
  final PunchRecord? record;
  final bool? isInRange;

  const PunchResult({
    required this.success,
    required this.message,
    required this.status,
    this.distanceMeters,
    this.radiusMeters,
    this.record,
    this.isInRange,
  });

  bool get isPending => success && status.trim().toLowerCase() == 'pending';

  String outcomeTitle({required bool isCheckIn}) => isPending
      ? 'Pending approval'
      : (isCheckIn ? 'Checked in' : 'Checked out');

  /// "You are 350 m from the office. You must be within 100 m to punch."
  String get outOfRangeMessage {
    final distance = distanceMeters;
    final radius = radiusMeters;
    if (distance == null || radius == null || distance <= radius) {
      return 'Your location could not be accepted under your employee '
          'attendance policy. Please contact your administrator if this persists.';
    }
    return 'You are ${formatMeters(distance)} from the office. '
        'You must be within ${formatMeters(radius)} to punch.';
  }

  factory PunchResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final record = data is Map<String, dynamic>
        ? PunchRecord.fromJson(data)
        : null;
    final policy = AttendanceLocationPolicy.fromJson(json);

    return PunchResult(
      success:
          json['success'] == true &&
          policy.isInRange == true &&
          record?.accepted == true,
      message: '${json['message'] ?? ''}',
      status: record?.status ?? '',
      distanceMeters: policy.distanceMeters,
      radiusMeters: policy.radiusMeters,
      record: record,
      isInRange: policy.isInRange,
    );
  }
}
