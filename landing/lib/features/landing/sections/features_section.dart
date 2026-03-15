import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../design/tokens.dart';
import '../../../design/animations/ss_scroll_reveal.dart';
import '../../../design/components/ss_feature_card.dart';
import '../../../design/components/ss_step_pill.dart';
import '../../../design/components/ss_card.dart';
import '../../../design/utils/responsive.dart';
import '../../../l10n/strings.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings  = context.watch<LocaleNotifier>().strings;
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.tablet;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: SSSpacing.xxl),
      color: SSColors.background,
      child: Center(
        child: Padding(
          padding: ssSectionPadding(context),
          child: Column(
            children: [
              // Header
              SSScrollReveal(
                child: Column(children: [
                  AnimatedSwitcher(
                    duration: SSMotion.fast,
                    child: Text(strings.featuresSectionTitle,
                        key: ValueKey(strings.featuresSectionTitle),
                        style: SSTextStyles.headline.responsive(context),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: SSSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: AnimatedSwitcher(
                      duration: SSMotion.fast,
                      child: Text(strings.featuresSectionSubtitle,
                          key: ValueKey(strings.featuresSectionSubtitle),
                          style: SSTextStyles.body,
                          textAlign: TextAlign.center),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: SSSpacing.xxl),

              // Feature cards
              isMobile
                  ? Column(
                      children: [
                        SSScrollReveal(
                          delay: Duration.zero,
                          child: SSFeatureCard(
                            icon: Icons.folder_open_rounded,
                            iconColor: SSColors.accent,
                            title: strings.featuresCard1Title,
                            description: strings.featuresCard1Description,
                            ctaLabel: strings.featuresCard1Cta,
                          ),
                        ),
                        const SizedBox(height: SSSpacing.md),
                        SSScrollReveal(
                          delay: ssStagger(context, 1),
                          child: SSFeatureCard(
                            icon: Icons.bolt_rounded,
                            iconColor: SSColors.danger,
                            title: strings.featuresCard2Title,
                            description: strings.featuresCard2Description,
                            ctaLabel: strings.featuresCard2Cta,
                          ),
                        ),
                        const SizedBox(height: SSSpacing.md),
                        SSScrollReveal(
                          delay: ssStagger(context, 2),
                          child: SSFeatureCard(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: SSColors.success,
                            title: strings.featuresCard3Title,
                            description: strings.featuresCard3Description,
                            ctaLabel: strings.featuresCard3Cta,
                          ),
                        ),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SSScrollReveal(
                              delay: Duration.zero,
                              child: SSFeatureCard(
                                icon: Icons.folder_open_rounded,
                                iconColor: SSColors.accent,
                                title: strings.featuresCard1Title,
                                description: strings.featuresCard1Description,
                                ctaLabel: strings.featuresCard1Cta,
                              ),
                            ),
                          ),
                          const SizedBox(width: SSSpacing.lg),
                          Expanded(
                            child: SSScrollReveal(
                              delay: const Duration(milliseconds: 100),
                              child: SSFeatureCard(
                                icon: Icons.bolt_rounded,
                                iconColor: SSColors.danger,
                                title: strings.featuresCard2Title,
                                description: strings.featuresCard2Description,
                                ctaLabel: strings.featuresCard2Cta,
                              ),
                            ),
                          ),
                          const SizedBox(width: SSSpacing.lg),
                          Expanded(
                            child: SSScrollReveal(
                              delay: const Duration(milliseconds: 200),
                              child: SSFeatureCard(
                                icon: Icons.check_circle_outline_rounded,
                                iconColor: SSColors.success,
                                title: strings.featuresCard3Title,
                                description: strings.featuresCard3Description,
                                ctaLabel: strings.featuresCard3Cta,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: SSSpacing.xxl),

              // How it works
              SSScrollReveal(
                delay: const Duration(milliseconds: 100),
                child: Column(children: [
                  Text(
                    'How it works',
                    style: SSTextStyles.title.copyWith(
                        color: SSColors.textSecondary, fontSize: 18),
                  ),
                  const SizedBox(height: SSSpacing.lg),
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SSStepPill(
                                step: 1, label: strings.featuresStep1),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: SSSpacing.sm),
                              child: Text('↓',
                                  style: TextStyle(
                                      color: SSColors.textMuted,
                                      fontSize: 18)),
                            ),
                            SSStepPill(
                                step: 2,
                                label: strings.featuresStep2,
                                isHighlighted: true),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: SSSpacing.sm),
                              child: Text('↓',
                                  style: TextStyle(
                                      color: SSColors.textMuted,
                                      fontSize: 18)),
                            ),
                            SSStepPill(
                                step: 3, label: strings.featuresStep3),
                          ],
                        )
                      : Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: SSSpacing.md,
                          runSpacing: SSSpacing.md,
                          children: [
                            SSStepPill(
                                step: 1, label: strings.featuresStep1),
                            const Text('→',
                                style: TextStyle(
                                    color: SSColors.textMuted,
                                    fontSize: 18)),
                            SSStepPill(
                                step: 2,
                                label: strings.featuresStep2,
                                isHighlighted: true),
                            const Text('→',
                                style: TextStyle(
                                    color: SSColors.textMuted,
                                    fontSize: 18)),
                            SSStepPill(
                                step: 3, label: strings.featuresStep3),
                          ],
                        ),
                ]),
              ),
              const SizedBox(height: SSSpacing.xxl),

              // Free tier highlight
              SSScrollReveal(
                delay: const Duration(milliseconds: 150),
                child: SSCard(
                  backgroundColor: SSColors.accent.withOpacity(0.06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_outline_rounded,
                          color: SSColors.accent, size: 20),
                      const SizedBox(width: SSSpacing.sm),
                      Flexible(
                        child: AnimatedSwitcher(
                          duration: SSMotion.fast,
                          child: Text(
                            strings.featuresFreeTierNote,
                            key: ValueKey(strings.featuresFreeTierNote),
                            style: SSTextStyles.body.copyWith(
                                color: SSColors.textSecondary,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
