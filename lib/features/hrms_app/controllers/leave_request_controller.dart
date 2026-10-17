import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/leave_request_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/leave_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';

class LeaveRequestController extends GetxController {
  final TextEditingController reasonController = TextEditingController();

  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rxn<LeaveType> leaveType = Rxn<LeaveType>();
  final RxList<LeaveType> leaveTypes = <LeaveType>[].obs;
  final RxBool isSubmitting = false.obs;

  final ApiController _api = ApiController();

  String get startDateLabel =>
      startDate.value == null ? 'Start Date' : _formatDate(startDate.value!);

  String get endDateLabel =>
      endDate.value == null ? 'End Date' : _formatDate(endDate.value!);

  String get leaveTypeLabel => leaveType.value?.name ?? 'Select leave type';

  @override
  void onInit() {
    super.onInit();
    loadLeaveTypes();
  }

  Future<void> loadLeaveTypes() async {
    try {
      leaveTypes.assignAll(await _api.fetchLeaveTypes());
    } on ApiException catch (e) {
      Get.snackbar('Error', e.displayMessage);
    } catch (_) {
      Get.snackbar('Error', 'Could not load leave types. Check your connection.');
    }
  }

  Future<void> pickStartDate(BuildContext context) async {
    final result = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result == null) return;
    startDate.value = result;
    // End date can't be before the new start date.
    if (endDate.value != null && endDate.value!.isBefore(result)) {
      endDate.value = null;
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final first = startDate.value ?? DateTime.now().subtract(const Duration(days: 365));
    final result = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? first,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) endDate.value = result;
  }

  Future<void> pickLeaveType(BuildContext context) async {
    if (leaveTypes.isEmpty) {
      await loadLeaveTypes();
      if (leaveTypes.isEmpty) return;
    }

    final result = await SelectionBottomSheet.show(
      context,
      title: 'Select leave type',
      options: leaveTypes
          .map((t) => SelectionOption(value: '${t.id}', title: t.name))
          .toList(),
      selectedValue: leaveType.value == null ? null : '${leaveType.value!.id}',
    );
    if (result != null) {
      leaveType.value = leaveTypes.firstWhere((t) => '${t.id}' == result);
    }
  }

  Future<void> submit() async {
    if (startDate.value == null || endDate.value == null || leaveType.value == null) {
      Get.snackbar('Missing information', 'Please choose a leave type, start date and end date.');
      return;
    }

    if (endDate.value!.isBefore(startDate.value!)) {
      Get.snackbar('Invalid dates', 'End date must be on or after start date.');
      return;
    }

    isSubmitting.value = true;
    try {
      await _api.submitLeaveRequest(
        leaveTypeId: leaveType.value!.id,
        startDate: _apiDate(startDate.value!),
        endDate: _apiDate(endDate.value!),
        reason: reasonController.text,
      );

      final leaveController = Get.isRegistered<LeaveController>()
          ? Get.find<LeaveController>()
          : null;
      leaveController?.selectedTab.value = LeaveStatus.pending;
      Get.back();
      if (leaveController != null) {
        await leaveController.fetchLeaveRequests();
      }
      Get.snackbar('Submitted', 'Your leave request was sent.');
    } on ApiException catch (e) {
      // Covers validation errors and "dates overlap an existing request".
      Get.snackbar('Could not submit', e.displayMessage);
    } on DioException catch (e) {
      final response = e.response?.data;
      final message = response is Map
          ? (response['message'] ?? response['error'])?.toString()
          : null;
      Get.snackbar(
        'Could not submit',
        message ?? e.message ?? 'The server could not process the request.',
      );
    } catch (_) {
      Get.snackbar('Could not submit', 'Check your connection and try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}
