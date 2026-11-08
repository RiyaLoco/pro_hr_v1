import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/models/res/attendance_history_models.dart';
import 'package:test_flutter/data/models/res/attendance_summary_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/features/hrms_app/controllers/attendance_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/widgets/attend_stats_row.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/widgets/history_card.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/widgets/weekly_progress_card.dart';

const _summaryJson = <String, dynamic>{
  'total_hours': 0,
  'on_time_percentage': null,
  'leave_days': 2,
  'weekly_progress': {
    'from': '2026-10-26',
    'to': '2026-11-01',
    'worked_hours': 0,
    'target_hours': 9,
    'percentage': 0,
    'target_source': 'schedule_details',
  },
};

Map<String, dynamic> _day(String date) => {
  'date': date,
  'check_in': '08:00:00',
  'check_out': '17:00:00',
  'worked_minutes': 540,
  'worked_hours': 9,
  'late_minutes': 0,
  'early_minutes': 0,
  'status': 'on_time',
  'events': [
    {
      'time': '08:00:00',
      'status': 'Success',
      'type': {'id': 1, 'name': 'Check IN'},
    },
    {
      'time': '17:00:00',
      'status': 'Success',
      'type': {'id': 2, 'name': 'Check OUT'},
    },
  ],
};

Map<String, dynamic> _page({
  List<Map<String, dynamic>> history = const [],
  int current = 1,
  int last = 1,
}) => {
  'success': true,
  // Raw events have different pagination and must not be rendered as days.
  'data': [
    {'time': '12:30:00', 'status': 'Failed'},
  ],
  'summary': _summaryJson,
  'history': history,
  'history_meta': {'current_page': current, 'last_page': last},
  'meta': {'current_page': 1, 'last_page': 99},
};

ApiController _api() {
  final api = ApiController();
  api.dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == AppUrlService.leaveRemainings) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'year': 2026,
                'data': [
                  {
                    'year': 2026,
                    'leave_type_id': null,
                    'days_entitled': '18.0',
                    'days_used': '5.5',
                    'days_remaining': '12.5',
                  },
                ],
              },
            ),
          );
        } else {
          handler.next(options);
        }
      },
    ),
  );
  return api;
}

