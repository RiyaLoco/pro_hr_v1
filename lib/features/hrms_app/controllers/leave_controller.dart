import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

/// Status of a leave request — also doubles as the tab selector
/// on the Leave list screen.
enum LeaveStatus { pending, rejected, approved }

extension LeaveStatusLabel on LeaveStatus {
  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.rejected:
        return 'Reject';
      case LeaveStatus.approved:
        return 'Approved';
    }
  }
}

/// Model for a single leave request.
class LeaveRequest {
  final String id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;

  const LeaveRequest({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });
}

/// Controller for the Leave list screen — holds the selected tab
/// (Pending / Reject / Approved) and the list of leave requests.
class LeaveController extends GetxController {
  final Rx<LeaveStatus> selectedTab = LeaveStatus.pending.obs;
  final RxList<LeaveRequest> allRequests = <LeaveRequest>[].obs;
  final RxBool isLoading = false.obs;

  /// Requests filtered to whichever tab is currently selected.
  List<LeaveRequest> get filteredRequests => allRequests
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

  /// Loads the user's leave requests. Replace the body with a real
  /// API / repository call when ready.
  Future<void> fetchLeaveRequests() async {
    isLoading.value = true;
    try {
      // TODO: replace with real data source (API, local DB, etc.)
      allRequests.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Adds a newly-submitted leave request to the top of the pending list.
  void addRequest(LeaveRequest request) {
    allRequests.insert(0, request);
  }
}