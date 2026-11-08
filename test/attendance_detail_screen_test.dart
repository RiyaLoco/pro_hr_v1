import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:test_flutter/data/models/res/attendance_history_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/attendance_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/attendance_detail_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/attendance_screen.dart';

Map<String, dynamic> _day(String date) => {
  'date': date,
  'status': 'late',
  'check_in': '08:15:00',
  'check_out': '17:00:00',
  'worked_minutes': 525,
  'late_minutes': 15,
  'early_minutes': 0,
  'events': [
    {
      'time': '08:10:00',
      'status': 'Failed',
      'type': {'name': 'Check IN'},
    },
    {
      'time': '08:15:00',
      'status': 'Success',
      'type': {'name': 'Check IN'},
      'compared_values': {
        'Matched Branch': {'id': 2, 'name': 'Head office'},
      },
    },
    {
      'time': '17:00:00',
      'status': 'Pending',
      'type': {'short_name': 'Out'},
    },
  ],
};

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(HomeController());
  });

  tearDown(Get.reset);

  test(
    'daily history preserves punch attempts and optional event metadata',
    () {
      final record = AttendanceRecord.fromJson(_day('2026-11-06'));
      expect(record.workedHours, 8.75);
      expect(record.events.map((event) => event.direction), [
        'in',
        'in',
        'out',
      ]);
      expect(record.events.map((event) => event.status), [
        'Failed',
        'Success',
        'Pending',
      ]);
      expect(record.events[1].locationPolicy.branchName, 'Head office');
      expect(record.events.first.locationPolicy.branchName, isNull);

      final withoutEvents = Map<String, dynamic>.from(_day('2026-11-06'))
        ..remove('events');
      expect(AttendanceRecord.fromJson(withoutEvents).events, isEmpty);
    },
  );

  testWidgets('history opens the selected day and returns without refetching', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var requests = 0;
    final api = ApiController();
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests++;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'history': [_day('2026-11-07'), _day('2026-11-06')],
                'history_meta': {'current_page': 1, 'last_page': 1},
              },
            ),
          );
        },
      ),
    );
    Get.put(AttendanceController(api: api));

    await tester.pumpWidget(
      GetMaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const AttendanceScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Nov 6, 2026'), 200);
    await Scrollable.ensureVisible(
      tester.element(find.text('Nov 6, 2026')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nov 6, 2026'));
    await tester.pumpAndSettle();

    final screen = tester.widget<AttendanceDetailScreen>(
      find.byType(AttendanceDetailScreen),
    );
    expect(screen.record.date, '2026-11-06');
    expect(find.text('Attendance Detail'), findsOneWidget);
    expect(find.text('8.75h'), findsOneWidget);
    expect(find.text('15 minutes'), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.text('Head office')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Head office').hitTestable(), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new).hitTestable());
    await tester.pumpAndSettle();
    expect(find.byType(AttendanceDetailScreen), findsNothing);
    expect(find.byType(AttendanceScreen), findsOneWidget);
    expect(find.text('Nov 6, 2026').hitTestable(), findsOneWidget);
    expect(requests, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final textScale in [1.0, 2.0]) {
    testWidgets('missing attendance fits a narrow screen at scale $textScale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final record = AttendanceRecord.fromJson({
        'date': '2026-11-06',
        'status': 'on_time',
        'check_in': '08:00:00',
      });

      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: AttendanceDetailScreen(record: record),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Not available'), findsNWidgets(3));
      expect(find.text('Not recorded'), findsOneWidget);
      expect(find.text('0 minutes'), findsNothing);
      expect(find.text('0h'), findsNothing);

      await Scrollable.ensureVisible(
        tester.element(find.text('No punch activity available for this day.')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      expect(
        find.text('No punch activity available for this day.').hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
