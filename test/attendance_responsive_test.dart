import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/punch_countroller.dart';
import 'package:test_flutter/features/hrms_app/screens/home/attendance_check.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/attendance_card.dart';

class _TestPunchController extends PunchController {
  int taps = 0;

  @override
  Future<void> fetchToday() async {}

  @override
  Future<void> onButtonTap() async {
    taps++;
  }
}

void main() {
  late _TestPunchController punch;

  setUp(() {
    Get.testMode = true;
    Get.put(HomeController())
      ..currentTime.value = '11:59 PM'
      ..currentDate.value = 'Wed 30 Sep 2026';
    punch = _TestPunchController();
    Get.put<PunchController>(punch);
    punch.checkInTime.value = '11:59 AM';
    punch.checkOutTime.value = '11:59 PM';
    punch.timeWorking.value = '12h 00m';
  });

  tearDown(Get.reset);

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
    const Size(768, 1024),
    const Size(1024, 768),
  ]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets('attendance card fits $size with text scale $textScale', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: AttendanceCard(),
              ),
            ),
          ),
        );

        for (final label in [
          'Attendance Check',
          'Check in',
          'Check out',
          'Times Working',
          '11:59 AM',
          '12h 00m',
        ]) {
          expect(find.text(label), findsOneWidget);
          final bounds = tester.getRect(find.text(label));
          expect(bounds.left, greaterThanOrEqualTo(16));
          expect(bounds.right, lessThanOrEqualTo(size.width - 16));
        }
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text('Scan In'));
        await tester.tap(find.text('Scan In'));
        expect(punch.taps, 1);

        punch.isCheckedIn.value = true;
        await tester.pump();
        expect(find.text('Scan Out'), findsOneWidget);
        punch.isCheckedOut.value = true;
        await tester.pump();
        expect(find.text('Done'), findsOneWidget);
        punch.isLoading.value = true;
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  for (final textScale in [1.0, 2.0]) {
    testWidgets('attendance page scrolls in landscape at scale $textScale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(568, 320);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
            ),
            child: child!,
          ),
          home: const AttendanceCheck(),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
      await tester.pump();
      await Scrollable.ensureVisible(
        tester.element(find.text('Scan In')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      expect(find.text('Scan In').hitTestable(), findsOneWidget);
      final bounds = tester.getRect(find.byType(AttendanceCard));
      expect(bounds.left, greaterThanOrEqualTo(24));
      expect(bounds.right, lessThanOrEqualTo(568 - 24));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
