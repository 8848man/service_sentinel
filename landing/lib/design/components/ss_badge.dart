import 'package:flutter/material.dart';
import '../tokens.dart';

enum SSBadgeVariant { danger, success, warning, info, neutral }

class SSBadge extends StatelessWidget {
  const SSBadge({
    super.key,
    required this.label,
    this.variant = SSBadgeVariant.neutral,
  });

  final String label;
  final SSBadgeVariant variant;

  Color get _bg => switch (variant) {
    SSBadgeVariant.danger  => SSColors.danger.withOpacity(0.15),
    SSBadgeVariant.success => SSColors.success.withOpacity(0.15),
    SSBadgeVariant.warning => SSColors.warning.withOpacity(0.15),
    SSBadgeVariant.info    => SSColors.accent.withOpacity(0.15),
    SSBadgeVariant.neutral => SSColors.textMuted.withOpacity(0.15),
  };

  Color get _fg => switch (variant) {
    SSBadgeVariant.danger  => SSColors.danger,
    SSBadgeVariant.success => SSColors.success,
    SSBadgeVariant.warning => SSColors.warning,
    SSBadgeVariant.info    => SSColors.accent,
    SSBadgeVariant.neutral => SSColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SSSpacing.sm + 2,
        vertical: SSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: SSRadius.bSm,
        border: Border.all(color: _fg.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: SSTextStyles.caption.copyWith(
          color: _fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
