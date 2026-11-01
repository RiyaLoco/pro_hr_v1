class AppUrlService {
  AppUrlService._();

  static const String baseUrl = 'http://192.168.1.11:8000/api/v1';
  static const String login = '/login';
  static const String leaveTypes = '/employee/leave-requests/types';
  static const String leaveRequests = '/employee/leave-requests';
  static const String recruitments = '/recruitments';
  static const String attendanceToday = '/employee/attendance/today';
  static const String attendanceCheckIn = '/employee/attendance/check-in';
  static const String attendanceCheckOut = '/employee/attendance/check-out';
  static const String attendanceTypes = '/employee/attendance/types';
  static const String schedules = '/employee/schedules';
  static const String shiftOptions = '/employee/shifts';
  static const String shiftRequests = '/employee/shift-requests';

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
