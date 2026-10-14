import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/features/hrms_app/controllers/payroll_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class YearToDateCard extends StatelessWidget {
  const YearToDateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayRollController>();
    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Year to date earning',
                    style: TextStyle(fontSize: 14, color: PColor.textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${controller.yearToDateEarning.value.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: PColor.primary),
                  ),
                ],
              ),
            ),
            _DownloadButton(onTap: controller.downloadYearToDateSummary),
          ],
        ),
      ),
    );
  }
  
}

class _DownloadButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DownloadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PColor.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Icon(Icons.file_download_outlined, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}