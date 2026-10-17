import 'package:flutter/material.dart';
import 'package:test_flutter/data/models/res/leave_request_models.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class LeaveRequestTile extends StatelessWidget {
  final LeaveRequest request;
  Color _statusColor(LeaveStatus status) {
  switch (status) {
    case LeaveStatus.pending:
      return const Color(0xFFE0A93B); // yellow
    case LeaveStatus.rejected:
      return const Color(0xFFD9534F); // red
    case LeaveStatus.approved:
      return PColor.primary;
  }
}
  const LeaveRequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.leaveType,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: PColor.primary,
                  ),
                ),
                Text(
                  request.reason,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: PColor.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                  style: TextStyle(fontSize: 13, color: PColor.textColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(request.status),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              request.status.label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
    String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}