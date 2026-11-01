import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/schedule_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/shift_request_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';

/// Form for asking to change the shift of one working day.
class ShiftRequestFormController extends GetxController {
  final WorkSchedule schedule;

  ShiftRequestFormController(this.schedule);

  final TextEditingController reasonController = TextEditingController();
  final Rxn<ShiftOption> newShift = Rxn<ShiftOption>();
  final RxList<ShiftOption> shifts = <ShiftOption>[].obs;
  final RxBool isSubmitting = false.obs;

  final ApiController _api = ApiController();

  String get newShiftLabel => newShift.value?.name ?? 'Select new shift';

  @override
  void onInit() {
    super.onInit();
    loadShifts();
  }

  Future<void> loadShifts() async {
    try {
      shifts.assignAll(await _api.fetchShiftOptions());
    } on ApiException catch (e) {
      Get.snackbar('Error', e.displayMessage);
    } catch (_) {
      Get.snackbar('Error', 'Could not load shifts. Check your connection.');
    }
  }

  Future<void> pickShift(BuildContext context) async {
    if (shifts.isEmpty) {
      await loadShifts();
      if (shifts.isEmpty) return;
    }

    // Asking for the shift you already have makes no sense.
    final options = shifts.where((s) => s.id != schedule.shiftId).toList();

    final result = await SelectionBottomSheet.show(
      context,
      title: 'Select new shift',
      options: options
          .map((s) => SelectionOption(
                value: '${s.id}',
                title: s.name,
                subtitle: s.timeLabel.isEmpty ? null : s.timeLabel,
              ))
          .toList(),
      selectedValue: newShift.value == null ? null : '${newShift.value!.id}',
    );
    if (result != null) {
      newShift.value = options.firstWhere((s) => '${s.id}' == result);
    }
  }

  Future<void> submit() async {
    if (newShift.value == null) {
      Get.snackbar('Missing information', 'Please choose the shift you want.');
      return;
    }
    if (reasonController.text.trim().isEmpty) {
      Get.snackbar('Missing information', 'Please enter a reason.');
      return;
    }

    isSubmitting.value = true;
    try {
      await _api.submitShiftRequest(
        scheduleDetailId: schedule.id,
        newShiftId: newShift.value!.id,
        reason: reasonController.text,
      );

      if (Get.isRegistered<ShiftRequestController>()) {
        await Get.find<ShiftRequestController>().fetchRequests();
      }

      Get.back();
      Get.snackbar('Submitted', 'Your shift request was sent for approval.');
    } on ApiException catch (e) {
      Get.snackbar('Could not submit', e.displayMessage);
    } catch (_) {
      Get.snackbar('Could not submit', 'Check your connection and try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}