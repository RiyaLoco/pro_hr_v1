import 'package:flutter/material.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  /// Text of the action. Defaults to "View All" unless only [actionIcon] is set.
  final String? actionLabel;

  /// Optional icon shown after the label (or alone when [actionLabel] is null).
  final IconData? actionIcon;

  /// Called when the action is tapped. If null, the action isn't tappable.
  final VoidCallback? onActionTap;

  /// Fully custom widget on the right. Overrides all the action options.
  final Widget? trailing;

  final bool showAction;

  /// Color of the action text/icon. Defaults to [PColor.textColor].
  final Color? actionColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onActionTap,
    this.trailing,
    this.showAction = true,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: PColor.primary,
            ),
          ),
        ),
        if (trailing != null)
          trailing!
        else if (showAction)
          _buildAction(),
      ],
    );
  }

  Widget _buildAction() {
    final color = actionColor ?? PColor.textColor;
    final colorIcon = actionColor ?? PColor.primary;
    // Keep the old behaviour: no label and no icon -> "View All".
    final label = actionLabel ?? (actionIcon == null ? 'View All' : null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onActionTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null)
                Text(label, style: TextStyle(fontSize: 14, color: color)),
              if (label != null && actionIcon != null) const SizedBox(width: 4),
              if (actionIcon != null) Icon(actionIcon, size: 20, color: colorIcon),
            ],
          ),
        ),
      ),
    );
  }
}