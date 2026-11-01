import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/models/res/punch_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/data/services/app_url_service.dart';

void main() {
  test('API type bcbv preserves ID 1 in both attendance requests', () async {
    final api = ApiController();
    final requests = <RequestOptions>[];
    api.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: options.method == 'GET'
              ? {
                  'success': true,
                  'data': [
                    {
                      'id': 1,
                      'name': 'bcbv',
                      'short_name': 'vg',
                      'color': '#ab3f3f',
                    },
                  ],
                }
              : {'success': true, 'message': 'Recorded'},
        ));
      },
    ));
    final type = (await api.fetchAttendanceTypes()).single;
    expect(type.id, 1);
    expect(type.name, 'bcbv');
    expect(type.direction, isNull);
    for (final isCheckIn in [true, false]) {
      await api.recordAttendance(
        isCheckIn: isCheckIn,
        attendanceTypeId: type.id,
        latitude: 11.5,
        longitude: 104.9,
        qrCode: 'office-qr',
      );
      expect(requests.last.data['attendance_type_id'], 1);
      expect(requests.last.path, isCheckIn
          ? AppUrlService.attendanceCheckIn
          : AppUrlService.attendanceCheckOut);
    }
  });

  test('attendance types parse API IDs and reject fabricated IDs', () {
    expect(PunchType.fromJson({'id': '7', 'name': 'Check In'}).id, 7);
    final out = PunchType.fromJson({
      'attendance_type_id': '12',
      'type_name': 'Punch Out',
    });
    expect(out.id, 12);
    expect(out.direction, 'out');
    for (final id in [null, 0, -1, 'invalid']) {
      expect(() => PunchType.fromJson({'id': id}), throwsFormatException);
    }
  });

  test('type list ignores malformed IDs and supports paginated data', () async {
    final api = ApiController();
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': {
                  'data': [
                    {'name': 'Missing ID'},
                    {'id': 0, 'name': 'Invalid ID'},
                    {'id': '9', 'name': 'Check Out'},
                  ],
                },
              },
            ),
          );
        },
      ),
    );
    final types = await api.fetchAttendanceTypes();
    expect(types.map((type) => type.id), [9]);
  });

  test('empty type list produces an actionable error', () async {
    final api = ApiController();
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'data': <dynamic>[]},
            ),
          );
        },
      ),
    );
    await expectLater(api.fetchAttendanceTypes(), throwsA(isA<ApiException>()));
  });

  test(
    'check-out sends QR, type ID and coordinates to check-out endpoint',
    () async {
      final api = ApiController();
      RequestOptions? sent;
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sent = options;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'message': 'Checked out'},
              ),
            );
          },
        ),
      );
      await api.recordAttendance(
        isCheckIn: false,
        attendanceTypeId: 9,
        latitude: 11.5,
        longitude: 104.9,
        qrCode: 'office-qr',
      );
      expect(sent?.path, AppUrlService.attendanceCheckOut);
      expect(sent?.data, {
        'attendance_type_id': 9,
        'latitude': 11.5,
        'longitude': 104.9,
        'qr_code': 'office-qr',
      });
    },
  );
}
