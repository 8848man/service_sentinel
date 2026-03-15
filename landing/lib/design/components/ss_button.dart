import 'package:flutter/material.dart';
import '../tokens.dart';
import '../animations/ss_hover_scale.dart';

enum SSButtonVariant { primary, outline, ghost }

class SSButton extends StatefulWidget {
  const SSButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SSButtonVariant.primary,
    this.isFullWidth = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final SSButtonVariant variant;
  final bool isFullWidth;
  final IconData? icon;

  @override
  State<SSButton> createState() => _SSButtonState();
}

class _SSButtonState extends State<SSButton> {
  bool _hovered = false;

  Color get _bgColor => switch (widget.variant) {
    SSButtonVariant.primary =>
      _hovered ? const Color(0xFF4A9AED) : SSColors.accent,
    SSButtonVariant.outline ||
    SSButtonVariant.ghost =>
      _hovered ? SSColors.accent.withOpacity(0.12) : Colors.transparent,
  };

  Color get _fgColor => switch (widget.variant) {
    SSButtonVariant.primary => SSColors.textPrimary,
    SSButtonVariant.outline ||
    SSButtonVariant.ghost =>
      _hovered ? SSColors.accent : SSColors.textSecondary,
  };

  Border? get _border => widget.variant == SSButtonVariant.outline
      ? Border.all(
          color: _hovered ? SSColors.accent : SSColors.border,
          width: 1.5,
        )
      : null;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < SSBreakpoint.mobile;
    Widget content = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: SSMotion.fast,
          padding: EdgeInsets.symmetric(
            horizontal: SSSpacing.lg,
            vertical: isMobile ? 14 : 10,
          ),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: SSRadius.bMd,
            border: _border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: _fgColor, size: 18),
                const SizedBox(width: SSSpacing.sm),
              ],
              AnimatedDefaultTextStyle(
                duration: SSMotion.fast,
                style: SSTextStyles.label.copyWith(color: _fgColor),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isFullWidth) {
      return SSHoverScale(
          child: SizedBox(width: double.infinity, child: content));
    }
    return SSHoverScale(child: content);
  }
}
