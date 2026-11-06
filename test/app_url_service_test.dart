import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/services/app_url_service.dart';

void main() {
  test('attachment storage paths resolve without duplicating storage', () {
    final server = Uri.parse(AppUrlService.baseUrl).origin;
    for (final path in [
      'leave-requests/report.pdf',
      'storage/leave-requests/report.pdf',
      '/storage/leave-requests/report.pdf',
      'public/leave-requests/report.pdf',
    ]) {
      expect(
        AppUrlService.attachmentUrl(path),
        '$server/storage/leave-requests/report.pdf',
      );
    }
  });

  test('loopback attachment links use the reachable API origin', () {
    final server = Uri.parse(AppUrlService.baseUrl).origin;
    for (final origin in [
      'http://localhost',
      'http://127.0.0.1:8000',
      'http://0.0.0.0:8000',
      'http://[::1]:8000',
      '//localhost:8000',
    ]) {
      expect(
        AppUrlService.attachmentUrl(
          '$origin/storage/leave-requests/report.pdf?download=1#page=2',
        ),
        '$server/storage/leave-requests/report.pdf?download=1#page=2',
      );
    }
    const cdn = 'https://files.example.com/report.pdf?signature=sample';
    expect(AppUrlService.attachmentUrl(cdn), cdn);
  });

  test('avatar disk paths resolve under Laravel public storage', () {
    final server = Uri.parse(AppUrlService.baseUrl).origin;
    expect(
      AppUrlService.fileUrl('admin-users-avatar/photo.jpg'),
      '$server/storage/admin-users-avatar/photo.jpg',
    );
    expect(
      AppUrlService.fileUrl('/avatars/photo.jpg'),
      '$server/storage/avatars/photo.jpg',
    );
    expect(
      AppUrlService.fileUrl('/storage/avatars/photo.jpg'),
      '$server/storage/avatars/photo.jpg',
    );
    expect(
      AppUrlService.fileUrl('https://example.com/avatar.jpg'),
      'https://example.com/avatar.jpg',
    );
    expect(
      AppUrlService.fileUrl('images/banner.jpg'),
      '$server/images/banner.jpg',
    );
  });
  test('file URLs handle whitespace and protocol-relative URLs', () {
    final server = Uri.parse(AppUrlService.baseUrl).origin;
    expect(
      AppUrlService.fileUrl('  /storage/avatars/photo.jpg  '),
      '$server/storage/avatars/photo.jpg',
    );
    expect(
      AppUrlService.fileUrl('//cdn.example.com/photo.jpg'),
      '${Uri.parse(AppUrlService.baseUrl).scheme}://cdn.example.com/photo.jpg',
    );
  });
}
