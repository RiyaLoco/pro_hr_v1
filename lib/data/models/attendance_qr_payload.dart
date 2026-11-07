import 'package:test_flutter/data/services/app_url_service.dart';

/// An attendance action whose parameters are filled from the selected type and
/// fresh phone GPS. Resolved office URLs remain supported for existing QRs.
class AttendanceQrPayload {
  final int? branchId;
  final int? attendanceTypeId;
  final double? latitude;
  final double? longitude;

  bool get isTemplate => attendanceTypeId == null;

  const AttendanceQrPayload._({
    required this.branchId,
    required this.attendanceTypeId,
    required this.latitude,
    required this.longitude,
  });

  factory AttendanceQrPayload.parse(String qrCode) {
    var action = qrCode.trim();
    if (action.isEmpty || action.length > 4096) {
      throw const FormatException('Scan a valid office attendance QR code.');
    }
    if (action.startsWith('action=')) {
      final parameters = Uri.splitQueryString(action);
      if (parameters.length != 1) {
        throw const FormatException('Scan a valid office attendance QR code.');
      }
      action = parameters['action']?.trim() ?? '';
    }

    final uri = Uri.tryParse(action);
    final api = Uri.parse(AppUrlService.baseUrl);
    if (uri == null ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty ||
        ((uri.hasScheme || uri.hasAuthority) &&
            (uri.scheme != api.scheme ||
                !uri.hasAuthority ||
                uri.origin != api.origin))) {
      throw const FormatException(
        'This QR code is not for this attendance service. Scan the office QR code.',
      );
    }

    int? branchId;
    if (uri.hasQuery) {
      final parameters = uri.queryParametersAll;
      final values = parameters['branch_id'];
      final value = values?.singleOrNull;
      branchId = value != null && RegExp(r'^[1-9][0-9]*$').hasMatch(value)
          ? int.tryParse(value)
          : null;
      if (parameters.length != 1 || branchId == null || branchId <= 0) {
        throw const FormatException(
          'The attendance QR has an invalid branch ID.',
        );
      }
    }

    final prefix = [
      ...api.pathSegments.where((segment) => segment.isNotEmpty),
      ...Uri.parse(AppUrlService.attendance).pathSegments,
    ];
    final segments = uri.pathSegments;
    if (segments.length != prefix.length + 2 ||
        Iterable<int>.generate(
          prefix.length,
        ).any((index) => segments[index] != prefix[index])) {
      throw const FormatException(
        'This QR code is not an attendance action. Scan the office QR code.',
      );
    }

    if (segments[prefix.length] == '{attendance_type_id}' &&
        segments.last == '{check_location}') {
      return AttendanceQrPayload._(
        branchId: branchId,
        attendanceTypeId: null,
        latitude: null,
        longitude: null,
      );
    }

    final type = int.tryParse(segments[prefix.length]);
    final location = segments.last.split(',');
    final latitude = location.length == 2
        ? double.tryParse(location[0].trim())
        : null;
    final longitude = location.length == 2
        ? double.tryParse(location[1].trim())
        : null;
    if (type == null ||
        type <= 0 ||
        latitude == null ||
        !latitude.isFinite ||
        latitude.abs() > 90 ||
        longitude == null ||
        !longitude.isFinite ||
        longitude.abs() > 180) {
      throw const FormatException(
        'The attendance QR action has invalid parameters.',
      );
    }

    return AttendanceQrPayload._(
      branchId: branchId,
      attendanceTypeId: type,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Runtime values are validated and encoded before sending the API request.
  String resolve({
    required int attendanceTypeId,
    required double latitude,
    required double longitude,
  }) {
    return AppUrlService.attendanceCheckUrl(
      attendanceTypeId: attendanceTypeId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
