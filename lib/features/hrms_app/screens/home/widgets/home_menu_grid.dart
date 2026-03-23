import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:test_flutter/common/widgets/menu_items.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Iconsax.people, 'label': 'Attendance', 'route': '/attendance'},
      {'icon': Iconsax.clock, 'label': 'Overtimes', 'route': '/overtimes'},
      {'icon': Iconsax.calendar_1, 'label': 'Schedule', 'route': '/schedule'},
      {
        'icon': Iconsax.message_question,
        'label': 'Request',
        'route': '/request',
      },
      {'icon': Iconsax.task, 'label': 'Missions', 'route': '/missions'},
      {
        'icon': Iconsax.document_text_1,
        'label': 'Reports',
        'route': '/reports',
      },
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
          return MenuItems(
            icon: item['icon'] as IconData,
            label: item['label'] as String,
            route: item['route'] as String,
          );
        },
      ),
    );
  }
}
