import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../design/tokens.dart';
import '../../../design/animations/ss_fade_in.dart';
import '../../../design/components/ss_button.dart';
import '../../../design/utils/responsive.dart';
import '../../../l10n/strings.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, this.onStartFree});

  final VoidCallback? onStartFree;

  @override
  Widget build(BuildContext context) {
    final strings  = context.watch<LocaleNotifier>().strings;
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.tablet;

    final vertPad = isMobile ? SSSpacing.lg : SSSpacing.xxl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 160,
        bottom: vertPad,
        left: ssSectionPadding(context).horizontal / 2,
        right: ssSectionPadding(context).horizontal / 2,
      ),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFF112236), Color(0xFF0D1B2A)],
        ),
      ),
      child: Center(
        child: Column(
          children: [
            // Eyebrow badge
            SSFadeIn(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: SSSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: SSColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: SSColors.accent.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: SSColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: SSSpacing.sm),
                    Text(
                      'API Monitoring Platform',
                      style: SSTextStyles.caption.copyWith(
                          color: SSColors.accent,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SSSpacing.lg),

            // Headline 1
            SSFadeIn(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedSwitcher(
                  duration: SSMotion.fast,
                  child: Text(
                    strings.heroHeadline1,
                    key: ValueKey(strings.heroHeadline1),
                    style: SSTextStyles.display.responsive(context).copyWith(
                        color: SSColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Headline 2
            SSFadeIn(
              delay: const Duration(milliseconds: 100),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedSwitcher(
                  duration: SSMotion.fast,
                  child: Text(
                    strings.heroHeadline2,
                    key: ValueKey(strings.heroHeadline2),
                    style: SSTextStyles.display.responsive(context).copyWith(
                        color: SSColors.accent),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SSSpacing.lg),

            // Subheadline
            SSFadeIn(
              delay: const Duration(milliseconds: 200),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: AnimatedSwitcher(
                  duration: SSMotion.fast,
                  child: Text(
                    strings.heroSubheadline,
                    key: ValueKey(strings.heroSubheadline),
                    style: SSTextStyles.body.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SSSpacing.sm),

            // Free tier note
            SSFadeIn(
              delay: const Duration(milliseconds: 300),
              child: AnimatedSwitcher(
                duration: SSMotion.fast,
                child: Text(
                  strings.heroFreeTierNote,
                  key: ValueKey(strings.heroFreeTierNote),
                  style: SSTextStyles.caption.copyWith(
                      color: SSColors.success, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: SSSpacing.xl),

            // CTA buttons
            SSFadeIn(
              delay: const Duration(milliseconds: 400),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SSButton(
                          label: strings.heroCtaPrimary,
                          onPressed: onStartFree ?? () {},
                          variant: SSButtonVariant.primary,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: SSSpacing.md),
                        SSButton(
                          label: strings.heroCtaSecondary,
                          onPressed: () {},
                          variant: SSButtonVariant.outline,
                          isFullWidth: true,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SSButton(
                          label: strings.heroCtaPrimary,
                          onPressed: onStartFree ?? () {},
                          variant: SSButtonVariant.primary,
                        ),
                        const SizedBox(width: SSSpacing.md),
                        SSButton(
                          label: strings.heroCtaSecondary,
                          onPressed: () {},
                          variant: SSButtonVariant.outline,
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
