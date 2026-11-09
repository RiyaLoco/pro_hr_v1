class AppUrlService {
  AppUrlService._();

  static const String baseUrl = 'http://192.168.1.14:8000/api/v1';
  static const String login = '/login';
  static const String leaveTypes = '/employee/leave-requests/types';
  static const String leaveRequests = '/employee/leave-requests';
  static const String leaveRemainings = '/employee/leave-remainings';
  static const String recruitments = '/recruitments';
  static const String attendance = '/employee/attendance';
  static const String attendanceToday = '/employee/attendance/today';
  static const String attendanceCheck =
      '/employee/attendance/{attendance_type_id}/{check_location}';
  static const String attendanceTypes = '/employee/attendance/types';
  static const String schedules = '/employee/schedules';
  static const String shiftOptions = '/employee/shift-requests/shifts';
  static const String shiftRequests = '/employee/shift-requests';
  static const String payrolls = '/employee/payrolls';
  static const String overtimeRequests = '/employee/ot-requests';
  static const String overtimeRates = '/employee/ot-requests/rates';

  /// The location is always the phone's GPS position, never QR contents.
  static String attendanceCheckUrl({
    required int attendanceTypeId,
    required double latitude,
    required double longitude,
  }) {
    if (attendanceTypeId <= 0) {
      throw ArgumentError.value(attendanceTypeId, 'attendanceTypeId');
    }
    if (!latitude.isFinite || latitude.abs() > 90) {
      throw ArgumentError.value(latitude, 'latitude');
    }
    if (!longitude.isFinite || longitude.abs() > 180) {
      throw ArgumentError.value(longitude, 'longitude');
    }
    return attendanceCheck
        .replaceFirst('{attendance_type_id}', '$attendanceTypeId')
        .replaceFirst(
          '{check_location}',
          Uri.encodeComponent('$latitude,$longitude'),
        );
  }

  /// Resolves Laravel public-disk attachments for the API server in use.
  static String attachmentUrl(String path) {
    path = path.trim();
    if (path.startsWith('//')) {
      path = '${Uri.parse(baseUrl).scheme}:$path';
    }
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final host = uri.host.toLowerCase();
      if (host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '0.0.0.0' ||
          host == '::1') {
        final api = Uri.parse(baseUrl);
        return uri
            .replace(scheme: api.scheme, host: api.host, port: api.port)
            .toString();
      }
      return path;
    }
    if (path.startsWith('/')) return fileUrl(path);
    // `attachment` stores a public disk key, e.g. leave-requests/report.pdf.
    if (path.startsWith('public/')) path = path.substring('public/'.length);
    if (!path.startsWith('storage/')) path = 'storage/$path';
    return fileUrl(path);
  }

  static String fileUrl(String path) {
    path = path.trim();
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return path;
    }

    final apiUri = Uri.parse(baseUrl);
    final serverUri = Uri(
      scheme: apiUri.scheme,
      host: apiUri.host,
      port: apiUri.hasPort ? apiUri.port : null,
    );
    if (path.startsWith('//')) {
      return '${apiUri.scheme}:$path';
    }
    var relativePath = path.replaceFirst(RegExp(r'^/+'), '');
    // Laravel stores avatar paths relative to its public storage disk.
    // API-provided absolute URLs and paths already under storage stay intact.
    if (relativePath.startsWith('avatars/') ||
        relativePath.startsWith('admin-users-avatar/')) {
      relativePath = 'storage/$relativePath';
    }
    return '${serverUri.toString()}/$relativePath';
  }
}
