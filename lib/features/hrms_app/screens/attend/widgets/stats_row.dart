import 'package:flutter/material.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard('120h', 'TOTAL HOURS')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('89%', 'ON TIME')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('12d', 'LEAVE')),
      ],
    );
  }
    Widget _statCard(String value, String label) {
    return AppContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      borderRadius: 10,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: PColor.primary,
            ),
          ),
          
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PColor.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}