import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/models/res/leave_request_models.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/features/authentication/controllers/login_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/image_string.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/leave_attachment_view.dart';

import '../../controllers/home_controller.dart';



const List<String> _shortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime d) => '${d.day} ${_shortMonths[d.month - 1]} ${d.year}';

String _formatDateTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour < 12 ? 'AM' : 'PM';
  return '${_formatDate(d)} - $hour:$minute $period';
}

class LeaveScreenDetail extends StatelessWidget {
  final LeaveRequest request;

  const LeaveScreenDetail({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final user = Get.find<LoginController>().user.value?.user;

    final name = user?.name ?? 'Guest';
    final avatar = user?.avatarUrl;
    final ImageProvider avatarImage = avatar != null
        ? NetworkImage(AppUrlService.fileUrl(avatar))
        : const AssetImage(ImageString.profile1);

    final r = request;
    final sameDay = r.startDate.year == r.endDate.year &&
        r.startDate.month == r.endDate.month &&
        r.startDate.day == r.endDate.day;
    final dateRange = sameDay
        ? _formatDate(r.startDate)
        : '${_formatDate(r.startDate)} - ${_formatDate(r.endDate)}';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: 'Leave Detail',
            subtitle: homeController.currentDate.value,
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Header ----
                  Row(
                    children: [
                      CircleAvatar(radius: 30, backgroundImage: avatarImage),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leave Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: PColor.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name,
                              style: TextStyle(fontSize: 16, color: PColor.textColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[300], height: 1),
                  const SizedBox(height: 16),

                  // ---- Reason ----
                  Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20, color: PColor.primary),
                      const SizedBox(width: 10),
                      Text(
                        'Reason for Leave',
                        style: TextStyle(fontSize: 15, color: PColor.textColor),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, top: 6, bottom: 4),
                    child: Text(
                      r.reason.isEmpty ? '-' : r.reason,
                      style: TextStyle(fontSize: 15, height: 1.4, color: PColor.textColor),
                    ),
                  ),

                  // ---- Facts ----
                  _InfoRow(icon: Icons.assignment_outlined, label: 'Leave type', value: r.leaveType),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Days Requested',
                    value: _daysLabel(r.days),
                  ),
                  _InfoRow(icon: Icons.calendar_today_outlined, label: 'Date Start-End', value: dateRange),
                  if (r.requestedAt != null)
                    _InfoRow(
                      icon: Icons.schedule,
                      label: 'Booking Date',
                      value: _formatDateTime(r.requestedAt!),
                    ),

                  // ---- Approve status ----
                  const SizedBox(height: 24),
                  _SectionTitle('Approve Status'),
                  Divider(color: Colors.grey[300], height: 1),
                  const SizedBox(height: 12),
                  _StatusRow(request: r),
                  if (r.approvedBy != null)
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Approved by',
                      value: r.approvedBy!,
                    ),
                  if (r.rejectedBy != null)
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Rejected by',
                      value: r.rejectedBy!,
                    ),

                  // ---- Attachment ----
                  if (r.attachmentUrl != null) ...[
                    const SizedBox(height: 24),
                    _SectionTitle('Attachments'),
                    Divider(color: Colors.grey[300], height: 1),
                    const SizedBox(height: 12),
                    LeaveAttachmentView(url: AppUrlService.attachmentUrl(r.attachmentUrl!)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _daysLabel(double days) {
    final text = days == days.roundToDouble() ? '${days.toInt()}' : '$days';
    return '$text ${days == 1 ? 'day' : 'days'}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: PColor.primary,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: PColor.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 15, color: PColor.textColor)),
          ),
          SizedBox(
            width: 18,
            child: Text(':', style: TextStyle(fontSize: 15, color: PColor.textColor)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(fontSize: 15, color: PColor.textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final LeaveRequest request;

  const _StatusRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;

    switch (request.rawStatus) {
      case 'acknowledge':
      case 'acknowledged':
        text = 'Approved';
        color = PColor.primary;
        break;
      default:
        switch (request.status) {
          case LeaveStatus.pending:
            text = 'Pending Approve';
            color = PColor.pendingColor;
            break;
          case LeaveStatus.approved:
            text = 'Approved';
            color = PColor.primary;
            break;
          case LeaveStatus.rejected:
            text = 'Rejected';
            color = PColor.rejectedColor;
            break;
        }
    }

    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          'Status : $text',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}
