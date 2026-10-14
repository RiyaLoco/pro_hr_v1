import 'package:flutter/material.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class SelectionOption {
  final String value;
  final String title;
  final String? subtitle;
  final ImageProvider? avatar;

  const SelectionOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.avatar,
  });
}

class SelectionBottomSheet extends StatelessWidget {
  final String title;
  final List<SelectionOption> options;
  final String? selectedValue;

  const SelectionBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.selectedValue,
  });

  /// Shows the sheet and returns the selected option's value, or null
  /// if the user dismissed it without picking anything.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<SelectionOption> options,
    String? selectedValue,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SelectionBottomSheet(
        title: title,
        options: options,
        selectedValue: selectedValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PColor.primary,
              ),
            ),
            const SizedBox(height: 20),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _OptionTile(
                  option: option,
                  isSelected: selectedValue == option.value,
                  onTap: () => Navigator.of(context).pop(option.value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final SelectionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = option.avatar != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: hasAvatar ? 12 : 18,
            vertical: hasAvatar ? 10 : 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PColor.primary.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              if (hasAvatar) ...[
                CircleAvatar(radius: 22, backgroundImage: option.avatar),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: hasAvatar ? 15 : 16,
                        fontWeight: FontWeight.w600,
                        color: PColor.primary,
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle!,
                        style: TextStyle(fontSize: 12, color: PColor.textColor),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RadioCircle(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool isSelected;

  const _RadioCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PColor.primary, width: 1.5),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PColor.primary,
                ),
              ),
            )
          : null,
    );
  }
}