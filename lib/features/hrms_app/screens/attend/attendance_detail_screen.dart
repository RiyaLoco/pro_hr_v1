import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/models/res/attendance_history_models.dart';
import 'package:test_flutter/data/models/res/attendance_summary_models.dart';
import 'package:test_flutter/data/models/res/punch_models.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key, required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(record.date);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: 'Attendance Detail',
            subtitle: record.dateLabel,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (date != null)
                                Text(
                                  DateFormat('EEEE').format(date),
                                  style: const TextStyle(
                                    color: PColor.subTitleColor,
                                    fontSize: 14,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                record.dateLabel,
                                style: const TextStyle(
                                  color: PColor.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _StatusBadge(status: record.statusLabel),
                              const Divider(height: 32),
                              const Text(
                                'Hours worked',
                                style: TextStyle(color: PColor.subTitleColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record.workedHours == null
                                    ? 'Not available'
                                    : '${formatAttendanceNumber(record.workedHours!)}h',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: PColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionTitle('Attendance information'),
                              _InfoRow(
                                icon: Icons.login,
                                label: 'Check in',
                                value: record.checkInLabel == '—'
                                    ? 'Not recorded'
                                    : record.checkInLabel,
                              ),
                              _InfoRow(
                                icon: Icons.logout,
                                label: 'Check out',
                                value: record.checkOutLabel == '—'
                                    ? 'Not recorded'
                                    : record.checkOutLabel,
                              ),
                              _InfoRow(
                                icon: Icons.schedule,
                                label: 'Late arrival',
                                value: _minutesLabel(record.lateMinutes),
                              ),
                              _InfoRow(
                                icon: Icons.timer_outlined,
                                label: 'Early departure',
                                value: _minutesLabel(record.earlyMinutes),
                              ),
                            ],
                          ),
                        ),
                        
                        // AppContainer(
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       const _SectionTitle('Punch activity'),
                        //       if (record.events.isEmpty)
                        //         const Text(
                        //           'No punch activity available for this day.',
                        //           style: TextStyle(
                        //             color: PColor.subTitleColor,
                        //             height: 1.5,
                        //           ),
                        //         )
                        //       else
                        //         for (
                        //           var i = 0;
                        //           i < record.events.length;
                        //           i++
                        //         ) ...[
                        //           if (i > 0) const Divider(height: 24),
                        //           _PunchActivity(event: record.events[i]),
                        //         ],
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _minutesLabel(int? minutes) => minutes == null
      ? 'Not available'
      : '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: PColor.primary,
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: PColor.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: PColor.subTitleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: PColor.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// class _PunchActivity extends StatelessWidget {
//   const _PunchActivity({required this.event});

//   final PunchRecord event;

//   @override
//   Widget build(BuildContext context) {
//     final label = switch (event.direction) {
//       'in' => 'Check in',
//       'out' => 'Check out',
//       _ => 'Attendance event',
//     };
//     final branch = event.locationPolicy.branchName;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _InfoRow(
//           icon: event.direction == 'out' ? Icons.logout : Icons.login,
//           label: label,
//           value: AttendanceRecord.formatTime(event.time),
//         ),
//         _StatusBadge(
//           status: event.status.trim().isEmpty ? 'Unknown' : event.status,
//         ),
//         if (branch != null && branch.trim().isNotEmpty)
//           _InfoRow(
//             icon: Icons.location_on_outlined,
//             label: 'Branch',
//             value: branch,
//           ),
//       ],
//     );
//   }
// }

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.trim().toLowerCase()) {
      'on time' || 'success' || 'success(via approval)' => PColor.primary,
      'late' || 'pending' => PColor.pendingColor,
      'absent' || 'failed' || 'rejected' => PColor.rejectedColor,
      _ => PColor.subTitleColor,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
