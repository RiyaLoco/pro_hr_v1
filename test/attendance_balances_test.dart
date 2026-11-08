import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/models/res/attendance_history_models.dart';
import 'package:test_flutter/data/models/res/attendance_summary_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/features/hrms_app/controllers/attendance_controller.dart';

Map<String, dynamic> _balance({
  int? type,
  String entitled = '18.0',
  String used = '2.5',
  String remaining = '15.5',
}) => {
  'year': 2026,
  'leave_type_id': type,
  'days_entitled': entitled,
  'days_used': used,
  'days_remaining': remaining,
};

void main() {
  tearDown(() => ApiController.setToken(null));

  test(
    'remaining leave uses the authenticated endpoint and decimal balances',
    () async {
      ApiController.setToken('test-token');
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
                data: {
                  'success': true,
                  'year': 2026,
                  'data': [_balance(type: 2)],
                },
              ),
            );
          },
        ),
      );

      final balances = await api.fetchLeaveRemaining(
        year: 2026,
        leaveTypeId: 2,
      );
      expect(sent?.uri.path, '/api/v1/employee/leave-remainings');
      expect(sent?.method, 'GET');
      expect(sent?.queryParameters, {'year': 2026, 'leave_type_id': 2});
      expect(sent?.headers['Authorization'], 'Bearer test-token');
      expect(balances.single.daysRemaining, 15.5);
      expect(balances.single.daysUsed, 2.5);
      expect(balances.single.year, 2026);
      expect(balances.single.leaveTypeId, 2);
    },
  );

  test(
    'attendance sums remaining balances without deducting used days again',
    () async {
      final api = ApiController();
      var failBalance = false;
      var balances = <Map<String, dynamic>>[
        _balance(type: 1),
        _balance(type: 2, entitled: '7.0', used: '0.0', remaining: '7.0'),
      ];
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final isBalance = options.path == AppUrlService.leaveRemainings;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: isBalance && failBalance ? 503 : 200,
                data: isBalance
                    ? (failBalance
                          ? {'success': false, 'message': 'Unavailable'}
                          : {'success': true, 'year': 2026, 'data': balances})
                    : {
                        'success': true,
                        'history': [
                          {
                            'date': '2026-11-02',
                            'status': 'on_time',
                            'worked_hours': '9.0',
                          },
                        ],
                        'history_meta': {'current_page': 1, 'last_page': 1},
                        'summary': {'total_hours': '9.0', 'leave_days': 99},
                      },
              ),
            );
          },
        ),
      );
      final controller = AttendanceController(api: api);
      await controller.fetchAttendance();
      expect(controller.leaveRemainingDays.value, 22.5);
      expect(controller.summary.value?.totalHours, 9);
      expect(controller.records.single.workedHours, 9);
      expect(controller.errorMessage.value, isNull);

      failBalance = true;
      await controller.fetchAttendance();
      expect(controller.records, hasLength(1));
      expect(controller.summary.value?.totalHours, 9);
      expect(controller.errorMessage.value, isNull);
      expect(controller.leaveRemainingDays.value, isNull);
      expect(controller.leaveBalanceError.value, isNotNull);

      failBalance = false;
      balances = [];
      await controller.fetchAttendance();
      expect(controller.leaveRemainingDays.value, 0);
      expect(controller.leaveBalanceError.value, isNull);
    },
  );

  test('malformed balances do not appear as zero remaining leave', () async {
    final api = ApiController();
    Object? data;
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'data': data},
          ),
        ),
      ),
    );
    for (final invalid in [
      null,
      'invalid',
      [false],
      [_balance(remaining: 'NaN')],
    ]) {
      data = invalid;
      await expectLater(api.fetchLeaveRemaining(), throwsFormatException);
    }
  });

  test(
    'weekly progress uses a 40-hour goal with a legacy 9-hour server target',
    () {
      final progress = WeeklyAttendanceProgress.fromJson({
        'worked_hours': '9.0',
        'target_hours': '9.0',
        'percentage': 100,
      });
      expect(progress.hoursLabel, '9/40');
      expect(progress.progress, 0.225);
      expect(progress.message, '31 hours remaining this week.');
    },
  );

  test('weekly goal is reached only at 40 worked hours', () {
    const belowGoal = WeeklyAttendanceProgress(workedHours: 39.5);
    expect(belowGoal.progress, 0.9875);
    expect(belowGoal.message, '0.5 hours remaining this week.');
    const atGoal = WeeklyAttendanceProgress(workedHours: 40);
    expect(atGoal.progress, 1);
    expect(atGoal.message, 'You have reached your weekly goal.');
  });

  test(
    'worked hours accept decimal strings and missing hours fall back to minutes',
    () {
      expect(
        AttendanceSummary.fromJson({'total_hours': '9.5'}).totalHours,
        9.5,
      );
      expect(AttendanceSummary.fromJson({'total_hours': 0}).totalHours, 0);
      expect(AttendanceSummary.fromJson({}).totalHours, isNull);
      final record = AttendanceRecord.fromJson({
        'date': '2026-11-02',
        'status': 'late',
        'worked_minutes': 525,
      });
      expect(record.workedHours, 8.75);
      expect(
        AttendanceRecord.fromJson({
          'date': '2026-11-02',
          'status': 'on_time',
        }).workedHours,
        isNull,
      );
    },
  );
}
