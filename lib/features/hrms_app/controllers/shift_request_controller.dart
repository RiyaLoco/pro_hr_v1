import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/schedule_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';

/// The employee's shift change requests: list, filter, cancel.
class ShiftRequestController extends GetxController {
  final RxList<ShiftRequestItem> requests = <ShiftRequestItem>[].obs;
  final RxBool isLoading = false.obs;

  /// Null = show all.
  final Rxn<ShiftRequestStatus> filter = Rxn<ShiftRequestStatus>();

  /// Id of the request being cancelled right now (for the button spinner).
  final RxnInt cancellingId = RxnInt();

  final ApiController _api = ApiController();

  List<ShiftRequestItem> get filteredRequests => filter.value == null
      ? requests.toList()
      : requests.where((r) => r.status == filter.value).toList();

  /// Newest request for a working day, or null. The API returns newest first.
  ShiftRequestItem? requestFor(int scheduleDetailId) =>
      requests.where((r) => r.scheduleDetailId == scheduleDetailId).firstOrNull;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    try {
      requests.assignAll(await _api.fetchShiftRequests());
    } on ApiException catch (e) {
      Get.snackbar('Shift requests', e.displayMessage);
    } catch (_) {
      Get.snackbar('Shift requests', 'Could not load your requests. Check your connection.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancel(ShiftRequestItem request) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel request?'),
        content: const Text('This will withdraw your shift change request.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    cancellingId.value = request.id;
    try {
      await _api.cancelShiftRequest(request.id);
      requests.removeWhere((r) => r.id == request.id);
      Get.snackbar('Cancelled', 'Your shift request was cancelled.');
    } on ApiException catch (e) {
      Get.snackbar('Could not cancel', e.displayMessage);
    } catch (_) {
      Get.snackbar('Could not cancel', 'Check your connection and try again.');
    } finally {
      cancellingId.value = null;
    }
  }
}