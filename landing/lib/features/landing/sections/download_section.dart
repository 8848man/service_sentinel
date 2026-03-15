import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../design/tokens.dart';
import '../../../design/animations/ss_fade_in.dart';
import '../../../design/animations/ss_scroll_reveal.dart';
import '../../../design/components/ss_download_button.dart';
import '../../../design/utils/responsive.dart';
import '../../../l10n/strings.dart';
import '../models/download_button_model.dart';

class DownloadSection extends StatelessWidget {
  const DownloadSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings  = context.watch<LocaleNotifier>().strings;
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.tablet;

    final buttons = [
      DownloadButtonModel(
        icon: Icons.phone_iphone_rounded,
        label: strings.downloadAppStore,
        sublabel: strings.downloadAppStoreSub,
        url: 'https://apps.apple.com',
      ),
      DownloadButtonModel(
        icon: Icons.android_rounded,
        label: strings.downloadGooglePlay,
        sublabel: strings.downloadGooglePlaySub,
        url: 'https://play.google.com',
      ),
      DownloadButtonModel(
        icon: Icons.language_rounded,
        label: strings.downloadWeb,
        sublabel: strings.downloadWebSub,
        isComingSoon: true,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: SSSpacing.xxl),
      color: const Color(0xFF091520),
      child: Center(
        child: Padding(
          padding: ssSectionPadding(context),
          child: Column(
            children: [
              SSFadeIn(
                child: Column(children: [
                  AnimatedSwitcher(
                    duration: SSMotion.fast,
                    child: Text(
                      strings.downloadSectionTitle,
                      key: ValueKey(strings.downloadSectionTitle),
                      style: SSTextStyles.headline.responsive(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: SSSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: AnimatedSwitcher(
                      duration: SSMotion.fast,
                      child: Text(
                        strings.downloadSectionSubtitle,
                        key: ValueKey(strings.downloadSectionSubtitle),
                        style: SSTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: SSSpacing.xxl),

              isMobile
                  ? Column(children: [
                      SSScrollReveal(
                        delay: Duration.zero,
                        child: SSDownloadButton(model: buttons[0]),
                      ),
                      const SizedBox(height: SSSpacing.lg),
                      SSScrollReveal(
                        delay: ssStagger(context, 1),
                        child: SSDownloadButton(model: buttons[1]),
                      ),
                      const SizedBox(height: SSSpacing.lg),
                      SSScrollReveal(
                        delay: ssStagger(context, 2),
                        child: SSDownloadButton(model: buttons[2]),
                      ),
                    ])
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SSScrollReveal(
                              delay: Duration.zero,
                              child: SSDownloadButton(model: buttons[0]),
                            ),
                          ),
                          const SizedBox(width: SSSpacing.lg),
                          Expanded(
                            child: SSScrollReveal(
                              delay: const Duration(milliseconds: 100),
                              child: SSDownloadButton(model: buttons[1]),
                            ),
                          ),
                          const SizedBox(width: SSSpacing.lg),
                          Expanded(
                            child: SSScrollReveal(
                              delay: const Duration(milliseconds: 200),
                              child: SSDownloadButton(model: buttons[2]),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
