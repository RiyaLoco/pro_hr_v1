import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Iconsax.people, 'label': 'Attendance'},
      {'icon': Iconsax.clock, 'label': 'Overtimes'},
      {'icon': Iconsax.calendar_1, 'label': 'Schedule'},
      {'icon': Iconsax.message_question, 'label': 'Request'},
      {'icon': Iconsax.task, 'label': 'Missions'},
      {'icon': Iconsax.document_text_1, 'label': 'Reports'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PColor.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final icon = item['icon'] as IconData?;
          final label = item['label'] as String;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, color: PColor.primary, size: 40),
                if (icon != null) const SizedBox(height: 8),
                if (label.isNotEmpty)
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: PColor.primary)),
              ],
            ),
          );
        },
      ),
    );
  }
}
