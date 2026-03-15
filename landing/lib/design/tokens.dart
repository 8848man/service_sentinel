import 'package:flutter/material.dart';

abstract final class SSBreakpoint {
  static const double mobile  = 480;
  static const double tablet  = 768;
  static const double desktop = 1024;
}

extension SSTextStyleResponsive on TextStyle {
  TextStyle responsive(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= SSBreakpoint.tablet) return this;
    final size = fontSize;
    if (size == null) return this;
    if (size > 40) return copyWith(fontSize: 28);
    if (size > 28) return copyWith(fontSize: 22);
    if (size > 18) return copyWith(fontSize: 18);
    if (size > 15) return copyWith(fontSize: 16);
    return this;
  }
}

abstract final class SSColors {
  static const background    = Color(0xFF0D1B2A);
  static const surface       = Color(0xFF112236);
  static const surfaceLight  = Color(0xFF1A3350);
  static const accent        = Color(0xFF378ADD);
  static const danger        = Color(0xFFE24B4A);
  static const success       = Color(0xFF1D9E75);
  static const warning       = Color(0xFFF59E0B);
  static const textPrimary   = Color(0xFFEFF6FF);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted     = Color(0xFF4E6C87);
  static const border        = Color(0xFF1E3A54);
}

abstract final class SSTextStyles {
  static const _fallback = ['NotoSansKR'];

  static final display = TextStyle(
    fontFamilyFallback: _fallback,
    fontSize: 56,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -1.0,
    color: SSColors.textPrimary,
  );

  static final headline = TextStyle(
    fontFamilyFallback: _fallback,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: SSColors.textPrimary,
  );

  static final title = TextStyle(
    fontFamilyFallback: _fallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: SSColors.textPrimary,
  );

  static final body = TextStyle(
    fontFamilyFallback: _fallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.7,
    color: SSColors.textSecondary,
  );

  static final caption = TextStyle(
    fontFamilyFallback: _fallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: SSColors.textMuted,
  );

  static final label = TextStyle(
    fontFamilyFallback: _fallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
    color: SSColors.textPrimary,
  );
}

abstract final class SSSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 40;
  static const double xxl = 64;
}

abstract final class SSRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 20;
  static BorderRadius get bSm => BorderRadius.circular(sm);
  static BorderRadius get bMd => BorderRadius.circular(md);
  static BorderRadius get bLg => BorderRadius.circular(lg);
  static BorderRadius get bXl => BorderRadius.circular(xl);
}

abstract final class SSMotion {
  static const fast     = Duration(milliseconds: 150);
  static const normal   = Duration(milliseconds: 300);
  static const slow     = Duration(milliseconds: 500);
  static const verySlow = Duration(milliseconds: 800);
}
