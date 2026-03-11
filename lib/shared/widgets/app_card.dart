import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.gradient,
    this.borderColor,
    this.borderRadius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? const Color(0xFFFFFEFB)) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? const Color(0xFFE1E9E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0E1A12),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x08FFFFFF),
            blurRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
