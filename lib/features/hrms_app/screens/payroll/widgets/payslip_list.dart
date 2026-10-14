import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/features/hrms_app/controllers/payroll_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/payroll/payroll_screen_detail.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';


class PayslipList extends StatelessWidget {
  const PayslipList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayRollController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.payslips.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text('No payslips available yet.', style: TextStyle(color: PColor.textColor)),
          ),
        );
      }

      return Column(
        children: controller.payslips
            .map(
              (payslip) => Padding(
                padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
                child: _PayslipTile(
                  payslip: payslip,
                  onTap: () => Get.to(() => PayslipDetailScreen(payslip: payslip)),
                ),
              ),
            )
            .toList(),
      );
    });
  }
}

class _PayslipTile extends StatelessWidget {
  final Payslip payslip;
  final VoidCallback onTap;

  const _PayslipTile({required this.payslip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payslip.month,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PColor.primary),
                  ),
                  _StatusPill(label: payslip.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(payslip.processedLabel, style: TextStyle(fontSize: 13, color: PColor.textColor)),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'NET: ',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: '\$${payslip.listNet.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PColor.primary),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Gross: ',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                        ),
                        if (payslip.listGross != null)
                          TextSpan(
                            text: '\$${payslip.listGross!.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PColor.primary),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: PColor.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PColor.primary),
      ),
    );
  }
}