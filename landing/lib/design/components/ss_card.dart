import 'package:flutter/material.dart';
import '../tokens.dart';

class SSCard extends StatelessWidget {
  const SSCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SSSpacing.lg),
    this.hasBorder = true,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hasBorder;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? SSColors.surface,
        borderRadius: SSRadius.bLg,
        border: hasBorder
            ? Border.all(color: SSColors.border, width: 1)
            : null,
      ),
      child: child,
    );
  }
}
