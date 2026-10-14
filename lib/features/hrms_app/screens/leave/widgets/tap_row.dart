import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/features/hrms_app/controllers/leave_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class TapRow extends StatelessWidget {
   TapRow({super.key});
  final controller = Get.put(LeaveController());
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          for (final status in LeaveStatus.values) ...[
            Expanded(
              child: _TabPill(
                label: status.label,
                isSelected: controller.selectedTab.value == status,
                onTap: () => controller.changeTab(status),
              ),
            ),
            if (status != LeaveStatus.values.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
  
}
class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
 
  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? PColor.primary : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? PColor.primary : PColor.primary.withOpacity(0.4),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: PColor.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : PColor.primary,
            ),
          ),
        ),
      ),
    );
  }
}