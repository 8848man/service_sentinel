import 'package:flutter/material.dart';
import '../tokens.dart';

class SSPhoneMockup extends StatelessWidget {
  const SSPhoneMockup({
    super.key,
    required this.child,
    this.width = 220,
  });

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 2.1;
    final radius = width * 0.12;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SSColors.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: SSColors.accent.withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            // Notch pill
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: width * 0.28,
                  height: 5,
                  decoration: BoxDecoration(
                    color: SSColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
