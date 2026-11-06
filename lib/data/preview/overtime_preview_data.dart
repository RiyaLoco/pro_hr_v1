import 'package:test_flutter/data/models/res/overtime_models.dart';

/// Sample data for the UI preview. These are not company rates or API records.
const overtimePreviewRates = [
  OtRate(
    id: 1,
    name: 'Weekday',
    multiplier: 1.5,
    description: 'Sample weekday rate',
  ),
  OtRate(
    id: 2,
    name: 'Rest day',
    multiplier: 2,
    description: 'Sample rest-day rate',
  ),
  OtRate(
    id: 3,
    name: 'Public holiday',
    multiplier: 3,
    description: 'Sample holiday rate',
  ),
];

List<OtRequest> overtimePreviewRequests(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final dates = [
    today,
    today.subtract(const Duration(days: 1)),
    today.subtract(const Duration(days: 3)),
    DateTime(now.year, now.month - 1, 15),
  ];
  return [
    OtRequest(
      id: 1,
      employeeId: 1,
      date: dates[0],
      startTime: '17:00:00',
      endTime: '19:00:00',
      hours: 2,
      otRateId: 1,
      reason: 'Complete the monthly reporting handover.',
      status: OvertimeStatus.pending,
      rate: overtimePreviewRates[0],
      createdBy: 1,
      createdAt: today,
    ),
    OtRequest(
      id: 2,
      employeeId: 1,
      date: dates[1],
      startTime: '17:00:00',
      endTime: '19:30:00',
      hours: 2.5,
      otRateId: 1,
      reason: 'Support the inventory reconciliation.',
      status: OvertimeStatus.approved,
      rate: overtimePreviewRates[0],
      approvedBy: 2,
      approverName: 'Sample manager',
      createdBy: 1,
      createdAt: dates[1],
    ),
    OtRequest(
      id: 3,
      employeeId: 1,
      date: dates[2],
      startTime: '09:00:00',
      endTime: '12:00:00',
      hours: 3,
      otRateId: 2,
      reason: 'Prepare files for the team review.',
      status: OvertimeStatus.reject,
      rate: overtimePreviewRates[1],
      approvedBy: 2,
      approverName: 'Sample manager',
      createdBy: 1,
      createdAt: dates[2],
    ),
    OtRequest(
      id: 4,
      employeeId: 1,
      date: dates[3],
      startTime: '09:00:00',
      endTime: '13:00:00',
      hours: 4,
      otRateId: 2,
      reason: 'Assist with the branch stock count.',
      status: OvertimeStatus.approved,
      rate: overtimePreviewRates[1],
      approvedBy: 2,
      approverName: 'Sample manager',
      createdBy: 1,
      createdAt: dates[3],
    ),
  ];
}
