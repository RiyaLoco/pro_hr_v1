import 'package:flutter/material.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class RecruitmentSection extends StatelessWidget {
  const RecruitmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recruitment',
                style: TextStyle(
                    color: PColor.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('View All',
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => Container(
              width: 140,
              decoration: BoxDecoration(
                color: PColor.primary,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}