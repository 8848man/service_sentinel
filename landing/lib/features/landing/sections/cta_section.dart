import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../design/tokens.dart';
import '../../../design/animations/ss_scroll_reveal.dart';
import '../../../design/components/ss_button.dart';
import '../../../design/utils/responsive.dart';
import '../../../l10n/strings.dart';

class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleNotifier>().strings;
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.tablet;
    final vertPad = isMobile ? SSSpacing.lg : SSSpacing.xxl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: vertPad),
      color: SSColors.surface,
      child: Center(
        child: Padding(
          padding: ssSectionPadding(context),
          child: Column(
            children: [
              // Accent divider
              SSScrollReveal(
                child: Container(
                  width: 48,
                  height: 3,
                  decoration: BoxDecoration(
                    color: SSColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SSSpacing.xl),

              SSScrollReveal(
                delay: const Duration(milliseconds: 100),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(children: [
                    AnimatedSwitcher(
                      duration: SSMotion.fast,
                      child: Text(
                        strings.ctaHeadline1,
                        key: ValueKey(strings.ctaHeadline1),
                        style: SSTextStyles.headline
                            .copyWith(fontSize: 44)
                            .responsive(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: SSMotion.fast,
                      child: Text(
                        strings.ctaHeadline2,
                        key: ValueKey(strings.ctaHeadline2),
                        style: SSTextStyles.headline
                            .copyWith(fontSize: 44, color: SSColors.accent)
                            .responsive(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: SSSpacing.lg),

              SSScrollReveal(
                delay: const Duration(milliseconds: 200),
                child: AnimatedSwitcher(
                  duration: SSMotion.fast,
                  child: Text(strings.ctaSubtext,
                      key: ValueKey(strings.ctaSubtext),
                      style: SSTextStyles.body,
                      textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(height: SSSpacing.sm),

              SSScrollReveal(
                delay: const Duration(milliseconds: 250),
                child: AnimatedSwitcher(
                  duration: SSMotion.fast,
                  child: Text(
                    strings.ctaFreeTierNote,
                    key: ValueKey(strings.ctaFreeTierNote),
                    style: SSTextStyles.caption.copyWith(
                        color: SSColors.success, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: SSSpacing.xl),

              // SSScrollReveal(
              //   delay: const Duration(milliseconds: 300),
              //   child: isMobile
              //       ? SSButton(
              //           label: strings.ctaButton,
              //           onPressed: () {},
              //           variant: SSButtonVariant.primary,
              //           isFullWidth: true,
              //         )
              //       : ConstrainedBox(
              //           constraints: const BoxConstraints(maxWidth: 400),
              //           child: SSButton(
              //             label: strings.ctaButton,
              //             onPressed: () {},
              //             variant: SSButtonVariant.primary,
              //             isFullWidth: true,
              //           ),
              //         ),
              // ),
              // const SizedBox(height: SSSpacing.xxl),

              SSScrollReveal(
                delay: const Duration(milliseconds: 350),
                child: AnimatedSwitcher(
                  duration: SSMotion.fast,
                  child: Text(strings.ctaFooter,
                      key: ValueKey(strings.ctaFooter),
                      style: SSTextStyles.caption,
                      textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
