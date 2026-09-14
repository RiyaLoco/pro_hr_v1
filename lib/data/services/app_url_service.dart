class AppUrlService {
  AppUrlService._();

  static const String baseUrl = 'http://192.168.1.6:8000/api/v1';
  static const String login = '/login';

  /// Converts a server-relative upload path, such as `avatars/user.jpg`, into
  /// a URL that can be used by [NetworkImage].
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