void main() {
  tearDown(() => ApiController.setToken(null));

  test(
    'empty history still supplies summary and uses history pagination',
    () async {
      final api = _api();
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: _page()),
          ),
        ),
      );
      final controller = AttendanceController(api: api);
      await controller.fetchAttendance();
      expect(controller.errorMessage.value, isNull);
      expect(controller.records, isEmpty);
      expect(controller.hasMore.value, isFalse);
      expect(controller.summary.value?.totalHours, 0);
      expect(controller.summary.value?.onTimePercentage, isNull);
      expect(controller.leaveRemainingDays.value, 12.5);
      expect(controller.leaveBalanceError.value, isNull);
      expect(controller.summary.value?.weeklyProgress?.hoursLabel, '0/40');
      expect(controller.summary.value?.weeklyProgress?.progress, 0);
    },
  );

  testWidgets('summary cards display zero and unknown values correctly', (
    tester,
  ) async {
    final summary = AttendanceSummary.fromJson(_summaryJson);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              WeeklyProgressCard(progress: summary.weeklyProgress!),
              AttendanceStatsRow(summary: summary, leaveRemainingDays: 12.5),
            ],
          ),
        ),
      ),
    );
    expect(find.text('0h'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('12.5d'), findsOneWidget);
    expect(find.text('LEAVE REMAIN'), findsOneWidget);
    expect(find.text('0/40'), findsOneWidget);
    expect(find.text('40 hours remaining this week.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'weekly progress uses 40 hours with missing targets and clamps overtime',
    () {
      final none = WeeklyAttendanceProgress.fromJson({'target_hours': 0});
      expect(none.progress, 0);
      expect(none.hoursLabel, '—/40');
      expect(none.message, 'Weekly progress is unavailable.');
      final noSchedule = WeeklyAttendanceProgress.fromJson({
        'worked_hours': 0,
        'target_hours': 0,
      });
      expect(noSchedule.message, '40 hours remaining this week.');
      final exceeded = WeeklyAttendanceProgress.fromJson({
        'worked_hours': '42.5',
        'target_hours': '9',
        'percentage': 472.22,
      });
      expect(exceeded.progress, 1);
      expect(exceeded.hoursLabel, '42.5/40');
      expect(exceeded.message, 'You have reached your weekly goal.');
    },
  );

  test(
    'authenticated history uses the supplied endpoint and daily fields',
    () async {
      ApiController.setToken('sample-token');
      final api = _api();
      RequestOptions? sent;
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sent = options;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: _page(history: [_day('2026-10-28')]),
              ),
            );
          },
        ),
      );
      final controller = AttendanceController(api: api);
      await controller.fetchAttendance();
      expect(sent?.path, AppUrlService.attendance);
      expect(sent?.uri.path, '/api/v1/employee/attendance');
      expect(sent?.method, 'GET');
      expect(sent?.queryParameters, {'page': 1});
      expect(sent?.headers['Authorization'], 'Bearer sample-token');
      final record = controller.records.single;
      expect(record.date, '2026-10-28');
      expect(record.dateLabel, 'Oct 28, 2026');
      expect(record.checkInLabel, '08:00 AM');
      expect(record.checkOutLabel, '05:00 PM');
      expect(record.statusLabel, 'ON TIME');
      expect(record.workedHours, 9);
      expect(controller.errorMessage.value, isNull);
      expect(controller.isLoading.value, isFalse);
    },
  );

  test(
    'pagination appends unique days and refresh resets to the first page',
    () async {
      final api = _api();
      final pages = <int>[];
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final page = options.queryParameters['page'] as int;
            pages.add(page);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: _page(
                  current: page,
                  last: 2,
                  history: [
                    _day('2026-10-28'),
                    if (page == 2) _day('2026-10-27'),
                  ],
                ),
              ),
            );
          },
        ),
      );
      final controller = AttendanceController(api: api);
      await controller.fetchAttendance();
      final summary = controller.summary.value;
      expect(controller.hasMore.value, isTrue);
      await controller.loadMore();
      expect(controller.records.map((r) => r.date), [
        '2026-10-28',
        '2026-10-27',
      ]);
      expect(controller.summary.value, same(summary));
      expect(controller.hasMore.value, isFalse);
      await controller.loadMore();
      expect(pages, [1, 2]);
      await controller.fetchAttendance();
      expect(pages, [1, 2, 1]);
      expect(controller.records, hasLength(1));
      expect(controller.hasMore.value, isTrue);
    },
  );

  test('page failure keeps data and retry requests the same page', () async {
    final api = _api();
    final pages = <int>[];
    var fail = true;
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final page = options.queryParameters['page'] as int;
          pages.add(page);
          final failed = page == 2 && fail;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: failed ? 403 : 200,
              data: failed
                  ? {'success': false, 'message': 'Attendance unavailable.'}
                  : _page(
                      current: page,
                      last: 2,
                      history: [_day(page == 1 ? '2026-10-28' : '2026-10-27')],
                    ),
            ),
          );
        },
      ),
    );
    final controller = AttendanceController(api: api);
    await controller.fetchAttendance();
    await controller.loadMore();
    expect(controller.records, hasLength(1));
    expect(controller.loadMoreError.value, 'Attendance unavailable.');
    expect(controller.hasMore.value, isTrue);
    expect(controller.isLoadingMore.value, isFalse);
    fail = false;
    await controller.loadMore();
    expect(pages, [1, 2, 2]);
    expect(controller.loadMoreError.value, isNull);
    expect(controller.records, hasLength(2));
  });

  test('failed refresh keeps records and summary and can be retried', () async {
    final api = _api();
    var fail = false;
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: fail ? 401 : 200,
            data: fail
                ? {'success': false, 'message': 'Please log in again.'}
                : _page(history: [_day('2026-10-28')]),
          ),
        ),
      ),
    );
    final controller = AttendanceController(api: api);
    await controller.fetchAttendance();
    final summary = controller.summary.value;
    fail = true;
    await controller.fetchAttendance();
    expect(controller.records, hasLength(1));
    expect(controller.summary.value, same(summary));
    expect(controller.errorMessage.value, 'Please log in again.');
    expect(controller.isLoading.value, isFalse);
    fail = false;
    await controller.fetchAttendance();
    expect(controller.errorMessage.value, isNull);
  });

  test(
    'malformed daily history cannot be confused with empty history',
    () async {
      final api = _api();
      Object? history = <dynamic>[];
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {..._page(), 'history': history},
            ),
          ),
        ),
      );
      final controller = AttendanceController(api: api);
      await controller.fetchAttendance();
      expect(controller.records, isEmpty);
      expect(controller.errorMessage.value, isNull);
      for (final invalid in [
        null,
        'invalid',
        [false],
        [
          {'time': '08:00:00'},
        ],
      ]) {
        history = invalid;
        await controller.fetchAttendance();
        expect(controller.errorMessage.value, isNotNull);
        expect(controller.isLoading.value, isFalse);
      }
    },
  );

  testWidgets('daily history fits a narrow screen and shows missing checkout', (
    tester,
  ) async {
    final record = AttendanceRecord.fromJson({
      ..._day('2026-10-28'),
      'check_out': null,
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 280, child: HistoryCard(record)),
          ),
        ),
      ),
    );
    expect(find.text('Oct 28, 2026'), findsOneWidget);
    expect(find.text('08:00 AM'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('ON TIME'), findsOneWidget);
    expect(record.workedHours, 9);
    expect(tester.takeException(), isNull);
  });
}
