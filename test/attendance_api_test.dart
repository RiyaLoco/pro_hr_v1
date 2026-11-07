import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:test_flutter/data/models/res/punch_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/data/services/attendance_qr_service.dart';
import 'package:test_flutter/features/hrms_app/controllers/punch_countroller.dart';

const _officeQr =
    'api/v1/employee/attendance/{attendance_type_id}/{check_location}';
const _fixedOfficeQr =
    '${AppUrlService.baseUrl}/employee/attendance/1/'
    '11.547273130564294, 104.90898218012883';

class _MemoryStorage extends Fake implements GetStorage {
  final values = <String, dynamic>{};

  @override
  Future<bool> get initStorage async => true;

  @override
  T? read<T>(String key) => values[key] as T?;

  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;
}

Map<String, dynamic> _record({
  int id = 101,
  int employee = 7,
  bool isCheckIn = true,
  String status = 'Success',
  double distance = 25,
  double radius = 100,
  String? branchLocation = '11.5002248304015,104.9',
  String? phoneLocation = '11.5,104.9',
}) => {
  'id': id,
  'employee_id': employee,
  'date': '2026-11-06',
  'time': isCheckIn ? '08:00:00' : '17:00:00',
  'status': status,
  'accuracy_meter': distance,
  'check_location': ?phoneLocation,
  'compared_values': {
    'Check Direction': isCheckIn ? 'in' : 'out',
    'Default Location': ?branchLocation,
    'Location Summary': {
      'policyRadius': radius,
      'isCheckinRange': distance <= radius,
    },
    'Radius Allowance(M)': radius,
    'Matched Branch': {
      'id': 1,
      'name': 'Branch A',
      'distance': distance,
      'location': ?branchLocation,
    },
  },
  'type': {
    'id': isCheckIn ? 3 : 9,
    'name': isCheckIn ? 'Check In' : 'Check Out',
  },
};

Map<String, dynamic> _result({
  bool isCheckIn = true,
  bool inRange = true,
  String status = 'Success',
  String branchLocation = '11.5002248304015,104.9',
  String phoneLocation = '11.5,104.9',
}) => {
  'success': inRange,
  'isCheckinRange': inRange,
  'policyRadius': 100,
  'primaryLocation': branchLocation,
  'message': inRange ? 'Attendance recorded.' : 'Outside the permitted radius.',
  'data': _record(
    isCheckIn: isCheckIn,
    status: inRange ? status : 'Failed',
    distance: inRange ? 25 : 250,
    branchLocation: branchLocation,
    phoneLocation: phoneLocation,
  ),
};

