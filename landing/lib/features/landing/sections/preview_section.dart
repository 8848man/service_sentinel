import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../design/tokens.dart';
import '../../../design/animations/ss_scroll_reveal.dart';
import '../../../design/components/ss_phone_mockup.dart';
import '../../../design/utils/responsive.dart';
import '../../../l10n/strings.dart';

class PreviewSection extends StatefulWidget {
  const PreviewSection({super.key});

  @override
  State<PreviewSection> createState() => _PreviewSectionState();
}

class _PreviewSectionState extends State<PreviewSection> {
  late final PageController _pageController;
  int _currentPage = 1;
  bool _showSwipeCaption = true;

  static const _screens = [
    (assetPath: 'assets/screens/project_list.jpg', widthScale: 0.88),
    (assetPath: 'assets/screens/dashboard.jpg', widthScale: 1.0),
    (assetPath: 'assets/screens/incident.jpg', widthScale: 0.88),
  ];

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: _currentPage, viewportFraction: 0.85);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSwipeHint());
  }

  Future<void> _runSwipeHint() async {
    if (!mounted || !_pageController.hasClients) return;
    await _pageController.animateTo(
      _pageController.offset + 20,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (!mounted) return;
    await _pageController.animateTo(
      _pageController.offset - 20,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleNotifier>().strings;
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.tablet;
    final captions = [
      strings.previewCaption1,
      strings.previewCaption2,
      strings.previewCaption3,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: SSSpacing.xxl),
      color: SSColors.surface,
      child: Center(
        child: Padding(
          padding: ssSectionPadding(context),
          child: Column(
            children: [
              SSScrollReveal(
                child: Column(children: [
                  AnimatedSwitcher(
                    duration: SSMotion.fast,
                    child: Text(strings.previewSectionTitle,
                        key: ValueKey(strings.previewSectionTitle),
                        style: SSTextStyles.headline.responsive(context),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: SSSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: AnimatedSwitcher(
                      duration: SSMotion.fast,
                      child: Text(strings.previewSectionSubtitle,
                          key: ValueKey(strings.previewSectionSubtitle),
                          style: SSTextStyles.body,
                          textAlign: TextAlign.center),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: SSSpacing.xxl),
              isMobile
                  ? _MobilePreview(
                      pageController: _pageController,
                      currentPage: _currentPage,
                      captions: captions,
                      screens: _screens,
                      showSwipeCaption: _showSwipeCaption,
                      onPageChanged: (i) => setState(() {
                        _currentPage = i;
                        _showSwipeCaption = false;
                      }),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SSScrollReveal(
                          delay: Duration.zero,
                          child: _PhoneWithCaption(
                            assetPath: _screens[0].assetPath,
                            caption: captions[0],
                            widthScale: _screens[0].widthScale,
                          ),
                        ),
                        const SizedBox(width: SSSpacing.xl),
                        SSScrollReveal(
                          delay: const Duration(milliseconds: 100),
                          child: _PhoneWithCaption(
                            assetPath: _screens[1].assetPath,
                            caption: captions[1],
                            widthScale: _screens[1].widthScale,
                          ),
                        ),
                        const SizedBox(width: SSSpacing.xl),
                        // SSScrollReveal(
                        //   delay: const Duration(milliseconds: 200),
                        //   child: _PhoneWithCaption(
                        //     assetPath: _screens[2].assetPath,
                        //     caption: captions[2],
                        //     widthScale: _screens[2].widthScale,
                        //   ),
                        // ),
                        _PhoneWithCaption(
                          assetPath: _screens[2].assetPath,
                          caption: captions[2],
                          widthScale: _screens[2].widthScale,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobilePreview extends StatelessWidget {
  const _MobilePreview({
    required this.pageController,
    required this.currentPage,
    required this.captions,
    required this.screens,
    required this.showSwipeCaption,
    required this.onPageChanged,
  });

  final PageController pageController;
  final int currentPage;
  final List<String> captions;
  final List<({String assetPath, double widthScale})> screens;
  final bool showSwipeCaption;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: screens.length,
            scrollBehavior: const ScrollBehavior().copyWith(
              // ← 여기 추가
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, i) {
              final s = screens[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: AnimatedScale(
                    scale: i == currentPage ? 1.0 : 0.95,
                    duration: SSMotion.fast,
                    child: SSPhoneMockup(
                      width: 230.0 * s.widthScale,
                      child: _ScreenPlaceholder(assetPath: s.assetPath),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: SSSpacing.lg),
        // Caption
        AnimatedSwitcher(
          duration: SSMotion.fast,
          child: Text(
            showSwipeCaption ? 'Swipe to explore →' : captions[currentPage],
            key: ValueKey(
                showSwipeCaption ? 'swipe_hint' : captions[currentPage]),
            style: SSTextStyles.caption.copyWith(
              fontSize: 14,
              color: showSwipeCaption
                  ? SSColors.textMuted
                  : SSColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: SSSpacing.md),
        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < screens.length; i++)
              GestureDetector(
                onTap: () => pageController.animateToPage(
                  i,
                  duration: SSMotion.normal,
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: SSMotion.normal,
                  curve: Curves.easeInOut,
                  width: i == currentPage ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: SSSpacing.xs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == currentPage ? SSColors.accent : SSColors.border,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PhoneWithCaption extends StatelessWidget {
  const _PhoneWithCaption({
    required this.assetPath,
    required this.caption,
    this.widthScale = 1.0,
  });

  final String assetPath;
  final String caption;
  final double widthScale;

  @override
  Widget build(BuildContext context) {
    final w = 230.0 * widthScale;
    return Column(
      children: [
        SSPhoneMockup(
          width: w,
          child: _ScreenPlaceholder(assetPath: assetPath),
        ),
        const SizedBox(height: SSSpacing.lg),
        AnimatedSwitcher(
          duration: SSMotion.fast,
          child: Text(
            caption,
            key: ValueKey(caption),
            style: SSTextStyles.caption
                .copyWith(fontSize: 14, color: SSColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ScreenPlaceholder extends StatelessWidget {
  const _ScreenPlaceholder({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: SSColors.surface,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android_rounded,
                  color: SSColors.textMuted, size: 36),
              const SizedBox(height: SSSpacing.sm),
              Text('Screenshot',
                  style:
                      SSTextStyles.caption.copyWith(color: SSColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
