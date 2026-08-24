import 'package:flutter/material.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: PColor.primary,
          ),
        ),
        const Text(
          'View All',
          style: TextStyle(fontSize: 14, color: PColor.textColor),
        ),
      ],
    );
  }
}
