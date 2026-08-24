import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double borderRadius;
  final Color shadowColor;
  final double blurRadius;
  final Offset shadowOffset;
  final bool showShadow;
  final Border? border;
  final AlignmentGeometry? alignment;
  final VoidCallback? onTap;

  const AppContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.color = Colors.white,
    this.borderRadius = 20,
    this.shadowColor = Colors.black,
    this.blurRadius = 10,
    this.shadowOffset = const Offset(0, 4),
    this.showShadow = true,
    this.border,
    this.alignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final containerWidget = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: shadowColor.withOpacity(0.05),
                  blurRadius: blurRadius,
                  offset: shadowOffset,
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: containerWidget,
        ),
      );
    }
    return containerWidget;
  }
}
