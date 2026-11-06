import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/models/res/overtime_models.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/widgets/overtime_status_chip.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class OvertimeDetailScreen extends StatelessWidget {
  OvertimeDetailScreen({super.key, required this.request});
  final OtRequest request;
  final homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[100],
    body: CustomScrollView(
      slivers: [
        CustomSliverAppBar(
          title: 'Overtime Details',
          subtitle: homeController.currentDate.value,
          isShowProfile: false,
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppContainer(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            request.hoursLabel,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: PColor.primary,
                            ),
                          ),
                            OvertimeStatusChip(status: request.status),
                        ],
                      ),
                      Text(
                        request.dateLabel,
                        style: const TextStyle(fontSize: 16,color: PColor.textColor),
                      ),
                      const Divider(height: 32),
                      _row('Time', request.timeLabel),
                      _row('Overtime rate', request.rateLabel),
                      if (request.rate?.description.isNotEmpty == true)
                        _row('Rate description', request.rate!.description),
                      _row('Review', request.reviewerLabel),
                      if (request.createdAt != null)
                        _row(
                          'Requested',
                          DateFormat(
                            'MMM d, yyyy · h:mm a',
                          ).format(request.createdAt!.toLocal()),
                        ),
                      if (request.creatorName != null)
                        _row('Created by', request.creatorName!),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppContainer(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reason',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,color: PColor.primary
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(request.reason, style: const TextStyle(height: 1.5,color: PColor.textColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: PColor.primary,fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w400,color: PColor.textColor)),
      ],
    ),
  );
}
