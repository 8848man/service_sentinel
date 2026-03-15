import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../tokens.dart';
import '../animations/ss_hover_scale.dart';
import '../utils/responsive.dart';
import 'ss_button.dart';

class SSNavBar extends StatefulWidget {
  const SSNavBar({super.key, required this.isScrolled, this.onStartFree});

  final bool isScrolled;
  final VoidCallback? onStartFree;

  @override
  State<SSNavBar> createState() => _SSNavBarState();
}

class _SSNavBarState extends State<SSNavBar> {
  OverlayEntry? _drawerEntry;

  void _openDrawer(BuildContext context) {
    final notifier = context.read<LocaleNotifier>();
    _drawerEntry = OverlayEntry(
      builder: (_) => ChangeNotifierProvider.value(
        value: notifier,
        child: _MobileDrawer(
          onClose: _closeDrawer,
          onStartFree: widget.onStartFree,
        ),
      ),
    );
    Overlay.of(context).insert(_drawerEntry!);
  }

  void _closeDrawer() {
    _drawerEntry?.remove();
    _drawerEntry = null;
  }

  @override
  void dispose() {
    _drawerEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<LocaleNotifier>();
    final strings  = notifier.strings;
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.tablet;

    final bar = AnimatedContainer(
      duration: SSMotion.normal,
      decoration: BoxDecoration(
        color: widget.isScrolled
            ? SSColors.background.withOpacity(0.88)
            : Colors.transparent,
        border: widget.isScrolled
            ? const Border(
                bottom: BorderSide(color: SSColors.border, width: 1))
            : null,
      ),
      child: isMobile
          ? _MobileNavContent(
              strings: strings,
              onHamburger: () => _openDrawer(context),
            )
          : _DesktopNavContent(
              strings: strings,
              notifier: notifier,
              onStartFree: widget.onStartFree,
            ),
    );

    if (widget.isScrolled) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: bar,
        ),
      );
    }
    return bar;
  }
}

class _DesktopNavContent extends StatelessWidget {
  const _DesktopNavContent({
    required this.strings,
    required this.notifier,
    this.onStartFree,
  });

  final SSStrings strings;
  final LocaleNotifier notifier;
  final VoidCallback? onStartFree;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ssSectionPadding(context).horizontal / 2,
            vertical: SSSpacing.md,
          ),
          child: Row(
            children: [
              _Logo(),
              const Spacer(),
              _NavLink(label: strings.navFeatures),
              const SizedBox(width: SSSpacing.xl),
              _LangToggle(notifier: notifier),
              const SizedBox(width: SSSpacing.lg),
              SSButton(
                  label: strings.navStartFree,
                  onPressed: onStartFree ?? () {},
                  variant: SSButtonVariant.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileNavContent extends StatelessWidget {
  const _MobileNavContent(
      {required this.strings, required this.onHamburger});

  final SSStrings strings;
  final VoidCallback onHamburger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SSSpacing.md, vertical: SSSpacing.md),
      child: Row(
        children: [
          _Logo(),
          const Spacer(),
          GestureDetector(
            onTap: onHamburger,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                width: 48,
                height: 48,
                child: const Icon(Icons.menu_rounded,
                    color: SSColors.textPrimary, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: SSColors.accent, borderRadius: SSRadius.bSm),
        child:
            const Icon(Icons.radar_rounded, color: Colors.white, size: 20),
      ),
      const SizedBox(width: SSSpacing.sm),
      Text('Service Sentinel',
          style: SSTextStyles.label.copyWith(fontSize: 15)),
    ]);
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label});
  final String label;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedDefaultTextStyle(
        duration: SSMotion.fast,
        style: SSTextStyles.label.copyWith(
          color: _hovered ? SSColors.textPrimary : SSColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        child: Text(widget.label),
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  const _LangToggle({required this.notifier});
  final LocaleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isEn = notifier.currentLocale.languageCode == 'en';
    return SSHoverScale(
      child: GestureDetector(
        onTap: notifier.toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Row(children: [
            Text('EN',
                style: SSTextStyles.label.copyWith(
                  color: isEn ? SSColors.accent : SSColors.textMuted,
                  fontWeight: isEn ? FontWeight.w700 : FontWeight.w400,
                )),
            Text(' | ',
                style:
                    SSTextStyles.label.copyWith(color: SSColors.textMuted)),
            Text('KO',
                style: SSTextStyles.label.copyWith(
                  color: !isEn ? SSColors.accent : SSColors.textMuted,
                  fontWeight: !isEn ? FontWeight.w700 : FontWeight.w400,
                )),
          ]),
        ),
      ),
    );
  }
}

// ── Mobile full-screen drawer overlay ────────────────────────────────────────

class _MobileDrawer extends StatefulWidget {
  const _MobileDrawer({required this.onClose, this.onStartFree});
  final VoidCallback onClose;
  final VoidCallback? onStartFree;

  @override
  State<_MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<_MobileDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: SSMotion.normal);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    if (mounted) widget.onClose();
  }

  Future<void> _closeAndScroll() async {
    final onStartFree = widget.onStartFree;
    await _controller.reverse();
    widget.onClose();
    await Future.delayed(SSMotion.normal);
    onStartFree?.call();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<LocaleNotifier>();
    final strings  = notifier.strings;
    final isEn = notifier.currentLocale.languageCode == 'en';

    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: SSColors.background.withOpacity(0.97),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: SSSpacing.md, vertical: SSSpacing.md),
                child: Row(
                  children: [
                    _Logo(),
                    const Spacer(),
                    GestureDetector(
                      onTap: _close,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: const Icon(Icons.close_rounded,
                              color: SSColors.textPrimary, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: SSColors.border, height: 1),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(SSSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: SSSpacing.lg),

                      // Nav link
                      _DrawerNavLink(
                          label: strings.navFeatures, onTap: _close),
                      const SizedBox(height: SSSpacing.xxl),

                      // Lang toggle
                      GestureDetector(
                        onTap: () => notifier.toggle(),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Row(children: [
                            Text('EN',
                                style: SSTextStyles.label.copyWith(
                                  color: isEn
                                      ? SSColors.accent
                                      : SSColors.textMuted,
                                  fontWeight: isEn
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                )),
                            Text(' | ',
                                style: SSTextStyles.label
                                    .copyWith(color: SSColors.textMuted)),
                            Text('KO',
                                style: SSTextStyles.label.copyWith(
                                  color: !isEn
                                      ? SSColors.accent
                                      : SSColors.textMuted,
                                  fontWeight: !isEn
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                )),
                          ]),
                        ),
                      ),
                      const SizedBox(height: SSSpacing.xl),

                      // CTA button
                      SSButton(
                        label: strings.navStartFree,
                        onPressed: _closeAndScroll,
                        variant: SSButtonVariant.primary,
                        isFullWidth: true,
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

class _DrawerNavLink extends StatefulWidget {
  const _DrawerNavLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_DrawerNavLink> createState() => _DrawerNavLinkState();
}

class _DrawerNavLinkState extends State<_DrawerNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: SSMotion.fast,
          style: SSTextStyles.headline.copyWith(
            fontSize: 28,
            color: _hovered ? SSColors.textPrimary : SSColors.textSecondary,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
