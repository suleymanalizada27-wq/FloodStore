import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Depth tokens: blur sigmas and shadow presets that give the "glass over
/// deep space" look its sense of physical layering.
///
/// Kept separate from [AppColors] because these are structural (how much
/// blur, how soft a shadow) rather than chromatic — a future light theme
/// would likely keep every value in this file unchanged while swapping
/// [AppColors] entirely.
abstract final class AppEffects {
  // Backdrop blur sigmas ---------------------------------------------

  /// Subtle blur for small chips/badges.
  static const double blurSubtle = 8;

  /// Standard glass-card blur (auth cards, dialogs).
  static const double blurCard = 20;

  /// Heavy blur for full-bleed background depth layers.
  static const double blurBackground = 60;

  // Shadows -------------------------------------------------------------

  /// Barely-there lift — resting state of an interactive card.
  static List<BoxShadow> get shadowSoft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.24),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Pressed/hovered elevation — the FloodStore primary button at rest.
  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.32),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  /// Maximum elevation — modals, the hero logo.
  static List<BoxShadow> get shadowStrong => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 48,
          offset: const Offset(0, 20),
        ),
      ];

  /// A soft, colored glow behind brand elements (logo, primary CTA on
  /// hover/focus). [color] defaults to the brand primary; [intensity] is
  /// 0..1 and maps to both opacity and spread so callers can pulse it in
  /// an animation without recomputing a whole shadow list every frame.
  static List<BoxShadow> glow({
    Color color = AppColors.primary,
    double intensity = 1,
  }) {
    final double clamped = intensity.clamp(0.0, 1.0).toDouble();
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.45 * clamped),
        blurRadius: 40 * clamped,
        spreadRadius: 2 * clamped,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.2 * clamped),
        blurRadius: 90 * clamped,
        spreadRadius: 8 * clamped,
      ),
    ];
  }
}
