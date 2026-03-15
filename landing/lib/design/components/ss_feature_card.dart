import 'package:flutter/material.dart';
import '../tokens.dart';
import '../animations/ss_hover_scale.dart';
import 'ss_card.dart';

class SSFeatureCard extends StatelessWidget {
  const SSFeatureCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return SSHoverScale(
      child: SSCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: SSRadius.bMd,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: SSSpacing.md),
            Text(title, style: SSTextStyles.title),
            const SizedBox(height: SSSpacing.sm),
            Text(description, style: SSTextStyles.body),
            if (ctaLabel != null) ...[
              const SizedBox(height: SSSpacing.md),
              _CtaLink(label: ctaLabel!, onTap: onCta),
            ],
          ],
        ),
      ),
    );
  }
}

class _CtaLink extends StatefulWidget {
  const _CtaLink({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  State<_CtaLink> createState() => _CtaLinkState();
}

class _CtaLinkState extends State<_CtaLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _hovered ? SSColors.accent : SSColors.textSecondary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: SSMotion.fast,
              style: SSTextStyles.label.copyWith(color: color, fontSize: 14),
              child: Text(widget.label),
            ),
            const SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: SSMotion.fast,
              style: SSTextStyles.label.copyWith(color: color),
              child: const Text('→'),
            ),
          ],
        ),
      ),
    );
  }
}
