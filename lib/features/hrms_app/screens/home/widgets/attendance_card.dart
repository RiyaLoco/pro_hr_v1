// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:test_flutter/common/widgets/app_container.dart';
// import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
// import 'package:test_flutter/features/hrms_app/screens/home/attendance_check.dart';
// import 'package:test_flutter/utils/constants/colors.dart';

// class AttendanceCard extends StatelessWidget {
//   const AttendanceCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<HomeController>();
//     return AppContainer(
//       onTap: () => Get.to(() => const AttendanceCheck()),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Text(
//               'Attendance Check',
//               style: TextStyle(
//                 color: PColor.primary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(
//                 child: Obx(
//                   () => Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         controller.currentTime.value,
//                         style: TextStyle(
//                           color: PColor.primary,
//                           fontSize: 36,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         controller.currentDate.value,
//                         style: TextStyle(color: Colors.grey[500], fontSize: 13),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           _TimeInfo(
//                             time: controller.checkInTime.value.isEmpty
//                                 ? '--:--'
//                                 : controller.checkInTime.value,
//                             label: 'Check in',
//                           ),
//                           _TimeInfo(
//                             time: controller.checkOutTime.value.isEmpty
//                                 ? '--:--'
//                                 : controller.checkOutTime.value,
//                             label: 'Check out',
//                           ),
//                           _TimeInfo(
//                             time: controller.timeWorking.value.isEmpty
//                                 ? '--:--'
//                                 : controller.timeWorking.value,
//                             label: 'Times Working',
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Obx(
//                 () => GestureDetector(
//                   onTap: controller.onPunchTap,
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     width: 90,
//                     height: 90,
//                     decoration: BoxDecoration(
//                       color: controller.isPunchedIn.value
//                           ? Colors.redAccent.withOpacity(0.7)
//                           : PColor.primary.withOpacity(0.6),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: controller.isPunchedIn.value
//                               ? Colors.redAccent.withOpacity(0.3)
//                               : PColor.primary.withOpacity(0.3),
//                           blurRadius: 16,
//                           spreadRadius: 4,
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Text(
//                         controller.isPunchedIn.value ? 'Punch Out' : 'Punch In',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TimeInfo extends StatelessWidget {
//   final String time;
//   final String label;
//   const _TimeInfo({required this.time, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(Icons.access_time, size: 16, color: PColor.primary),
//         const SizedBox(width: 4),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               time,
//               style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,color: PColor.textColor),
//             ),
//             Text(
//               label,
//               style: TextStyle(fontSize: 10, color: Colors.grey[500]),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/punch_countroller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final punch = Get.put(PunchController());

    return AppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Attendance Check',
              style: TextStyle(
                color: PColor.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final clock = Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      home.currentTime.value,
                      style: const TextStyle(
                        color: PColor.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      home.currentDate.value,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              );
              final button = _PunchButton(controller: punch);
              final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;

              if (constraints.maxWidth < 280 * textScale) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    clock,
                    const SizedBox(height: 16),
                    Center(child: button),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: clock),
                  const SizedBox(width: 16),
                  button,
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Obx(
            () => Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _TimeInfo(
                  time: punch.checkInTime.value.isEmpty
                      ? '--:--'
                      : punch.checkInTime.value,
                  label: 'Check in',
                ),
                _TimeInfo(
                  time: punch.checkOutTime.value.isEmpty
                      ? '--:--'
                      : punch.checkOutTime.value,
                  label: 'Check out',
                ),
                _TimeInfo(
                  time: punch.timeWorking.value.isEmpty
                      ? '--:--'
                      : punch.timeWorking.value,
                  label: 'Times Working',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PunchButton extends StatelessWidget {
  final PunchController controller;

  const _PunchButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
    final diameter = 84.0 * (textScale < 1 ? 1 : textScale);

    return Obx(() {
      final busy = controller.isPunching.value || controller.isLoading.value;
      final done = controller.isCheckedOut.value;
      final checkedIn = controller.isCheckedIn.value;

      final Color base = (checkedIn && !done)
          ? Colors.redAccent
          : PColor.primary;
      final double strength = done ? 0.35 : (checkedIn ? 0.7 : 0.6);

      return GestureDetector(
        onTap: busy ? null : controller.onButtonTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: base.withValues(alpha: strength),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(child: _buildLabel(busy, done, checkedIn)),
        ),
      );
    });
  }

  Widget _buildLabel(bool busy, bool done, bool checkedIn) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    if (busy) {
      return const SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      );
    }

    if (done) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 26),
          SizedBox(height: 2),
          Text('Done', style: textStyle),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.qr_code_scanner, color: Colors.white, size: 26),
        SizedBox(height: 2),
        Text(checkedIn ? 'Scan Out' : 'Scan In', style: textStyle),
      ],
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final String time;
  final String label;
  const _TimeInfo({required this.time, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.access_time, size: 14, color: PColor.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PColor.textColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
