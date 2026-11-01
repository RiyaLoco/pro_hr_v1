import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class MenuItems extends StatelessWidget {
  const MenuItems({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: PColor.primary, size: 45),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
