import 'package:flutter/material.dart';
import '../tokens.dart';
import '../animations/ss_hover_scale.dart';
import 'ss_badge.dart';
import 'ss_card.dart';
import '../../features/landing/models/target_card_model.dart';

class SSTargetCard extends StatelessWidget {
  const SSTargetCard({super.key, required this.model});

  final TargetCardModel model;

  @override
  Widget build(BuildContext context) {
    return SSHoverScale(
      child: SSCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role badge
            Row(
              children: [
                Icon(model.icon, color: SSColors.accent, size: 18),
                const SizedBox(width: SSSpacing.sm),
                SSBadge(label: model.role, variant: SSBadgeVariant.info),
              ],
            ),
            const SizedBox(height: SSSpacing.md),

            // Pain line
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '→ ',
                  style: SSTextStyles.body.copyWith(color: SSColors.accent),
                ),
                Expanded(
                  child: Text(
                    model.pain,
                    style: SSTextStyles.body
                        .copyWith(color: SSColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SSSpacing.md),

            // Solution line with left accent border
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: SSColors.accent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: SSSpacing.sm),
                  Expanded(
                    child: Text(
                      model.solution,
                      style: SSTextStyles.body
                          .copyWith(color: SSColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
