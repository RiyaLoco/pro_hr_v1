import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/features/hrms_app/controllers/overtime_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OvertimeController>();
    return TextField(
      controller: controller.searchController,
      onChanged: controller.updateSearch,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: PColor.primary),
        hintText: 'Search date, reason, or rate',
        hintStyle: const TextStyle(fontSize: 14,color: PColor.textColor),
      ),
    );
  }
}
