import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../design/tokens.dart';
import '../../../design/animations/ss_scroll_reveal.dart';
import '../../../design/components/ss_card.dart';
import '../../../design/components/ss_badge.dart';
import '../../../design/components/ss_phone_mockup.dart';
import '../../../design/components/ss_browser_mockup.dart';
import '../../../design/utils/responsive.dart';
import '../../../l10n/strings.dart';

class HandySection extends StatelessWidget {
  const HandySection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings  = context.watch<LocaleNotifier>().strings;
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.tablet;

    final mobileCard = SSScrollReveal(
      delay: Duration.zero,
      child: SSCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: SSMotion.fast,
              child: Text(strings.handyMobileTitle,
                  key: ValueKey(strings.handyMobileTitle),
                  style: SSTextStyles.title),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: SSMotion.fast,
              child: Text(strings.handyMobilePlatform,
                  key: ValueKey(strings.handyMobilePlatform),
                  style: SSTextStyles.caption),
            ),
            const SizedBox(height: SSSpacing.xl),
            Center(
              child: SSPhoneMockup(
                width: isMobile ? 120 : 150,
                child: _ScreenImg('assets/screens/dashboard.png'),
              ),
            ),
            const SizedBox(height: SSSpacing.xl),
            _Bullet(
                icon: Icons.notifications_active_rounded,
                label: strings.handyMobileBullet1),
            const SizedBox(height: SSSpacing.md),
            _Bullet(
                icon: Icons.visibility_rounded,
                label: strings.handyMobileBullet2),
            const SizedBox(height: SSSpacing.md),
            _Bullet(
                icon: Icons.check_circle_rounded,
                label: strings.handyMobileBullet3),
          ],
        ),
      ),
    );

    final webCard = SSScrollReveal(
      delay: ssStagger(context, 1),
      child: SSCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              AnimatedSwitcher(
                duration: SSMotion.fast,
                child: Text(strings.handyWebTitle,
                    key: ValueKey(strings.handyWebTitle),
                    style: SSTextStyles.title),
              ),
              const SizedBox(width: SSSpacing.sm),
              SSBadge(
                  label: strings.handyWebBadge,
                  variant: SSBadgeVariant.info),
            ]),
            const SizedBox(height: SSSpacing.xl + 20),
            SizedBox(
              height: 200,
              child: SSBrowserMockup(
                child: _ScreenImg('assets/screens/dashboard.png'),
              ),
            ),
            const SizedBox(height: SSSpacing.xl),
            _Bullet(
                icon: Icons.dashboard_rounded,
                label: strings.handyWebBullet1),
            const SizedBox(height: SSSpacing.md),
            _Bullet(
                icon: Icons.group_rounded,
                label: strings.handyWebBullet2),
            const SizedBox(height: SSSpacing.md),
            _Bullet(
                icon: Icons.analytics_rounded,
                label: strings.handyWebBullet3),
          ],
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: SSSpacing.xxl),
      color: SSColors.background,
      child: Center(
        child: Padding(
          padding: ssSectionPadding(context),
          child: Column(
            children: [
              SSScrollReveal(
                child: Column(children: [
                  AnimatedSwitcher(
                    duration: SSMotion.fast,
                    child: Text(strings.handySectionTitle,
                        key: ValueKey(strings.handySectionTitle),
                        style: SSTextStyles.headline.responsive(context),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: SSSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: AnimatedSwitcher(
                      duration: SSMotion.fast,
                      child: Text(strings.handySectionSubtitle,
                          key: ValueKey(strings.handySectionSubtitle),
                          style: SSTextStyles.body,
                          textAlign: TextAlign.center),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: SSSpacing.xxl),

              isMobile
                  ? Column(children: [
                      mobileCard,
                      const SizedBox(height: SSSpacing.md),
                      webCard,
                    ])
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: mobileCard),
                          const SizedBox(width: SSSpacing.lg),
                          Expanded(child: webCard),
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

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: SSColors.accent, size: 18),
      const SizedBox(width: SSSpacing.sm),
      Expanded(
          child: AnimatedSwitcher(
        duration: SSMotion.fast,
        child: Text(label,
            key: ValueKey(label),
            style: SSTextStyles.body.copyWith(fontSize: 15)),
      )),
    ]);
  }
}

class _ScreenImg extends StatelessWidget {
  const _ScreenImg(this.path);
  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF0A1628),
        child: const Center(
          child: Icon(Icons.image_rounded,
              color: SSColors.textMuted, size: 32),
        ),
      ),
    );
  }
}
