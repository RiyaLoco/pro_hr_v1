import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/models/res/payroll_model.dart';
import 'package:test_flutter/features/hrms_app/controllers/payroll_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

import '../../controllers/home_controller.dart';

const Color _deductionColor = Color(0xFFD9822B);

class PayslipDetailScreen extends StatelessWidget {
  final Payslip payslip;

  const PayslipDetailScreen({super.key, required this.payslip});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.find<PayRollController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: '${payslip.month} Payslips',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(controller),
                  const SizedBox(height: 20),
                  _buildEarningsCard(),
                  const SizedBox(height: 20),
                  _buildDeductionsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Header: net take-home pay ----
  Widget _buildHeaderCard(PayRollController controller) {
    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payslip.month,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: PColor.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: PColor.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  payslip.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: PColor.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Net Take-Home Pay',
            style: TextStyle(fontSize: 14, color: PColor.textColor),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '៛${payslip.netTakeHome.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: PColor.primary,
                ),
              ),
              Material(
                color: PColor.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => controller.downloadPayslip(payslip),
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            payslip.paidOnLabel,
            style: TextStyle(fontSize: 13, color: PColor.textColor),
          ),
        ],
      ),
    );
  }

  // ---- Earnings breakdown ----
  Widget _buildEarningsCard() {
    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart, size: 18, color: PColor.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Earnings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PColor.primary,
                    ),
                  ),
                ],
              ),
              Text(
                'Gross Pay',
                style: TextStyle(fontSize: 13, color: PColor.textColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: PColor.primary.withOpacity(0.3), height: 1),
          const SizedBox(height: 10),
          ...payslip.earnings.map(
            (item) => _LineItemRow(item: item, color: PColor.primary),
          ),
          const SizedBox(height: 4),
          Divider(color: PColor.primary.withOpacity(0.3), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Gross Earnings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: PColor.primary,
                ),
              ),
              Text(
                '៛${payslip.totalGross.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: PColor.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Deductions breakdown ----
  Widget _buildDeductionsCard() {
    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.remove_circle_outline,
                    size: 18,
                    color: _deductionColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Deductions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _deductionColor,
                    ),
                  ),
                ],
              ),
              Text(
                'Statutory & Plans',
                style: TextStyle(fontSize: 13, color: PColor.textColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0x40D9822B), height: 1),
          const SizedBox(height: 10),
          if (payslip.deductions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No deductions this period.',
                style: TextStyle(color: PColor.textColor),
              ),
            )
          else
            // ...payslip.deductions.map(
            //   (item) => _LineItemRow(item: item, color: _deductionColor, isDeduction: true),
            // ),
            ...payslip.deductions.map(
              (item) => _LineItemRow(
                item: item,
                color: _deductionColor,
                isDeduction: !item.label.toLowerCase().contains('advance'),
              ),
            ),
          const SizedBox(height: 4),
          const Divider(color: Color(0x40D9822B), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Deductions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _deductionColor,
                ),
              ),
              Text(
                '៛${payslip.totalDeductions.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _deductionColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  final PayslipLineItem item;
  final Color color;
  final bool isDeduction;

  const _LineItemRow({
    required this.item,
    required this.color,
    this.isDeduction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: TextStyle(fontSize: 14, color: PColor.textColor),
          ),
          Text(
            '${isDeduction ? '-' : ''}៛${item.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
