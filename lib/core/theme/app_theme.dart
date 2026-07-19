import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// FloodStore's single, canonical Material 3 theme.
///
/// There is intentionally no light theme — the brand is dark-first, the way
/// Linear and Arc are. If a light mode is ever required, fork this file
/// rather than branching every widget on `Theme.of(context).brightness`.
abstract final class AppTheme {
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark().copyWith(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.white,
      outline: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: AppTextStyles.textTheme,
      fontFamily: AppTextStyles.body(size: 14).fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}