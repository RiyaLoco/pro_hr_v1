class AppUrlService {
  AppUrlService._();

  static const String baseUrl = 'http://192.168.1.4:8000/api/v1';
  static const String login = '/login';
  static const String leaveTypes = '/employee/leave-requests/types';
  static const String leaveRequests = '/employee/leave-requests';

  static String fileUrl(String path) {
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
    return '${serverUri.toString()}/${path.replaceFirst(RegExp(r'^/+'), '')}';
  }
}
