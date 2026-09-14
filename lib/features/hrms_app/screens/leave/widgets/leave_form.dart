import 'package:flutter/material.dart';
import 'package:test_flutter/utils/constants/colors.dart';

/// Shared bordered field used across the Leave Request form —
/// matches the outlined, rounded-pill style fields in the design
/// (icon on the left, label/value in the middle, optional trailing
/// widget such as a dropdown arrow on the right).
class LeaveFormField extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool showDropdownIcon;

  const LeaveFormField({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.showDropdownIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PColor.primary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: PColor.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: PColor.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showDropdownIcon)
              Icon(Icons.keyboard_arrow_down, size: 20, color: PColor.primary),
          ],
        ),
      ),
    );
  }
}

/// Multiline bordered text field, used for the "Reason" input.
class LeaveTextAreaField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int minLines;
  final int maxLines;

  const LeaveTextAreaField({
    super.key,
    required this.controller,
    this.hint = 'Reason',
    this.icon = Icons.edit_outlined,
    this.minLines = 3,
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PColor.primary.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(icon, size: 18, color: PColor.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: minLines,
              maxLines: maxLines,
              style: TextStyle(fontSize: 14, color: PColor.primary),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  color: PColor.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bordered "Upload Image" action row.
class LeaveUploadField extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const LeaveUploadField({
    super.key,
    this.label = 'Upload Image',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PColor.primary.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_outlined, size: 18, color: PColor.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: PColor.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}