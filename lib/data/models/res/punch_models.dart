import 'package:test_flutter/utils/helpers/distant_helpers.dart';

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
  final int? branchId;
  final String? branchName;
  final String? branchLocation;
  final String? phoneLocation;
  final double? reportedDistanceMeters;
  final String? validationMessage;

  const AttendanceLocationPolicy({
    this.isInRange,
    this.distanceMeters,
    this.radiusMeters,
    this.branchId,
    this.branchName,
    this.branchLocation,
    this.phoneLocation,
    this.reportedDistanceMeters,
    this.validationMessage,
  });

  factory AttendanceLocationPolicy.fromJson(
    Map<String, dynamic> json, {
    double? currentLatitude,
    double? currentLongitude,
    int? expectedBranchId,
    String? qrBranchLocation,
  }) {
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
    // Both actions can use a permitted secondary branch. WithPrimary describes
    // only the primary office and must never replace a matched branch distance.
    final rawDistance = matched['distance'] ?? record['accuracy_meter'];
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
    final reportedDistance = distance;
    final hasCurrentPosition =
        currentLatitude != null || currentLongitude != null;
    // New scans always use the position submitted by this phone. History uses
    // the GPS saved on that event, never the phone's position at refresh time.
    final phoneLocation = hasCurrentPosition
        ? '$currentLatitude,$currentLongitude'
        : record['check_location'] ??
              compared['Check Location'] ??
              json['primaryCheck'] ??
              summary['primaryCheck'];
    final returnedBranchId = int.tryParse('${matched['id']}');
    final wrongBranch =
        expectedBranchId != null && returnedBranchId != expectedBranchId;
    final scoped = expectedBranchId != null || qrBranchLocation != null;
    dynamic branchLocation = qrBranchLocation ?? matched['location'];
    // Older unscoped responses may include only the permitted branch list.
    // Select the nearest coordinate from that list, without imposing IN-only
    // primary-office restrictions. An identified QR never uses this fallback.
    if (!scoped && matched.isEmpty && phoneLocation is String) {
      final conditional =
          json['conditionalLocation'] ?? summary['conditionalLocation'];
      final locations = [
        json['primaryLocation'] ??
            summary['primaryLocation'] ??
            compared['Default Location'],
        if (conditional is List)
          ...conditional.whereType<Map>().map((branch) => branch['location']),
      ];
      double? nearest;
      for (final location in locations.whereType<String>()) {
        try {
          final meters = calculateDistanceMeters(location, phoneLocation);
          if (nearest == null || meters < nearest) {
            nearest = meters;
            branchLocation = location;
          }
        } on ArgumentError {
          // A broken optional office must not hide a valid permitted office.
        }
      }
    }
    var invalidCoordinates = false;
    var wrongQrLocation = false;
    if (branchLocation != null && phoneLocation != null) {
      try {
        if (branchLocation is! String || phoneLocation is! String) {
          throw ArgumentError('Branch and phone coordinates are required.');
        }
        distance = calculateDistanceMeters(branchLocation, phoneLocation);
        if (qrBranchLocation != null && matched['location'] is String) {
          // Only office-coordinate rounding tolerance, never a phone radius.
          wrongQrLocation =
              calculateDistanceMeters(qrBranchLocation, matched['location']) >
              0.2;
        }
      } on ArgumentError {
        invalidCoordinates = true;
        distance = null;
      }
    } else if (scoped && hasCurrentPosition) {
      invalidCoordinates = true;
      distance = null;
    }
    if (wrongBranch) {
      // A distance to a different office cannot describe the scanned branch.
      distance = null;
    }
    final flags = [json['isCheckinRange'], summary['isCheckinRange']];
    final invalidRadius =
        (rawRadius != null || hasCurrentPosition) && radius == null;
    final invalidDistance =
        (rawDistance != null && number(rawDistance) == null) ||
        (record['accuracy_meter'] != null &&
            number(record['accuracy_meter']) == null);
    final outside =
        invalidRadius ||
        invalidDistance ||
        invalidCoordinates ||
        wrongBranch ||
        wrongQrLocation ||
        flags.contains(false) ||
        (distance != null && radius != null && distance > radius);
    final measuredInside =
        distance != null && radius != null && distance <= radius;
    final inside =
        measuredInside || (!hasCurrentPosition && flags.contains(true));
    return AttendanceLocationPolicy(
      isInRange: outside ? false : (inside ? true : null),
      distanceMeters: distance,
      radiusMeters: radius,
      branchId: returnedBranchId,
      branchName: wrongBranch || wrongQrLocation
          ? null
          : matched['name']?.toString(),
      branchLocation: wrongBranch || branchLocation is! String
          ? null
          : branchLocation,
      phoneLocation: phoneLocation is String ? phoneLocation : null,
      reportedDistanceMeters: reportedDistance,
      validationMessage: wrongBranch || wrongQrLocation
          ? 'The attendance server did not verify the scanned branch. Please use its updated branch QR code.'
          : invalidCoordinates
          ? 'The scanned branch coordinates could not be verified.'
          : null,
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

  factory PunchRecord.fromJson(
    Map<String, dynamic> json, {
    AttendanceLocationPolicy? locationPolicy,
  }) {
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
      locationPolicy: locationPolicy ?? AttendanceLocationPolicy.fromJson(json),
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
      return record?.locationPolicy.validationMessage ??
          'Your location was not accepted under the employee attendance policy.';
    }
    final branch = record?.locationPolicy.branchName;
    return 'You are ${formatMeters(distance)} from ${branch ?? 'the attendance branch'}. '
        'You must be within ${formatMeters(radius)} to punch.';
  }

  factory PunchResult.fromJson(
    Map<String, dynamic> json, {
    double? currentLatitude,
    double? currentLongitude,
    int? expectedBranchId,
    String? qrBranchLocation,
  }) {
    final data = json['data'];
    final hasRecord = data is Map<String, dynamic>;
    final policy = AttendanceLocationPolicy.fromJson(
      json,
      currentLatitude: hasRecord ? currentLatitude : null,
      currentLongitude: hasRecord ? currentLongitude : null,
      expectedBranchId: hasRecord ? expectedBranchId : null,
      qrBranchLocation: hasRecord ? qrBranchLocation : null,
    );
    final record = data is Map<String, dynamic>
        ? PunchRecord.fromJson(data, locationPolicy: policy)
        : null;

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
