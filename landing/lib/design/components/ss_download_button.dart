import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../tokens.dart';
import '../animations/ss_hover_scale.dart';
import 'ss_badge.dart';
import 'ss_card.dart';
import '../../features/landing/models/download_button_model.dart';

class SSDownloadButton extends StatelessWidget {
  const SSDownloadButton({super.key, required this.model});

  final DownloadButtonModel model;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.tablet;
    final content = _CardContent(model: model, isMobile: isMobile);

    if (model.isComingSoon) {
      return Opacity(opacity: 0.5, child: content);
    }

    return SSHoverScale(
      scale: 1.02,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            final url = model.url;
            if (url != null) {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            }
          },
          child: content,
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.model, required this.isMobile});

  final DownloadButtonModel model;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final arrowOrBadge = model.isComingSoon
        ? SSBadge(label: model.sublabel, variant: SSBadgeVariant.info)
        : const Icon(Icons.arrow_forward_rounded,
            color: SSColors.accent, size: 20);

    if (isMobile) {
      return SSCard(
        padding: const EdgeInsets.symmetric(
            horizontal: SSSpacing.md, vertical: SSSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Row(
            children: [
              Icon(model.icon, color: SSColors.accent, size: 28),
              const SizedBox(width: SSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      model.label,
                      style: SSTextStyles.label.copyWith(
                          fontSize: 16, color: SSColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.sublabel,
                      style: SSTextStyles.caption
                          .copyWith(color: SSColors.textSecondary),
                    ),
                  ],
                ),
              ),
              arrowOrBadge,
            ],
          ),
        ),
      );
    }

    return SSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(model.icon, color: SSColors.accent, size: 28),
              const Spacer(),
              arrowOrBadge,
            ],
          ),
          const SizedBox(height: SSSpacing.md),
          Text(
            model.label,
            style: SSTextStyles.headline
                .copyWith(color: SSColors.textPrimary, fontSize: 20),
          ),
          const SizedBox(height: SSSpacing.xs),
          Text(
            model.sublabel,
            style:
                SSTextStyles.caption.copyWith(color: SSColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
