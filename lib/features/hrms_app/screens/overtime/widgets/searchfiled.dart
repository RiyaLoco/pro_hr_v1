import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';


class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OvertimeController());
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PColor.primary.withOpacity(0.4)),
      ),
      child: TextField(
        onChanged: controller.updateSearch,
        style: TextStyle(fontSize: 14, color: PColor.primary),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: PColor.primary, size: 20),
          hintText: 'Search by date or Manager...',
          hintStyle: TextStyle(color: PColor.primary.withOpacity(0.7)),
        ),
      ),
    );
  }
}