import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/models/res/schedule_models.dart';
import 'package:test_flutter/features/hrms_app/controllers/shift_request_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/schedule/widgets/shift_status_chip.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

import '../../controllers/home_controller.dart';

/// "My Requests": every shift change request with its progress.
class ShiftRequestsScreen extends StatelessWidget {
  const ShiftRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(ShiftRequestController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: controller.fetchRequests,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CustomSliverAppBar(
              title: 'Shift Requests',
              subtitle: homeController.currentDate.value,
              isShowProfile: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilterRow(controller: controller),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.isLoading.value && controller.requests.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final items = controller.filteredRequests;
                      if (items.isEmpty) return _buildEmptyState();

                      return Column(
                        children: items
                            .map(
                              (request) => Padding(
                                padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
                                child: _RequestCard(request: request, controller: controller),
                              ),
                            )
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 180),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.swap_horiz,
              size: 72,
              color: PColor.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No shift requests',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PColor.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final ShiftRequestController controller;

  const _FilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final options = <ShiftRequestStatus?>[null, ...ShiftRequestStatus.values];

    return Obx(
      () => Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            Expanded(
              child: _FilterPill(
                label: options[i]?.label ?? 'All',
                isSelected: controller.filter.value == options[i],
                onTap: () => controller.filter.value = options[i],
              ),
            ),
            if (i < options.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? PColor.primary : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? PColor.primary : PColor.primary.withOpacity(0.4),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : PColor.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ShiftRequestItem request;
  final ShiftRequestController controller;

  const _RequestCard({required this.request, required this.controller});

  String get _footer {
    final lines = <String>[];
    if (request.requestedAt != null) {
      lines.add('Requested ${formatRequestedAt(request.requestedAt!)}');
    }
    if (request.status != ShiftRequestStatus.pending && request.approvedBy != null) {
      final verb = request.status == ShiftRequestStatus.approved ? 'Approved' : 'Rejected';
      lines.add('$verb by ${request.approvedBy}');
    }
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == ShiftRequestStatus.pending;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.date == null ? 'Shift change' : formatWeekdayDate(request.date!),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PColor.primary,
                  ),
                ),
              ),
              ShiftStatusChip(status: request.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ShiftBlock(label: 'Current', name: request.oldShiftName, time: request.oldTime),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 20, color: PColor.primary),
              ),
              Expanded(
                child: _ShiftBlock(label: 'Requested', name: request.newShiftName, time: request.newTime),
              ),
            ],
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              request.reason,
              style: TextStyle(fontSize: 13, height: 1.4, color: PColor.textColor),
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 14),
          _ProgressSteps(status: request.status),
          if (_footer.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_footer, style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey[500])),
          ],
          if (isPending)
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() {
                final cancelling = controller.cancellingId.value == request.id;
                return TextButton.icon(
                  onPressed: cancelling ? null : () => controller.cancel(request),
                  icon: cancelling
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.close, size: 16, color: Colors.redAccent),
                  label: const Text(
                    'Cancel request',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _ShiftBlock extends StatelessWidget {
  final String label;
  final String name;
  final String time;

  const _ShiftBlock({required this.label, required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(
          name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        if (time.isNotEmpty)
          Text(time, style: TextStyle(fontSize: 12, color: PColor.textColor)),
      ],
    );
  }
}

enum _StepState { done, active, upcoming, failed }

/// Submitted -> In review -> Approved / Rejected.
class _ProgressSteps extends StatelessWidget {
  final ShiftRequestStatus status;

  const _ProgressSteps({required this.status});

  @override
  Widget build(BuildContext context) {
    final pending = status == ShiftRequestStatus.pending;
    final approved = status == ShiftRequestStatus.approved;

    final steps = <(String, _StepState)>[
      ('Submitted', _StepState.done),
      ('In review', pending ? _StepState.active : _StepState.done),
      (
        approved ? 'Approved' : (pending ? 'Decision' : 'Rejected'),
        pending ? _StepState.upcoming : (approved ? _StepState.done : _StepState.failed),
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepDot(label: steps[i].$1, state: steps[i].$2),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(top: 8, left: 4, right: 4),
                color: steps[i + 1].$2 == _StepState.upcoming
                    ? Colors.grey[300]
                    : PColor.primary.withOpacity(0.6),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final _StepState state;

  const _StepDot({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData? icon;

    switch (state) {
      case _StepState.done:
        color = PColor.primary;
        icon = Icons.check;
        break;
      case _StepState.active:
        color = const Color(0xFFE0A93B);
        icon = Icons.more_horiz;
        break;
      case _StepState.failed:
        color = const Color(0xFFD9534F);
        icon = Icons.close;
        break;
      case _StepState.upcoming:
        color = Colors.grey.shade400;
        icon = null;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: icon == null ? null : Icon(icon, size: 12, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: state == _StepState.upcoming ? FontWeight.normal : FontWeight.w600,
            color: state == _StepState.upcoming ? Colors.grey[500] : Colors.black87,
          ),
        ),
      ],
    );
  }
}