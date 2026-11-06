import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/overtime_models.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_request_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/overtime_detail_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/overtime_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/entry_list.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/overtime_status_tabs.dart';

void main() {
  final now = DateTime(2026, 11, 18);
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  test(
    'web model parses Laravel decimal strings and related rate and approver',
    () {
      final request = OtRequest.fromJson({
        'id': '12',
        'employee_id': '3',
        'date': '2026-11-17',
        'start_time': '17:00:00',
        'end_time': '19:30:00',
        'hours': '2.50',
        'ot_rate_id': '2',
        'status': 'Approved',
        'reason': 'Stock count',
        'approved_by': 7,
        'approvedby': {'id': 7, 'name': 'Sample reviewer'},
        'created_by': 9,
        'createdby': {'id': 9, 'name': 'Sample employee'},
        'ot_rate': {
          'id': 2,
          'name': 'Rest day',
          'multiplier': '2.00',
          'description': 'Sample rate',
        },
      });
      expect(request.hoursLabel, '2.5 hours');
      expect(request.timeLabel, '5:00 PM – 7:30 PM');
      expect(request.rateLabel, 'Rest day · 2×');
      expect(request.status, OvertimeStatus.approved);
      expect(request.approvedBy, 7);
      expect(request.reviewerLabel, 'Reviewed by Sample reviewer');
      expect(parseOvertimeStatus('unexpected'), OvertimeStatus.unknown);
    },
  );

  test('preview totals and combined filters use the request data', () async {
    final controller = OvertimeController(now: () => now);
    addTearDown(controller.onClose);
    await controller.fetchEntries();
    expect(controller.totalApprovedHours, '6.5h');
    expect(controller.thisMonthHours, '7.5h');
    expect(controller.pendingCount, 1);
    controller.selectedStatus.value = OvertimeStatus.approved;
    controller.updateSearch('inventory');
    expect(controller.filteredEntries.single.hours, 2.5);
    controller.updateSearch('monthly');
    expect(controller.filteredEntries, isEmpty);
    controller.resetFilters();
    expect(controller.filteredEntries, hasLength(4));
  });

  test(
    'overnight preview request keeps rate ID and survives refresh',
    () async {
      final overtime = OvertimeController(now: () => now);
      final form = OvertimeRequestController(overtime: overtime);
      addTearDown(form.onClose);
      addTearDown(overtime.onClose);
      await overtime.fetchEntries();
      form.date.value = now;
      form.startTime.value = const TimeOfDay(hour: 22, minute: 30);
      form.endTime.value = const TimeOfDay(hour: 1, minute: 0);
      form.rate.value = overtime.rates[1];
      form.reasonController.text = 'Complete overnight maintenance';
      expect(form.endsNextDay, isTrue);
      expect(form.hours, 2.5);
      expect(form.savePreview(), isTrue);
      final added = overtime.allEntries.first;
      expect(added.status, OvertimeStatus.pending);
      expect(added.otRateId, 2);
      expect(added.startTime, '22:30:00');
      expect(added.endTime, '01:00:00');
      await overtime.fetchEntries();
      expect(overtime.allEntries.where((r) => r.id == added.id), hasLength(1));
      expect(overtime.pendingCount, 2);
    },
  );

  test('incomplete or zero-duration requests cannot be saved', () async {
    final overtime = OvertimeController(now: () => now);
    final form = OvertimeRequestController(overtime: overtime);
    addTearDown(form.onClose);
    addTearDown(overtime.onClose);
    await overtime.fetchEntries();
    expect(form.savePreview(), isFalse);
    form.date.value = now;
    form.startTime.value = const TimeOfDay(hour: 18, minute: 0);
    form.endTime.value = const TimeOfDay(hour: 18, minute: 0);
    form.rate.value = overtime.rates.first;
    form.reasonController.text = 'Reason';
    expect(form.savePreview(), isFalse);
    expect(
      form.validationError.value,
      'Start and end times must be different.',
    );
    form.endTime.value = const TimeOfDay(hour: 19, minute: 0);
    form.reasonController.text = '   ';
    expect(form.savePreview(), isFalse);
    expect(overtime.allEntries, hasLength(4));
  });

  testWidgets('history filter and detail navigation fit a mobile screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Get.put(HomeController());
    Get.put(OvertimeController(now: () => now));
    await tester.pumpWidget(const GetMaterialApp(home: OvertimeScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(OvertimeStatusTabs), findsOneWidget);
    expect(find.text('6.5h'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(OvertimeStatusTabs),
        matching: find.text('Pending'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 request'), findsOneWidget);
    final card = find.byType(OvertimeEntryCard).first;
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(OvertimeDetailScreen), findsOneWidget);
    expect(
      find.text('Complete the monthly reporting handover.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await Get.deleteAll(force: true);
    Get.reset();
  });

  testWidgets('request form saves a local preview and returns to history', (
    tester,
  ) async {
    Get.put(HomeController());
    final overtime = Get.put(OvertimeController(now: () => now));
    await tester.pumpWidget(const GetMaterialApp(home: OvertimeScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    final form = Get.find<OvertimeRequestController>();
    form.date.value = now;
    form.startTime.value = const TimeOfDay(hour: 17, minute: 0);
    form.endTime.value = const TimeOfDay(hour: 19, minute: 30);
    await tester.pump();
    await tester.tap(find.text('Select overtime rate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekday · 1.5×'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      'Finish project handover',
    );
    final save = find.text('Save preview request');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(overtime.allEntries.first.reason, 'Finish project handover');
    expect(overtime.allEntries.first.hours, 2.5);
    expect(overtime.pendingCount, 2);
    expect(find.byType(OvertimeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await Get.deleteAll(force: true);
    Get.reset();
  });
}
