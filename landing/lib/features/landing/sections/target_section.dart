import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../design/tokens.dart';
import '../../../design/animations/ss_fade_in.dart';
import '../../../design/animations/ss_scroll_reveal.dart';
import '../../../design/components/ss_button.dart';
import '../../../design/components/ss_target_card.dart';
import '../../../design/utils/responsive.dart';
import '../../../l10n/strings.dart';
import '../models/target_card_model.dart';

class TargetSection extends StatelessWidget {
  const TargetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings  = context.watch<LocaleNotifier>().strings;
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.tablet;

    final cards = [
      TargetCardModel(
        role: strings.target1Role,
        pain: strings.target1Pain,
        solution: strings.target1Solution,
        icon: Icons.rocket_launch_rounded,
      ),
      TargetCardModel(
        role: strings.target2Role,
        pain: strings.target2Pain,
        solution: strings.target2Solution,
        icon: Icons.work_outline_rounded,
      ),
      TargetCardModel(
        role: strings.target3Role,
        pain: strings.target3Pain,
        solution: strings.target3Solution,
        icon: Icons.auto_awesome_rounded,
      ),
      TargetCardModel(
        role: strings.target4Role,
        pain: strings.target4Pain,
        solution: strings.target4Solution,
        icon: Icons.people_outline_rounded,
      ),
    ];

    final cardGap = isMobile ? SSSpacing.md : SSSpacing.lg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: SSSpacing.xxl),
      color: const Color(0xFF0F2030),
      child: Center(
        child: Padding(
          padding: ssSectionPadding(context),
          child: Column(
            children: [
              // Title
              SSFadeIn(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedSwitcher(
                    duration: SSMotion.fast,
                    child: Text(
                      strings.targetSectionTitle,
                      key: ValueKey(strings.targetSectionTitle),
                      style: SSTextStyles.headline.responsive(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SSSpacing.md),

              // Subtitle
              SSFadeIn(
                delay: const Duration(milliseconds: 100),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: AnimatedSwitcher(
                    duration: SSMotion.fast,
                    child: Text(
                      strings.targetSectionSubtitle,
                      key: ValueKey(strings.targetSectionSubtitle),
                      style: SSTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SSSpacing.xxl),

              // Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final useGrid =
                      constraints.maxWidth >= SSBreakpoint.tablet;
                  if (useGrid) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SSScrollReveal(
                                child: SSTargetCard(model: cards[0]),
                              ),
                            ),
                            SizedBox(width: cardGap),
                            Expanded(
                              child: SSScrollReveal(
                                delay: ssStagger(context, 1),
                                child: SSTargetCard(model: cards[1]),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: cardGap),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SSScrollReveal(
                                delay: ssStagger(context, 2),
                                child: SSTargetCard(model: cards[2]),
                              ),
                            ),
                            SizedBox(width: cardGap),
                            Expanded(
                              child: SSScrollReveal(
                                delay: ssStagger(context, 3),
                                child: SSTargetCard(model: cards[3]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  // Single column
                  return Column(
                    children: [
                      for (int i = 0; i < cards.length; i++) ...[
                        if (i > 0) SizedBox(height: cardGap),
                        SSScrollReveal(
                          delay: ssStagger(context, i),
                          child: SSTargetCard(model: cards[i]),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: SSSpacing.xxl),

              // CTA nudge
              SSScrollReveal(
                delay: ssStagger(context, 4),
                child: SSButton(
                  label: strings.targetCtaNudge,
                  onPressed: () {},
                  variant: SSButtonVariant.ghost,
                  isFullWidth: isMobile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
