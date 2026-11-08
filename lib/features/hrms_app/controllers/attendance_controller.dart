import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/attendance_history_models.dart';
import 'package:test_flutter/data/models/res/attendance_summary_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';

class AttendanceController extends GetxController {
  AttendanceController({ApiController? api}) : _api = api ?? ApiController();

  final ApiController _api;
  final RxList<AttendanceRecord> records = <AttendanceRecord>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<AttendanceSummary> summary = Rxn<AttendanceSummary>();
  final RxnDouble leaveRemainingDays = RxnDouble();
  final RxnString leaveBalanceError = RxnString();
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxnString loadMoreError = RxnString();
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    if (isLoading.value || isLoadingMore.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    loadMoreError.value = null;
    try {
      final result = await _api.fetchAttendance();
      records.assignAll(result.records);
      summary.value = result.summary;
      _currentPage = result.currentPage;
      hasMore.value = result.hasMore;
      if (result.summary != null) {
        await _fetchLeaveRemaining();
      }
    } on ApiException catch (e) {
      errorMessage.value = e.displayMessage;
    } catch (_) {
      errorMessage.value = 'Could not load attendance. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchLeaveRemaining() async {
    leaveBalanceError.value = null;
    try {
      final balances = await _api.fetchLeaveRemaining();
      leaveRemainingDays.value = balances.fold<double>(
        0,
        (total, balance) => total + balance.daysRemaining,
      );
    } catch (_) {
      leaveRemainingDays.value = null;
      leaveBalanceError.value =
          'Could not load remaining leave. Pull down to retry.';
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    loadMoreError.value = null;
    try {
      final result = await _api.fetchAttendance(page: _currentPage + 1);
      final dates = records.map((record) => record.date).toSet();
      records.addAll(result.records.where((record) => dates.add(record.date)));
      _currentPage = result.currentPage;
      hasMore.value = result.hasMore;
    } on ApiException catch (e) {
      loadMoreError.value = e.displayMessage;
    } catch (_) {
      loadMoreError.value = 'Could not load more attendance. Please try again.';
    } finally {
      isLoadingMore.value = false;
    }
  }
}
