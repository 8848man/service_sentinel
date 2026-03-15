import 'package:flutter/material.dart';
import '../tokens.dart';

class SSResponsive extends StatelessWidget {
  const SSResponsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w >= SSBreakpoint.desktop) return desktop;
        if (w >= SSBreakpoint.tablet) return tablet ?? mobile;
        return mobile;
      },
    );
  }
}

EdgeInsets ssSectionPadding(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= SSBreakpoint.desktop) {
    return const EdgeInsets.symmetric(horizontal: SSSpacing.xxl);
  }
  if (w >= SSBreakpoint.tablet) {
    return const EdgeInsets.symmetric(horizontal: SSSpacing.xl);
  }
  return const EdgeInsets.symmetric(horizontal: SSSpacing.md);
}

Duration ssStagger(BuildContext context, int index) {
  final w = MediaQuery.sizeOf(context).width;
  final ms = w < SSBreakpoint.tablet ? 50 : 100;
  return Duration(milliseconds: ms * index);
}
