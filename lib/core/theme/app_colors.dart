import 'package:flutter/material.dart';

/// Centralized color tokens for the FloodStore brand.
///
/// Nothing in the UI layer should hardcode a hex value — every color used
/// in a widget must trace back to a token defined here. This keeps the
/// "luxury minimalism" language consistent across every screen and makes
/// future theming (e.g. a light mode) a one-file change.
abstract final class AppColors {
  // Base surfaces
  static const Color background = Color(0xFF05070B);
  static const Color surface = Color(0xFF0A0D13);
  static const Color card = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)
  static const Color cardElevated = Color(0x14FFFFFF); // 0.08

  // Brand
  static const Color primary = Color(0xFF0EA5FF);
  static const Color secondary = Color(0xFF4FD1FF);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFA7B0BE);
  static const Color textTertiary = Color(0xFF6B7280);

  // Structure
  static const Color border = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color borderStrong = Color(0x26FFFFFF); // 0.15
  static const Color divider = Color(0x0FFFFFFF);

  // Feedback
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF60A5FA);

  // Interaction state
  /// Ring drawn around the currently keyboard-focused control — distinct
  /// from [primary] so it reads as "focus" even on primary-colored
  /// elements (e.g. focusing the primary button via Tab).
  static const Color focusRing = Color(0xFF7DD3FC);
  static const Color disabledText = Color(0xFF4B5563);
  static const Color disabledSurface = Color(0x08FFFFFF); // 0.03

  // Overlays / scrims
  static const Color scrim = Color(0xB3000000); // rgba(0,0,0,0.70)
  static const Color scrimLight = Color(0x66000000); // 0.40

  // Shimmer (skeleton / loading-state sweep)
  static const Color shimmerBase = Color(0x0FFFFFFF);
  static const Color shimmerHighlight = Color(0x26FFFFFF);

  // Gradients — used sparingly, per brand guidance ("no gradients everywhere")
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x14FFFFFF), Color(0x05FFFFFF)],
  );

  /// Vertical depth wash used behind the animated background layers —
  /// pulls the eye toward the center where the logo/card sit.
  static const LinearGradient backgroundDepthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF070A10), background, Color(0xFF030407)],
  );

  static RadialGradient glow({double opacity = 0.35}) => RadialGradient(
        colors: [
          primary.withValues(alpha: opacity),
          primary.withValues(alpha: 0),
        ],
      );
}
