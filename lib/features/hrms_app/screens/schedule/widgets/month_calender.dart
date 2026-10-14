import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/features/hrms_app/controllers/schedule_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

const List<String> _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const List<String> _kWeekdayLabels = [
  'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT',
];

/// A month-grid calendar (prev/next header, weekday row, 6x7 day
/// grid) driven by [ScheduleController]. Selecting a day updates
/// `controller.selectedDate`; the selected day is highlighted with
/// a filled circle.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();

    return Obx(() {
      final month = controller.currentMonth.value;
      final days = _buildGridDays(month);

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: controller.previousMonth,
                icon: const Icon(Icons.chevron_left, color: Colors.black54),
              ),
              Text(
                '${_kMonthNames[month.month - 1]} ${month.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: controller.nextMonth,
                icon: const Icon(Icons.chevron_right, color: Colors.black54),
              ),
            ],
          ),
          Row(
            children: _kWeekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: days
                .map((day) => _DayCell(day: day, controller: controller))
                .toList(),
          ),
        ],
      );
    });
  }

  List<DateTime> _buildGridDays(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // DateTime.weekday: Mon=1 ... Sun=7. We want the grid to start on
    // the Sunday on/before the 1st, so Sunday itself needs 0 leading days.
    final leadingDays = firstOfMonth.weekday % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: leadingDays));
    return List.generate(42, (i) => gridStart.add(Duration(days: i)));
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final ScheduleController controller;

  const _DayCell({required this.day, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = day.month == controller.currentMonth.value.month;
    final isSelected = _isSameDate(day, controller.selectedDate.value);

    return GestureDetector(
      onTap: () => controller.selectDate(day),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? PColor.primary : Colors.transparent,
          ),
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : (isCurrentMonth ? Colors.black87 : Colors.grey[350]),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}