void main() {
  late _MemoryStorage storage;
  late ApiController api;
  late List<RequestOptions> requests;
  late Object? responseData;
  late int statusCode;
  late Map<String, dynamic> today;

  setUp(() {
    storage = _MemoryStorage();
    api = ApiController(attendanceQr: AttendanceQrService(storage: storage));
    requests = [];
    statusCode = 201;
    responseData = _result();
    today = {
      'success': true,
      'checked_in': true,
      'checked_out': false,
      'data': [_record()],
    };
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          final isToday = options.path == AppUrlService.attendanceToday;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: isToday ? 200 : statusCode,
              data: isToday ? today : responseData,
            ),
          );
        },
      ),
    );
  });

  tearDown(() => ApiController.setToken(null));

  Future<PunchResult> punch({
    bool isCheckIn = true,
    String qr = _officeQr,
    double latitude = 11.5,
    double longitude = 104.9,
  }) => api.recordAttendance(
    isCheckIn: isCheckIn,
    attendanceTypeId: isCheckIn ? 3 : 9,
    latitude: latitude,
    longitude: longitude,
    qrCode: qr,
  );

  test(
    'one action template resolves both directions with fresh phone coordinates',
    () async {
      ApiController.setToken('attendance-token');
      await punch(qr: '  $_officeQr  ');
      final checkIn = requests.single;
      expect(checkIn.method, 'POST');
      expect(
        Uri.decodeComponent(checkIn.uri.path),
        '/api/v1/employee/attendance/3/11.5,104.9',
      );
      expect(checkIn.data, {'qr_code': _officeQr});
      expect(checkIn.headers['Authorization'], 'Bearer attendance-token');
      expect(checkIn.queryParameters, isEmpty);

      responseData = _result(
        isCheckIn: false,
        branchLocation: '11.6002248304015,104.8',
        phoneLocation: '11.6,104.8',
      );
      final result = await punch(
        isCheckIn: false,
        latitude: 11.6,
        longitude: 104.8,
      );
      expect(result.success, isTrue);
      expect(requests[1].path, AppUrlService.attendanceToday);
      expect(requests.last.method, 'POST');
      expect(
        Uri.decodeComponent(requests.last.uri.path),
        '/api/v1/employee/attendance/9/11.6,104.8',
      );
      expect(requests.last.data, {'qr_code': _officeQr});
    },
  );

  test(
    'check-out at another branch can scan a different valid attendance QR',
    () async {
      await punch();
      requests.clear();
      responseData = _result(
        isCheckIn: false,
        branchLocation: '12,105',
        phoneLocation: '12,105',
      );
      const branchBQr = '${AppUrlService.baseUrl}/employee/attendance/1/12,105';
      final result = await punch(
        isCheckIn: false,
        qr: branchBQr,
        latitude: 12,
        longitude: 105,
      );
      expect(result.success, isTrue);
      expect(requests.map((r) => r.method), ['GET', 'POST']);
      expect(
        Uri.decodeComponent(requests.last.uri.path),
        '/api/v1/employee/attendance/9/12.0,105.0',
      );
      expect(requests.last.data, {'qr_code': branchBQr});
    },
  );

  test(
    'a different branch QR still cannot override rejected check-out GPS',
    () async {
      await punch();
      responseData = _result(isCheckIn: false, inRange: false);
      final result = await punch(
        isCheckIn: false,
        qr: '${AppUrlService.baseUrl}/employee/attendance/1/12,105',
        latitude: 0,
        longitude: 0,
      );
      expect(result.success, isFalse);
      expect(result.isInRange, isFalse);
      expect(result.status, 'Failed');
    },
  );

  test('QR is required before any network request', () async {
    for (final isCheckIn in [true, false]) {
      await expectLater(
        punch(isCheckIn: isCheckIn, qr: '  '),
        throwsA(isA<ApiException>()),
      );
    }
    expect(requests, isEmpty);
  });

  test('check-out requires an accepted check-in on this device', () async {
    await expectLater(
      punch(isCheckIn: false),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('unavailable on this device'),
        ),
      ),
    );
    today['checked_in'] = false;
    today['data'] = [_record(status: 'Failed')];
    await expectLater(
      punch(isCheckIn: false),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Check in before checking out.',
        ),
      ),
    );
    expect(requests.every((r) => r.method == 'GET'), isTrue);
  });

  test('already completed attendance cannot send another check-out', () async {
    await punch();
    requests.clear();
    today['checked_out'] = true;
    today['data'] = [_record(), _record(id: 102, isCheckIn: false)];
    await expectLater(punch(isCheckIn: false), throwsA(isA<ApiException>()));
    expect(requests.map((r) => r.method), ['GET']);
  });

  test('stored QR remains available to a recreated service', () async {
    await punch();
    await AttendanceQrService(
      storage: storage,
    ).requireCheckInForCheckOut(PunchRecord.fromJson(_record()));
  });

  test('another day or employee cannot reuse the saved QR', () async {
    await punch();
    for (final record in [_record(id: 102), _record(employee: 8)]) {
      today['data'] = [record];
      requests.clear();
      await expectLater(punch(isCheckIn: false), throwsA(isA<ApiException>()));
      expect(requests.map((r) => r.method), ['GET']);
    }
  });

  test('out-of-radius check-in never saves a QR or reports success', () async {
    statusCode = 422;
    responseData = _result(inRange: false);
    final result = await punch();
    expect(result.success, isFalse);
    expect(result.status, 'Failed');
    expect(result.radiusMeters, 100);
    expect(storage.values, isEmpty);
  });

  test(
    'current GPS must be inside the actual branch coordinate radius',
    () async {
      // The API incorrectly reports a short distance and even echoes office GPS.
      // Neither may replace the phone position submitted for this scan.
      final record = _record(distance: 0);
      record['check_location'] = '11.547273130564294,104.90898218012883';
      final compared = record['compared_values'] as Map;
      compared['Default Location'] = record['check_location'];
      compared['Matched Branch'] = {
        'id': 1,
        'location': record['check_location'],
        'distance': 0,
      };
      responseData = {
        ..._result(),
        'primaryLocation': record['check_location'],
        'WithPrimary': 0,
        'data': record,
      };
      final result = await punch(latitude: 11.540200, longitude: 104.85816);
      expect(result.success, isFalse);
      expect(result.distanceMeters, greaterThan(5500));
      expect(storage.values, isEmpty);
    },
  );

  test(
    'refresh recalculates distance from stored branch and punch coordinates',
    () async {
      final record = _record(distance: 0);
      record['check_location'] = '11.540200,104.85816';
      (record['compared_values'] as Map)['Default Location'] =
          '11.547273130564294,104.90898218012883';
      today['data'] = [record];
      final controller = PunchController(api: api);
      await controller.fetchToday();
      expect(controller.isCheckedIn.value, isFalse);
      expect(controller.checkInTime.value, isEmpty);
    },
  );

  test(
    'different coordinates pass only within the configured radius',
    () async {
      for (final (latitude, longitude, radius, accepted) in [
        (11.547273130564294, 104.90898218012883, 0.0, true),
        (11.54732899907136, 104.9089653152003, 10.0, true),
        (11.54732899907136, 104.9089653152003, 5.0, false),
        (11.540200, 104.85816, 150.0, false),
      ]) {
        final record = _record(
          distance: 0,
          radius: radius,
          branchLocation: '11.547273130564294,104.90898218012883',
          phoneLocation: '$latitude,$longitude',
        );
        responseData = {
          ..._result(),
          'policyRadius': radius,
          'primaryLocation': '11.547273130564294,104.90898218012883',
          'data': record,
        };
        final result = await punch(latitude: latitude, longitude: longitude);
        expect(result.success, accepted, reason: 'radius: $radius');
        expect(result.distanceMeters! <= radius, accepted);
      }
    },
  );

  test(
    'branch-specific scans reject missing or invalid branch coordinates',
    () async {
      for (final location in [null, '', 'NaN,104.9', '91,104.9', '11.5']) {
        final record = _record(distance: 0, branchLocation: null);
        responseData = {
          ..._result(),
          'primaryLocation': location,
          'data': record,
        };
        final result = await punch(qr: '$_officeQr?branch_id=1');
        expect(result.success, isFalse, reason: '$location');
        expect(result.record?.accepted, isFalse);
      }
      expect(storage.values, isEmpty);
    },
  );

  test(
    'today preserves accepted legacy records without coordinate metadata',
    () async {
      today['data'] = [_record(branchLocation: null, phoneLocation: null)];
      final attendance = await api.fetchTodayAttendance();
      expect(attendance.checkedIn, isTrue);
      expect(attendance.checkInRecord, isNotNull);
    },
  );

  test('check-out compares GPS with the matched branch coordinates', () async {
    await punch();
    final record = _record(
      isCheckIn: false,
      distance: 0,
      branchLocation: '11.547273130564294,104.90898218012883',
      phoneLocation: '11.540200,104.85816',
    );
    responseData = {
      ..._result(isCheckIn: false),
      'primaryLocation': '11.540200,104.85816',
      'WithPrimary': 0,
      'data': record,
    };
    final result = await punch(
      isCheckIn: false,
      latitude: 11.540200,
      longitude: 104.85816,
    );
    expect(result.success, isFalse);
    expect(result.distanceMeters, greaterThan(5500));
  });

  test(
    'branch-specific check-out needs its matched branch coordinates',
    () async {
      await punch();
      final record = _record(isCheckIn: false, branchLocation: null);
      responseData = {..._result(isCheckIn: false), 'data': record};
      expect(
        (await punch(isCheckIn: false, qr: '$_officeQr?branch_id=1')).success,
        isFalse,
      );
    },
  );

  test(
    'a rounded distance cannot move an outside point into the radius',
    () async {
      final record = _record(
        distance: 100,
        radius: 100,
        branchLocation: '0,0',
        phoneLocation: '0.000899325203212,0',
      );
      responseData = {..._result(), 'primaryLocation': '0,0', 'data': record};
      final result = await punch(latitude: 0.000899325203212, longitude: 0);
      expect(result.success, isFalse);
      expect(result.distanceMeters, closeTo(100.0004, 0.000001));
    },
  );

  test('the same QR cannot bypass the server check-out radius', () async {
    await punch();
    statusCode = 422;
    responseData = _result(isCheckIn: false, inRange: false);
    final result = await punch(isCheckIn: false);
    expect(result.success, isFalse);
    expect(result.status, 'Failed');
  });

  test('in-range pending approval is an accepted check-in', () async {
    responseData = _result(status: 'Pending');
    final pending = await punch();
    expect(pending.success, isTrue);
    expect(pending.isPending, isTrue);
    expect(pending.outcomeTitle(isCheckIn: true), 'Pending approval');
    today['data'] = [_record(status: 'Pending')];
    responseData = _result(isCheckIn: false);
    expect((await punch(isCheckIn: false)).success, isTrue);
  });

  test(
    'a success flag cannot override the employee radius allowance',
    () async {
      for (final isCheckIn in [true, false]) {
        if (!isCheckIn) {
          responseData = _result();
          await punch();
        }
        final record = _record(
          isCheckIn: isCheckIn,
          distance: 250,
          branchLocation: '11.5022483040148,104.9',
          phoneLocation: '11.5,104.9',
        );
        (record['compared_values'] as Map)['Location Summary'] = {
          'policyRadius': 100,
          'isCheckinRange': true,
        };
        responseData = {
          ..._result(isCheckIn: isCheckIn),
          'primaryLocation': '11.5022483040148,104.9',
          'data': record,
        };
        final result = await punch(isCheckIn: isCheckIn);
        expect(result.success, isFalse);
        expect(result.isInRange, isFalse);
        expect(result.distanceMeters, closeTo(250, 0.001));
        expect(result.radiusMeters, 100);
        expect(result.outOfRangeMessage, contains('250 m'));
      }
    },
  );

  test('each employee uses the returned radius, including its boundary', () {
    for (final (distance, radius, accepted) in [
      (26.0, 25.0, false),
      (150.0, 200.0, true),
      (25.0, 25.0, true),
      (0.0, 0.0, true),
      (0.001, 0.0, false),
    ]) {
      final result = PunchResult.fromJson({
        'success': true,
        'isCheckinRange': true,
        'policyRadius': radius,
        'data': _record(
          distance: distance,
          radius: radius,
          branchLocation: null,
          phoneLocation: null,
        ),
      });
      expect(result.success, accepted);
    }
  });

  test('check-out can use an allowed secondary branch', () async {
    await punch();
    responseData = {
      ..._result(isCheckIn: false),
      'primaryLocation': '11.54496608029594,104.9',
      'WithPrimary': 5000,
    };
    final result = await punch(isCheckIn: false);
    expect(result.success, isTrue);
    expect(result.distanceMeters, closeTo(25, 0.001));
  });

  test(
    'check-in at the matched allowed branch ignores a distant primary office',
    () async {
      final record = _record();
      final compared = record['compared_values'] as Map;
      compared['Default Location'] = '0,1.8';
      (compared['Matched Branch'] as Map)['id'] = 12;
      (compared['Location Summary'] as Map)['WithPrimary'] = 200000;
      responseData = {
        ..._result(),
        'primaryLocation': '0,1.8',
        'WithPrimary': 200000,
        'data': record,
      };
      final result = await punch(qr: '$_officeQr?branch_id=12');
      expect(result.success, isTrue);
      expect(result.distanceMeters, closeTo(25, 0.001));
      expect(storage.values, isNotEmpty);
      today['data'] = [record];
      expect((await api.fetchTodayAttendance()).checkedIn, isTrue);
    },
  );

  test(
    'a branch 200 km away is never shown as the primary office 5 km away',
    () async {
      final record = _record(
        branchLocation: '0,1.8',
        phoneLocation: '0,0',
        distance: 5000,
      );
      final compared = record['compared_values'] as Map;
      compared['Default Location'] = '0,0.0449660803';
      compared['Matched Branch'] = {
        'id': 12,
        'name': 'Far branch',
        'location': '0,1.8',
        'distance': 5000,
      };
      responseData = {
        ..._result(),
        'primaryLocation': '0,0.0449660803',
        'WithPrimary': 5000,
        'data': record,
      };
      final result = await punch(
        qr: '$_officeQr?branch_id=12',
        latitude: 0,
        longitude: 0,
      );
      expect(result.success, isFalse);
      expect(result.distanceMeters, closeTo(200150.86796, 0.01));
      expect(result.outOfRangeMessage, contains('200.15 km'));
      expect(result.outOfRangeMessage, contains('Far branch'));
      expect(storage.values, isEmpty);
    },
  );

  test(
    'a response for another branch cannot supply the scanned branch distance',
    () async {
      final result = await punch(qr: '$_officeQr?branch_id=12');
      expect(result.success, isFalse);
      expect(result.distanceMeters, isNull);
      expect(result.outOfRangeMessage, contains('scanned branch'));
      expect(storage.values, isEmpty);
    },
  );

  test(
    'legacy responses without optional coordinates still honor server radius evidence',
    () async {
      responseData = {
        ..._result(),
        'data': _record(branchLocation: null, phoneLocation: null),
      };
      expect((await punch()).success, isTrue);
    },
  );

  test('a matched branch outside its radius still rejects check-in', () async {
    final record = _record(
      distance: 0,
      branchLocation: '11.54496608029594,104.9',
      phoneLocation: '11.5,104.9',
    );
    (record['compared_values'] as Map)['Location Summary'] = {
      'policyRadius': 100,
      'WithPrimary': 5000,
      'isCheckinRange': true,
      'conditionalLocation': [
        {'id': 2, 'distance': 0},
      ],
    };
    responseData = {
      ..._result(),
      'primaryLocation': '11.54496608029594,104.9',
      'WithPrimary': 5000,
      'data': record,
    };
    final result = await punch();
    expect(result.success, isFalse);
    expect(result.distanceMeters, closeTo(5000, 0.001));
    expect(storage.values, isEmpty);

    today['data'] = [record];
    final controller = PunchController(api: api);
    await controller.fetchToday();
    expect(controller.isCheckedIn.value, isFalse);
  });

  test(
    'a missing primary-office distance does not block a valid matched office',
    () async {
      responseData = {..._result(), 'WithPrimary': null};
      final result = await punch();
      expect(result.success, isTrue);
      expect(result.isInRange, isTrue);
      expect(storage.values, isNotEmpty);
    },
  );

  test('summary-only distances include allowed secondary branches', () {
    final result = PunchResult.fromJson({
      'success': true,
      'policyRadius': 100,
      'WithPrimary': 5000,
      'conditionalLocation': [
        {'id': 2, 'distance': 40},
      ],
      'data': {
        ..._record(isCheckIn: false, branchLocation: null, phoneLocation: null),
        'accuracy_meter': null,
        'compared_values': {'Check Direction': 'out'},
      },
    });
    expect(result.success, isTrue);
    expect(result.distanceMeters, 40);
  });

  test('malformed location evidence never accepts attendance', () async {
    for (final value in [-1, 'NaN', 'Infinity', 'invalid']) {
      responseData = {..._result(), 'policyRadius': value};
      expect((await punch()).success, isFalse);
      responseData = {
        ..._result(),
        'data': {..._record(), 'accuracy_meter': value},
      };
      expect((await punch()).success, isFalse);
    }
    expect(storage.values, isEmpty);
  });

  test('missing work-policy confirmation is not a successful scan', () async {
    responseData = {
      'success': true,
      'data': {
        ..._record(),
        'accuracy_meter': null,
        'compared_values': {'Check Direction': 'in'},
      },
    };
    expect((await punch()).success, isFalse);
    expect(storage.values, isEmpty);
  });

  test(
    'missing employee policy or schedule preserves the server error',
    () async {
      statusCode = 422;
      for (final message in [
        'The employee location policy is not configured.',
        'The employee work schedule is not configured.',
      ]) {
        responseData = {'success': false, 'message': message};
        await expectLater(
          punch(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.displayMessage,
              'message',
              message,
            ),
          ),
        );
      }
      expect(storage.values, isEmpty);
    },
  );

  test(
    'refresh cannot show rejected attendance as checked in or out',
    () async {
      final controller = PunchController(api: api);
      today['checked_out'] = true;
      today['data'] = [
        _record(distance: 250),
        _record(id: 102, isCheckIn: false, status: 'Pending', distance: 250),
      ];
      await controller.fetchToday();
      expect(controller.isCheckedIn.value, isFalse);
      expect(controller.isCheckedOut.value, isFalse);
      expect(controller.checkInTime.value, isEmpty);
      expect(controller.checkOutTime.value, isEmpty);
      expect(controller.timeWorking.value, isEmpty);
    },
  );

  test('rejected check-out keeps the card ready to scan out again', () async {
    final controller = PunchController(api: api);
    today['checked_out'] = true;
    today['data'] = [
      _record(),
      _record(id: 102, isCheckIn: false, distance: 250),
    ];
    await controller.fetchToday();
    expect(controller.isCheckedIn.value, isTrue);
    expect(controller.isCheckedOut.value, isFalse);
    expect(controller.checkInTime.value, '8:00 AM');
    expect(controller.checkOutTime.value, isEmpty);
  });

  test(
    'pending time-policy approval cannot override a failed radius',
    () async {
      responseData = {
        ..._result(status: 'Pending'),
        'data': _record(status: 'Pending', distance: 250),
      };
      final result = await punch();
      expect(result.success, isFalse);
      expect(result.isPending, isFalse);
      expect(storage.values, isEmpty);
    },
  );

  test('in-range early check-out is clearly pending approval', () async {
    await punch();
    responseData = _result(isCheckIn: false, status: 'Pending');
    final result = await punch(isCheckIn: false);
    expect(result.success, isTrue);
    expect(result.isPending, isTrue);
    expect(result.outcomeTitle(isCheckIn: false), 'Pending approval');
  });

  test('the reported 5591.497 m scan fails a 150 m employee policy', () async {
    final failedRecord = {
      ..._record(
        id: 92,
        employee: 2,
        status: 'Failed',
        distance: 5591.497,
        radius: 150,
      ),
      'time': '16:55:32',
      'check_location': '11.540200,104.85816',
      'attendance_type_id': 1,
      'late_minutes': 535,
      'early_minutes': 0,
      'root_caused': {'Caused 1=': 'Location Out of Radius'},
      'compared_values': {
        'Check Direction': 'in',
        'Work Policy': '[DS][Full Time][Full Time Employee Policy]',
        'Default Location': '11.547273130564294,104.90898218012883',
        'Location Summary': {
          'policyRadius': 150,
          'WithPrimary': 5591.497,
          'isCheckinRange': false,
        },
        'Matched Branch': {'id': 1, 'distance': 5591.497},
        'Radius Allowance(M)': 150,
        'Flex Schedule Time IN': '08:00:00',
        'Flex Schedule Time OUT': '17:00:00',
        'All Set Checked': false,
      },
      'type': {'id': 1, 'name': 'Check In', 'short_name': 'In'},
    };
    for (final code in [422, 200]) {
      statusCode = code;
      responseData = {
        'success': false,
        'message': 'Your location is outside the permitted branch radius.',
        'policyRadius': 150,
        'WithPrimary': 5591.497,
        'isCheckinRange': false,
        'conditionalLocation': [
          {'id': 1, 'distance': 5591.497},
        ],
        'data': failedRecord,
      };
      final result = await api.recordAttendance(
        isCheckIn: true,
        attendanceTypeId: 1,
        latitude: 11.540200,
        longitude: 104.85816,
        qrCode: _officeQr,
      );
      expect(result.success, isFalse);
      expect(result.record?.accepted, isFalse);
      expect(result.outOfRangeMessage, contains('5.59 km'));
      expect(result.outOfRangeMessage, contains('150 m'));
      expect(storage.values, isEmpty);
    }
    today['data'] = [failedRecord];
    today['checked_in'] = true;
    final controller = PunchController(api: api);
    await controller.fetchToday();
    expect(controller.isCheckedIn.value, isFalse);
    expect(controller.isCheckedOut.value, isFalse);
    expect(controller.checkInTime.value, isEmpty);
  });

  test(
    'explicit approval still counts according to the backend policy',
    () async {
      today['data'] = [_record(status: 'Success(Via Approval)', distance: 250)];
      final attendance = await api.fetchTodayAttendance();
      expect(attendance.checkedIn, isTrue);
      expect(attendance.checkInRecord?.accepted, isTrue);
      // An original out-of-range snapshot cannot authorize a new direct scan.
      responseData = {
        ..._result(),
        'data': _record(status: 'Success(Via Approval)', distance: 250),
      };
      expect((await punch()).success, isFalse);
    },
  );

  test('validation and conflict errors do not save a QR', () async {
    for (final status in [401, 409, 422]) {
      statusCode = status;
      responseData = {
        'success': false,
        'message': 'Attendance rejected.',
        'errors': {
          'attendance_type_id': ['Choose a check-in or check-out type.'],
        },
      };
      await expectLater(punch(), throwsA(isA<ApiException>()));
      expect(storage.values, isEmpty);
    }
  });

  test('explicit failed location cannot be treated as success', () async {
    responseData = {..._result(inRange: false), 'success': true};
    expect((await punch()).success, isFalse);
    expect(storage.values, isEmpty);
  });

  test(
    'existing fixed QR values never replace fresh GPS and the selected type',
    () async {
      await punch(qr: _fixedOfficeQr);
      expect(
        Uri.decodeComponent(requests.single.uri.path),
        '/api/v1/employee/attendance/3/11.5,104.9',
      );
      expect(requests.single.data, {'qr_code': _fixedOfficeQr});
    },
  );

  test('unrelated QR codes cannot make any attendance request', () async {
    final server = Uri.parse(AppUrlService.baseUrl).origin;
    for (final qr in [
      'office-qr',
      'random QR text',
      'https://example.com',
      'https://office.example/api/v1/employee/attendance/1/11.5,104.9',
      '$server/api/v1/employee/schedules/1/11.5,104.9',
      '$server/api/v1/employee/attendance/1/91,104.9',
      '$server/api/v1/employee/attendance/1/11.5,NaN',
    ]) {
      for (final isCheckIn in [true, false]) {
        await expectLater(
          punch(qr: qr, isCheckIn: isCheckIn),
          throwsA(isA<ApiException>()),
        );
      }
    }
    expect(requests, isEmpty);
    expect(storage.values, isEmpty);
  });

  test('the backend can reject an unissued QR with a valid action', () async {
    statusCode = 422;
    responseData = {
      'success': false,
      'message': 'This QR code was not issued for an allowed office.',
    };
    await expectLater(
      punch(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.displayMessage,
          'message',
          'This QR code was not issued for an allowed office.',
        ),
      ),
    );
    expect(storage.values, isEmpty);
  });

  test('attendance types preserve API IDs and read short names', () {
    expect(PunchType.fromJson({'id': '7', 'name': 'Check In'}).id, 7);
    final out = PunchType.fromJson({
      'attendance_type_id': '12',
      'type_name': 'Departure',
      'short_name': 'OUT',
    });
    expect(out.id, 12);
    expect(out.direction, 'out');
    for (final id in [null, 0, -1, 'invalid']) {
      expect(() => PunchType.fromJson({'id': id}), throwsFormatException);
    }
  });

  test('type selection follows Laravel names without a neutral fallback', () {
    final types = [
      PunchType.fromJson({'id': 1, 'name': 'bcbv', 'short_name': 'vg'}),
      PunchType.fromJson({
        'id': 3,
        'name': 'Arrival',
        'short_name': 'check_in',
      }),
      PunchType.fromJson({'id': 9, 'name': 'CHECK-OUT'}),
    ];
    expect(PunchType.forDirection(types, isCheckIn: true).id, 3);
    expect(PunchType.forDirection(types, isCheckIn: false).id, 9);
    expect(
      () => PunchType.forDirection([types.first, types.last], isCheckIn: true),
      throwsStateError,
    );
    expect(
      PunchType.fromJson({'id': 4, 'name': 'Punch Out'}).direction,
      isNull,
    );
    expect(
      PunchType.fromJson({
        'id': 4,
        'name': 'Check In',
        'short_name': 'OUT',
      }).direction,
      'in',
    );
  });

  test('type list ignores malformed IDs and supports paginated data', () async {
    responseData = {
      'data': {
        'data': [
          {'name': 'Missing ID'},
          {'id': 0, 'name': 'Invalid ID'},
          {'id': '9', 'name': 'Departure', 'short_name': 'OUT'},
        ],
      },
    };
    final types = await api.fetchAttendanceTypes();
    expect(types.map((type) => type.id), [9]);
    expect(types.single.direction, 'out');
  });

  test('empty type list produces an actionable error', () async {
    responseData = {'data': <dynamic>[]};
    await expectLater(api.fetchAttendanceTypes(), throwsA(isA<ApiException>()));
  });
}
