import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/features/hrms_app/controllers/schedule_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

const List<String> _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const List<String> _kWeekdayLabels = [
  'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT',
];

/// Month calendar driven by [ScheduleController]: prev/next header, weekday
/// row, 6x7 day grid. The selected day is a filled circle, today has a ring,
/// and days with a working shift get a small dot.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();

    return Obx(() {
      final month = controller.currentMonth.value;
      final start = ScheduleController.gridStart(month);
      final days = List.generate(42, (i) => start.add(Duration(days: i)));

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
            // Without this, a GridView adds the phone's status-bar / home-bar
            // insets as padding, which is what left the big gaps above and
            // below the dates.
            padding: EdgeInsets.zero,
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: days
                .map((day) => _DayCell(day: day, month: month, controller: controller))
                .toList(),
          ),
        ],
      );
    });
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final DateTime month;
  final ScheduleController controller;

  const _DayCell({required this.day, required this.month, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Each cell has its own Obx. The cells are built after the parent Obx
    // finishes, so without this the highlight would not follow taps.
    return Obx(() {
      final isCurrentMonth = day.month == month.month;
      final selected = controller.selectedDate.value;
      final isSelected = day.year == selected.year &&
          day.month == selected.month &&
          day.day == selected.day;
      final now = DateTime.now();
      final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
      final hasSchedule = controller.hasSchedule(day);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.selectDate(day),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? PColor.primary : Colors.transparent,
                  border: (isToday && !isSelected)
                      ? Border.all(color: PColor.primary, width: 1.5)
                      : null,
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
              if (hasSchedule)
                Positioned(
                  bottom: -5,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCurrentMonth ? PColor.primary : PColor.primary.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}