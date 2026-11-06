import 'package:get/get.dart';

class PayslipLineItem {
  final String label;
  final double amount;

  const PayslipLineItem({required this.label, required this.amount});
}

class Payslip {
  final String month;
  final String status;
  final String processedLabel;
  final double listNet;
  final double? listGross;
  final String paidOnLabel;
  final double netTakeHome;
  final List<PayslipLineItem> earnings;
  final List<PayslipLineItem> deductions;

  const Payslip({
    required this.month,
    required this.status,
    required this.processedLabel,
    required this.listNet,
    this.listGross,
    required this.paidOnLabel,
    required this.netTakeHome,
    required this.earnings,
    required this.deductions,
  });

  double get totalGross => earnings.fold(0, (sum, item) => sum + item.amount);
  double get totalDeductions =>
      deductions.fold(0, (sum, item) => sum + item.amount);
}

class PayRollController extends GetxController {
  final RxDouble yearToDateEarning = 3600.00.obs;
  final RxList<Payslip> payslips = <Payslip>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPayslips();
  }

  Future<void> fetchPayslips() async {
    isLoading.value = true;
    try {
      payslips.value = [
        Payslip(
          month: 'October 2026',
          status: 'Paid',
          processedLabel: 'Processed on 10 Oct 2026',
          listNet: 300,
          listGross: 370,
          paidOnLabel: 'Paid on 1 Feb 2024',
          netTakeHome: 370,
          earnings: [
            PayslipLineItem(label: 'Basic Salary', amount: 300),
            PayslipLineItem(label: 'Overtime Pay', amount: 50),
            PayslipLineItem(label: 'Performance/Transport', amount: 30),
          ],
          deductions: [
            PayslipLineItem(label: 'Tax', amount: 00.00),
            PayslipLineItem(label: 'Insurance', amount: 10.00),
          ],
        ),
        Payslip(
          month: 'September 2026',
          status: 'Paid',
          processedLabel: 'Processed on 10 Sep 2026',
          listNet: 300.00,
          listGross: 350.00,
          paidOnLabel: 'Paid on 1 Sep 2024',
          netTakeHome: 4200.00,
          earnings: [
            PayslipLineItem(label: 'Basic Salary', amount: 3200.00),
            PayslipLineItem(label: 'Bonus', amount: 1000.00),
          ],
          deductions: [
            PayslipLineItem(label: 'Tax', amount: 600.00),
            PayslipLineItem(label: 'Insurance', amount: 400.00),
          ],
        ),
        Payslip(
          month: 'August 2026',
          status: 'Paid',
          processedLabel: 'Processed on Aug 10, 2026',
          listNet: 300,
          listGross: null,
          paidOnLabel: 'Paid on Aug 10, 2026',
          netTakeHome: 350,
          earnings: const [PayslipLineItem(label: 'Basic Salary', amount: 350)],
          deductions: const [],
        ),
        Payslip(
          month: 'July 2026',
          status: 'Paid',
          processedLabel: 'Processed on July 10, 2026',
          listNet: 300,
          listGross: null,
          paidOnLabel: 'Paid on April 10, 2026',
          netTakeHome: 350,
          earnings: const [PayslipLineItem(label: 'Basic Salary', amount: 350)],
          deductions: const [],
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadYearToDateSummary()async {
    
  }

  Future<void> downloadPayslip(Payslip payslip)async {
   
  }
}
