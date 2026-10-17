import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:test_flutter/data/models/res/leave_request_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';

/// Controller for the Leave list screen — holds the selected tab
/// (Pending / Reject / Approved) and the list of leave requests.
class LeaveController extends GetxController {
  final Rx<LeaveStatus> selectedTab = LeaveStatus.pending.obs;
  final RxList<LeaveRequest> requests = <LeaveRequest>[].obs;
  final RxBool isLoading = false.obs;
  final ApiController _api = ApiController();
  int _fetchGeneration = 0;

  /// The API returns all requests; each tab filters them locally.
  List<LeaveRequest> get filteredRequests => requests
      .where((request) => request.status == selectedTab.value)
      .toList();


  @override
  void onInit() {
    super.onInit();
    fetchLeaveRequests();
  }

  void changeTab(LeaveStatus status) {
    selectedTab.value = status;
  }

  /// Loads all statuses so tabs don't depend on an API status-filter format.
  Future<void> fetchLeaveRequests() async {
    final generation = ++_fetchGeneration;
    isLoading.value = true;
    try {
      final result = await _api.fetchLeaveRequests();
      if (generation != _fetchGeneration) return;
      requests.assignAll(result);
    } on ApiException catch (e) {
      if (generation == _fetchGeneration) {
        Get.snackbar('Error', e.displayMessage);
      }
    } catch (_) {
      if (generation == _fetchGeneration) {
        Get.snackbar(
          'Error',
          'Could not load leave requests. Check your connection.',
        );
      }
    } finally {
      if (generation == _fetchGeneration) isLoading.value = false;
    }
  }
}
