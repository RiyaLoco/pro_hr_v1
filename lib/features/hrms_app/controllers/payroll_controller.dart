import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/payroll_model.dart';
import 'package:test_flutter/data/services/api_controller.dart';



/// Payrolls list + year-to-date, loaded from the employee payroll API.
class PayRollController extends GetxController {
  final RxDouble yearToDateEarning = 0.0.obs;
  final RxList<Payslip> payslips = <Payslip>[].obs;
  final RxBool isLoading = false.obs;

  final ApiController _api = ApiController();

  @override
  void onInit() {
    super.onInit();
    fetchPayslips();
  }

  Future<void> fetchPayslips() async {
    isLoading.value = true;
    try {
      final all = await _api.fetchPayslips();

      // Drafts and payrolls still waiting for approval are never shown.
      final released = all.where((p) => p.isReleased).toList();
      payslips.assignAll(released);

      // Year to date = net pay of this year's released payslips.
      final year = DateTime.now().year;
      yearToDateEarning.value = released
          .where((p) => p.periodEnd?.year == year)
          .fold(0.0, (sum, p) => sum + p.netTakeHome);
    } on ApiException catch (e) {
      Get.snackbar('Payroll', e.displayMessage);
    } catch (_) {
      Get.snackbar('Payroll', 'Could not load your payslips. Check your connection.');
    } finally {
      isLoading.value = false;
    }
  }

  // The API has no PDF endpoint yet.
  Future<void> downloadYearToDateSummary() async {
    Get.snackbar('Download', 'Downloads are not available yet.');
  }

  Future<void> downloadPayslip(Payslip payslip) async {
    Get.snackbar('Download', 'Downloads are not available yet.');
  }
}