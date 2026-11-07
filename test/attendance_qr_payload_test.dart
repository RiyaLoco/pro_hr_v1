import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/models/attendance_qr_payload.dart';
import 'package:test_flutter/data/services/app_url_service.dart';

void main() {
  const template =
      'api/v1/employee/attendance/{attendance_type_id}/{check_location}';
  const action =
      '${AppUrlService.baseUrl}/employee/attendance/1/'
      '11.547273130564294, 104.90898218012883';

  test('accepts the parameterized action in branch QR formats', () {
    for (final qr in [
      template,
      '/$template',
      '${Uri.parse(AppUrlService.baseUrl).origin}/$template',
      template.replaceAll('{', '%7B').replaceAll('}', '%7D'),
      'action=$template',
      'action=${Uri.encodeQueryComponent(template)}',
      '  $template  ',
    ]) {
      final payload = AttendanceQrPayload.parse(qr);
      expect(payload.isTemplate, isTrue, reason: qr);
      expect(payload.attendanceTypeId, isNull);
      expect(payload.latitude, isNull);
      expect(payload.longitude, isNull);
    }
  });

  test('resolves each scan using its selected type and phone GPS', () {
    final payload = AttendanceQrPayload.parse(template);
    for (final (type, latitude, longitude) in [
      (1, 11.54732899907136, 104.9089653152003),
      (2, 11.5473, 104.9090),
      (9, -11.5, 104.9),
    ]) {
      final path = payload.resolve(
        attendanceTypeId: type,
        latitude: latitude,
        longitude: longitude,
      );
      expect(Uri.parse(path).pathSegments, [
        'employee',
        'attendance',
        '$type',
        '$latitude,$longitude',
      ]);
      expect(path, isNot(contains('{')));
      expect(path, isNot(contains('}')));
    }
  });

  test('keeps branch identity separate from runtime attendance parameters', () {
    for (final qr in [
      '$template?branch_id=12',
      '${Uri.parse(AppUrlService.baseUrl).origin}/$template?branch_id=12',
      'action=${Uri.encodeQueryComponent('$template?branch_id=12')}',
    ]) {
      final payload = AttendanceQrPayload.parse(qr);
      expect(payload.branchId, 12);
      expect(payload.isTemplate, isTrue);
      final path = payload.resolve(
        attendanceTypeId: 9,
        latitude: 12.3,
        longitude: 104.9,
      );
      expect(Uri.parse(path).pathSegments.last, '12.3,104.9');
    }
  });

  test('rejects ambiguous or invalid branch identity', () {
    for (final query in [
      '',
      'branch_id=0',
      'branch_id=-1',
      'branch_id=abc',
      'branch_id=1.5',
      'branch_id=1&branch_id=2',
      'branch_id=1&other=2',
      'branch_id[]=1',
    ]) {
      expect(
        () => AttendanceQrPayload.parse('$template?$query'),
        throwsFormatException,
      );
    }
  });

  test('template resolution rejects invalid runtime parameters', () {
    final payload = AttendanceQrPayload.parse(template);
    for (final (type, latitude, longitude) in [
      (0, 11.5, 104.9),
      (1, double.nan, 104.9),
      (1, 91.0, 104.9),
      (1, 11.5, double.infinity),
    ]) {
      expect(
        () => payload.resolve(
          attendanceTypeId: type,
          latitude: latitude,
          longitude: longitude,
        ),
        throwsArgumentError,
      );
    }
  });

  test('reads the supplied attendance URL including the coordinate space', () {
    final payload = AttendanceQrPayload.parse(action);
    expect(payload.isTemplate, isFalse);
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

  test('rejects incomplete templates and malformed fixed QR parameters', () {
    for (final suffix in [
      '0/11.5,104.9',
      '-1/11.5,104.9',
      'invalid/11.5,104.9',
      '{attendance_type_id}/11.5,104.9',
      '1/{check_location}',
      '{check_location}/{attendance_type_id}',
      '{type_id}/{location}',
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
