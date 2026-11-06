import 'package:flutter/material.dart';
import 'package:test_flutter/data/models/res/attendance_summary_models.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({super.key, required this.progress});

  final WeeklyAttendanceProgress progress;

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Weekly Progress',
              style: TextStyle(
                color: PColor.primary,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: Sizes.defaultSpace),
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress.progress,
                    strokeWidth: 14,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(PColor.primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      progress.hoursLabel,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: PColor.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'HOURS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PColor.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Sizes.defaultSpace),
          Text(
            progress.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: PColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}
