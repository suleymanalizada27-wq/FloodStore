import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography system for FloodStore.
///
/// Display/heading text uses Manrope for a geometric, confident presence
/// (comparable to how Linear/Arc lean on a distinctive grotesque). Body and
/// UI text uses Inter, chosen for its exceptional legibility at small sizes
/// — the same reasoning Stripe and Notion apply to their product UIs.
abstract final class AppTextStyles {
  static TextTheme get textTheme => TextTheme(
        displayLarge: display(size: 44),
        displayMedium: display(size: 34),
        displaySmall: display(size: 28),
        headlineLarge: heading(size: 24),
        headlineMedium: heading(size: 20),
        headlineSmall: heading(size: 18),
        titleLarge: heading(size: 16),
        titleMedium: body(size: 15, weight: FontWeight.w600),
        titleSmall: body(size: 13, weight: FontWeight.w600),
        bodyLarge: body(size: 16),
        bodyMedium: body(size: 14),
        bodySmall: body(size: 12, color: AppColors.textSecondary),
        labelLarge: body(size: 14, weight: FontWeight.w600),
        labelMedium: body(size: 12, weight: FontWeight.w500),
        labelSmall: body(
          size: 11,
          weight: FontWeight.w500,
          color: AppColors.textTertiary,
        ),
      );

  /// Convenience static equivalents of the [textTheme] entries of the same
  /// name — [AuthShell], [LoginScreen], and [ForgotPasswordScreen] all
  /// reference `AppTextStyles.headlineMedium` / `.headlineLarge` directly
  /// rather than through `Theme.of(context).textTheme`, so these need to
  /// exist as static getters too, not just inside [textTheme].
  static TextStyle get headlineLarge => heading(size: 24);
  static TextStyle get headlineMedium => heading(size: 20);
  static TextStyle get headlineSmall => heading(size: 18);
  static TextStyle get titleMedium => heading(size: 15);

  static TextStyle display({
    required double size,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -1.2,
        height: 1.08,
      );

  static TextStyle heading({
    required double size,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle body({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 0,
        height: 1.4,
      );

  /// Wide, tracked-out label used for eyebrow text like "STORE" under the
  /// wordmark, or section kickers.
  static TextStyle overline({
    Color color = AppColors.secondary,
    double size = 12,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 4,
      );

  /// Fixed-width digit style for OTP cells and other short numeric codes,
  /// where tabular figures keep every glyph the same width so the digits
  /// don't visually jitter as they fill in.
  static TextStyle code({
    double size = 24,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
