import 'package:test_flutter/data/services/app_url_service.dart';

/// The office URL carried by an attendance QR, not the phone's GPS position.
/// Parsing checks the action's shape and origin. Laravel must bind these
/// coordinates to a permitted branch and check the phone GPS against it.
class AttendanceQrPayload {
  final int attendanceTypeId;
  final double latitude;
  final double longitude;

  const AttendanceQrPayload._({
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
        !uri.path.startsWith('/') ||
        uri.hasQuery ||
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
        'The attendance QR code has an invalid type or office location.',
      );
    }

    return AttendanceQrPayload._(
      attendanceTypeId: type,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
