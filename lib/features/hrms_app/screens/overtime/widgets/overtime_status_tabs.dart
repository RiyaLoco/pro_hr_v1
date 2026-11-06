import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/overtime_models.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class OvertimeStatusTabs extends StatelessWidget {
  const OvertimeStatusTabs({super.key});

  static const _statuses = <OvertimeStatus?>[
    null,
    OvertimeStatus.pending,
    OvertimeStatus.approved,
    OvertimeStatus.reject,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OvertimeController>();
    return Obx(
      () => Row(
        children: [
          for (var index = 0; index < _statuses.length; index++) ...[
            Expanded(
              child: _StatusTab(
                label: _statuses[index]?.label ?? 'All',
                selected: controller.selectedStatus.value == _statuses[index],
                onTap: () => controller.selectedStatus.value = _statuses[index],
              ),
            ),
            if (index < _statuses.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? PColor.primary : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? PColor.primary
                  : PColor.primary.withValues(alpha: 0.4),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: PColor.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : PColor.primary,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
