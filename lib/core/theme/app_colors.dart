import 'package:flutter/material.dart';

/// Centralized color tokens for the FloodStore brand.
///
/// Nothing in the UI layer should hardcode a hex value — every color used
/// in a widget must trace back to a token defined here. This keeps the
/// "luxury minimalism" language consistent across every screen and makes
/// future theming (light/dark modes) a one-file change.
abstract final class AppColors {
  // =========================================================================
  // DARK THEME TOKENS (existing brand - dark-first luxury)
  // =========================================================================
  static const Color darkBackground = Color(0xFF05070B);
  static const Color darkSurface = Color(0xFF0A0D13);
  static const Color darkCard = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)
  static const Color darkCardElevated = Color(0x14FFFFFF); // 0.08

  static const Color darkPrimary = Color(0xFF0EA5FF);
  static const Color darkSecondary = Color(0xFF4FD1FF);

  static const Color darkTextPrimary = Color(0xFFF5F7FA);
  static const Color darkTextSecondary = Color(0xFFA7B0BE);
  static const Color darkTextTertiary = Color(0xFF6B7280);

  static const Color darkBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color darkBorderStrong = Color(0x26FFFFFF); // 0.15
  static const Color darkDivider = Color(0x0FFFFFFF);

  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkError = Color(0xFFFF6B6B);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkInfo = Color(0xFF60A5FA);

  static const Color darkFocusRing = Color(0xFF7DD3FC);
  static const Color darkDisabledText = Color(0xFF4B5563);
  static const Color darkDisabledSurface = Color(0x08FFFFFF); // 0.03

  static const Color darkScrim = Color(0xB3000000); // rgba(0,0,0,0.70)
  static const Color darkScrimLight = Color(0x66000000); // 0.40

  static const Color darkShimmerBase = Color(0x0FFFFFFF);
  static const Color darkShimmerHighlight = Color(0x26FFFFFF);

  static const LinearGradient darkBrandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPrimary, darkSecondary],
  );

  static const LinearGradient darkGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x14FFFFFF), Color(0x05FFFFFF)],
  );

  static const LinearGradient darkBackgroundDepthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF070A10), darkBackground, Color(0xFF030407)],
  );

  static RadialGradient darkGlow({double opacity = 0.35}) => RadialGradient(
        colors: [
          darkPrimary.withValues(alpha: opacity),
          darkPrimary.withValues(alpha: 0),
        ],
      );

  // =========================================================================
  // LIGHT THEME TOKENS (new - premium light mode)
  // =========================================================================
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF5F5F5);
  static const Color lightCardElevated = Color(0xFFFFFFFF);

  static const Color lightPrimary = Color(0xFF0066CC);
  static const Color lightSecondary = Color(0xFF0099FF);

  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF4A4A5A);
  static const Color lightTextTertiary = Color(0xFF8A8A9A);

  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightBorderStrong = Color(0xFFCCCCCC);
  static const Color lightDivider = Color(0xFFEEEEEE);

  static const Color lightSuccess = Color(0xFF00A86B);
  static const Color lightError = Color(0xFFE53E3E);
  static const Color lightWarning = Color(0xFFF5A623);
  static const Color lightInfo = Color(0xFF2196F3);

  static const Color lightFocusRing = Color(0xFF0066CC);
  static const Color lightDisabledText = Color(0xFFBDBDBD);
  static const Color lightDisabledSurface = Color(0xFFF0F0F0);

  static const Color lightScrim = Color(0x80000000); // rgba(0,0,0,0.50)
  static const Color lightScrimLight = Color(0x40000000); // 0.25

  static const Color lightShimmerBase = Color(0xFFE0E0E0);
  static const Color lightShimmerHighlight = Color(0xFFF5F5F5);

  static const LinearGradient lightBrandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightPrimary, lightSecondary],
  );

  static const LinearGradient lightGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5F5F5), Color(0xFFFFFFFF)],
  );

  static const LinearGradient lightBackgroundDepthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0F0F0), lightBackground, Color(0xFFFAFAFA)],
  );

  static RadialGradient lightGlow({double opacity = 0.25}) => RadialGradient(
        colors: [
          lightPrimary.withValues(alpha: opacity),
          lightPrimary.withValues(alpha: 0),
        ],
      );

  // =========================================================================
  // BACKWARD COMPATIBILITY ALIASES (resolve to dark theme - brand default)
  // =========================================================================
  /// @deprecated Use Theme.of(context).colorScheme or AppTheme.dark/light instead.
  /// These exist for backward compatibility with existing widget code.
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color card = darkCard;
  static const Color cardElevated = darkCardElevated;
  static const Color primary = darkPrimary;
  static const Color secondary = darkSecondary;
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textTertiary = darkTextTertiary;
  static const Color border = darkBorder;
  static const Color borderStrong = darkBorderStrong;
  static const Color divider = darkDivider;
  static const Color success = darkSuccess;
  static const Color error = darkError;
  static const Color warning = darkWarning;
  static const Color info = darkInfo;
  static const Color focusRing = darkFocusRing;
  static const Color disabledText = darkDisabledText;
  static const Color disabledSurface = darkDisabledSurface;
  static const Color scrim = darkScrim;
  static const Color scrimLight = darkScrimLight;
  static const Color shimmerBase = darkShimmerBase;
  static const Color shimmerHighlight = darkShimmerHighlight;
  static const LinearGradient brandGradient = darkBrandGradient;
  static const LinearGradient glassGradient = darkGlassGradient;
  static const LinearGradient backgroundDepthGradient = darkBackgroundDepthGradient;

  static RadialGradient glow({double opacity = 0.35}) => darkGlow(opacity: opacity);
}
