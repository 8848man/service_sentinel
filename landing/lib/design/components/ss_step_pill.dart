import 'package:flutter/material.dart';
import '../tokens.dart';

class SSStepPill extends StatelessWidget {
  const SSStepPill({
    super.key,
    required this.step,
    required this.label,
    this.isHighlighted = false,
  });

  final int step;
  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SSSpacing.lg, vertical: SSSpacing.sm + 2),
      decoration: BoxDecoration(
        color: isHighlighted
            ? SSColors.accent.withOpacity(0.15)
            : SSColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isHighlighted ? SSColors.accent : SSColors.border,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isHighlighted ? SSColors.accent : SSColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: SSTextStyles.caption.copyWith(
                color: isHighlighted ? Colors.white : SSColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: SSSpacing.sm),
          Text(
            label,
            style: SSTextStyles.label.copyWith(
              color: isHighlighted
                  ? SSColors.textPrimary
                  : SSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
