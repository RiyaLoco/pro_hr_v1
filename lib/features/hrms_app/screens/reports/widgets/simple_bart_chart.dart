import 'package:flutter/material.dart';
import 'package:test_flutter/features/hrms_app/controllers/report_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

/// A lightweight bar chart built from plain Containers — no charting
/// package dependency. Bars are scaled relative to the largest value
/// in [data]; pass [maxValue] to pin the scale instead (e.g. an 8h
/// workday goal) so bars don't look "full" just because today was
/// the busiest day of a quiet week.
class SimpleBarChart extends StatelessWidget {
  final List<DailyHours> data;
  final double? maxValue;
  final double height;

  const SimpleBarChart({
    super.key,
    required this.data,
    this.maxValue,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final scale = maxValue ??
        (data.isEmpty
            ? 1
            : data.map((d) => d.hours).reduce((a, b) => a > b ? a : b).clamp(1, double.infinity));

    return SizedBox(
      height: height + 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data
            .map(
              (day) => Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      day.hours == 0 ? '' : day.hours.toStringAsFixed(day.hours % 1 == 0 ? 0 : 1),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: PColor.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 16,
                      height: scale == 0 ? 4 : (day.hours / scale) * height,
                      decoration: BoxDecoration(
                        color: day.hours == 0 ? Colors.grey[200] : PColor.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day.dayLabel,
                      style: TextStyle(fontSize: 11, color: PColor.textColor),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}