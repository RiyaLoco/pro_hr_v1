import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/models/attendance_qr_payload.dart';
import 'package:test_flutter/data/services/app_url_service.dart';

void main() {
  const action =
      '${AppUrlService.baseUrl}/employee/attendance/1/'
      '11.547273130564294, 104.90898218012883';

  test('reads the supplied attendance URL including the coordinate space', () {
    final payload = AttendanceQrPayload.parse(action);
    expect(payload.attendanceTypeId, 1);
    expect(payload.latitude, 11.547273130564294);
    expect(payload.longitude, 104.90898218012883);
  });

  test('reads encoded coordinates and action parameter QR contents', () {
    for (final qr in [
      action.replaceFirst(', ', '%2C%20'),
      'action=${Uri.encodeQueryComponent(action)}',
      'action=$action',
      Uri.parse(action).path,
      '  $action  ',
    ]) {
      final payload = AttendanceQrPayload.parse(qr);
      expect(payload.attendanceTypeId, 1);
      expect(payload.latitude, 11.547273130564294);
      expect(payload.longitude, 104.90898218012883);
    }
  });

  test('rejects text, other origins and other API actions', () {
    final api = Uri.parse(AppUrlService.baseUrl);
    for (final qr in [
      '',
      'office-qr',
      'https://example.com',
      action.replaceFirst(api.host, 'other.example'),
      action.replaceFirst(':${api.port}', ':9999'),
      action.replaceFirst(api.scheme, 'ftp'),
      action.replaceFirst('employee/attendance', 'employee/schedules'),
      action.replaceFirst('/attendance/', '/attendance/extra/'),
      action.replaceFirst('${api.scheme}://', '${api.scheme}://user:pass@'),
      '$action?redirect=https://example.com',
      '$action#ignored',
      '$action/extra',
      'action=$action&extra=1',
    ]) {
      expect(
        () => AttendanceQrPayload.parse(qr),
        throwsFormatException,
        reason: qr,
      );
    }
  });

  test('requires resolved positive type IDs and finite valid coordinates', () {
    for (final suffix in [
      '0/11.5,104.9',
      '-1/11.5,104.9',
      'invalid/11.5,104.9',
      '{attendance_type_id}/{check_location}',
      '1/11.5',
      '1/11.5,104.9,1',
      '1/NaN,104.9',
      '1/Infinity,104.9',
      '1/91,104.9',
      '1/-91,104.9',
      '1/11.5,181',
      '1/11.5,-181',
      '1/11.5,',
      '1/,104.9',
    ]) {
      expect(
        () => AttendanceQrPayload.parse(
          '${AppUrlService.baseUrl}/employee/attendance/$suffix',
        ),
        throwsFormatException,
        reason: suffix,
      );
    }
  });
}
