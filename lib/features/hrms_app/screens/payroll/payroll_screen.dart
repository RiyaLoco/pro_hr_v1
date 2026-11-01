import 'package:test_flutter/common/widgets/app_refresh_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/features/hrms_app/controllers/payroll_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/payroll/widgets/payslip_list.dart';
import 'package:test_flutter/features/hrms_app/screens/payroll/widgets/year_to_date_card.dart';
import 'package:test_flutter/utils/constants/colors.dart';

import '../../controllers/home_controller.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(PayRollController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AppRefreshScrollView(
        onRefresh: controller.fetchPayslips,
        slivers: [
          CustomSliverAppBar(
            title: 'Payrolls',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YearToDateCard(),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Payslips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PColor.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PayslipList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
