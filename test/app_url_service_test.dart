import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/services/app_url_service.dart';

void main() {
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
