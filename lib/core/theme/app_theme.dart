import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// FloodStore's canonical Material 3 theme — supports both dark (brand default)
/// and light modes. Uses semantic color tokens from [AppColors] so the entire
/// color palette lives in one place.
abstract final class AppTheme {
  static ThemeData get dark => _buildTheme(_DarkTokenResolver());
  static ThemeData get light => _buildTheme(_LightTokenResolver());

  static ThemeData _buildTheme(_TokenResolver tokens) {
    final colorScheme = ColorScheme(
      brightness: tokens.brightness,
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      secondary: tokens.secondary,
      onSecondary: tokens.onSecondary,
      tertiary: tokens.tertiary,
      onTertiary: tokens.onTertiary,
      surface: tokens.surface,
      onSurface: tokens.onSurface,
      surfaceContainerHighest: tokens.surfaceContainerHighest,
      surfaceContainerHigh: tokens.surfaceContainerHigh,
      surfaceContainerLow: tokens.surfaceContainerLow,
      surfaceContainerLowest: tokens.surfaceContainerLowest,
      error: tokens.error,
      onError: tokens.onError,
      outline: tokens.outline,
      outlineVariant: tokens.outlineVariant,
      shadow: tokens.shadow,
      scrim: tokens.scrim,
      inverseSurface: tokens.inverseSurface,
      onInverseSurface: tokens.onInverseSurface,
      inversePrimary: tokens.inversePrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: tokens.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.scaffoldBackground,
      canvasColor: tokens.canvasColor,
      splashFactory: InkSparkle.splashFactory,
      textTheme: AppTextStyles.textTheme.apply(
        bodyColor: tokens.textPrimary,
        displayColor: tokens.textPrimary,
      ),
      fontFamily: AppTextStyles.body(size: 14).fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: tokens.textPrimary,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(color: tokens.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: tokens.cardColor,
        elevation: tokens.cardElevation,
        shadowColor: tokens.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokens.cardBorder, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.body(size: 15, weight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.body(size: 15, weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.primary,
          side: BorderSide(color: tokens.outline, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.body(size: 15, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppTextStyles.body(size: 14, weight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.inputFillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.inputBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.inputBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.error, width: 2),
        ),
        labelStyle: AppTextStyles.body(size: 14, color: tokens.textSecondary),
        hintStyle: AppTextStyles.body(size: 14, color: tokens.textTertiary),
        errorStyle: AppTextStyles.body(size: 12, color: tokens.error),
        floatingLabelStyle: AppTextStyles.body(size: 12, color: tokens.primary, weight: FontWeight.w600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.chipBackgroundColor,
        selectedColor: tokens.primary.withValues(alpha: 0.12),
        disabledColor: tokens.disabledSurface,
        labelStyle: AppTextStyles.body(size: 13, color: tokens.textSecondary),
        secondaryLabelStyle: AppTextStyles.body(size: 13, color: tokens.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: tokens.outlineVariant, width: 1),
        ),
        brightness: tokens.brightness,
      ),
      dividerTheme: DividerThemeData(
        color: tokens.dividerColor,
        thickness: 0.5,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: tokens.primary.withValues(alpha: 0.08),
        iconColor: tokens.textSecondary,
        textColor: tokens.textPrimary,
        titleTextStyle: AppTextStyles.body(size: 16, weight: FontWeight.w500, color: tokens.textPrimary),
        subtitleTextStyle: AppTextStyles.body(size: 14, color: tokens.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.surface,
        selectedItemColor: tokens.primary,
        unselectedItemColor: tokens.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedLabelStyle: AppTextStyles.body(size: 12, weight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.body(size: 12, weight: FontWeight.w400),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surface,
        indicatorColor: tokens.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.body(size: 12, weight: FontWeight.w600, color: tokens.primary);
          }
          return AppTextStyles.body(size: 12, color: tokens.textTertiary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: tokens.primary, size: 24);
          }
          return IconThemeData(color: tokens.textTertiary, size: 24);
        }),
        height: 72,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.primary,
        foregroundColor: tokens.onPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.surfaceContainerHighest,
        contentTextStyle: AppTextStyles.body(size: 14, color: tokens.onSurface),
        actionTextColor: tokens.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(color: tokens.textPrimary),
        contentTextStyle: AppTextStyles.body(size: 15, color: tokens.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalBackgroundColor: tokens.surface,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: tokens.primary,
        unselectedLabelColor: tokens.textTertiary,
        indicatorColor: tokens.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: AppTextStyles.body(size: 14, weight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.body(size: 14, weight: FontWeight.w400),
        dividerColor: tokens.dividerColor,
        splashFactory: InkSparkle.splashFactory,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.primary,
        linearTrackColor: tokens.primary.withValues(alpha: 0.15),
        circularTrackColor: tokens.primary.withValues(alpha: 0.15),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: tokens.primary,
        inactiveTrackColor: tokens.primary.withValues(alpha: 0.15),
        thumbColor: tokens.primary,
        overlayColor: tokens.primary.withValues(alpha: 0.12),
        valueIndicatorColor: tokens.primary,
        valueIndicatorTextStyle: AppTextStyles.body(size: 12, color: tokens.onPrimary),
      ),
    );
  }
}

/// Abstract token resolver — each theme mode provides its own implementation.
abstract class _TokenResolver {
  Brightness get brightness;
  Color get primary;
  Color get onPrimary;
  Color get secondary;
  Color get onSecondary;
  Color get tertiary;
  Color get onTertiary;
  Color get surface;
  Color get onSurface;
  Color get surfaceContainerHighest;
  Color get surfaceContainerHigh;
  Color get surfaceContainerLow;
  Color get surfaceContainerLowest;
  Color get error;
  Color get onError;
  Color get outline;
  Color get outlineVariant;
  Color get shadow;
  Color get scrim;
  Color get inverseSurface;
  Color get onInverseSurface;
  Color get inversePrimary;

  Color get scaffoldBackground;
  Color get canvasColor;
  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;
  Color get cardColor;
  double get cardElevation;
  Color get cardBorder;
  Color get dividerColor;
  Color get inputFillColor;
  Color get inputBorderColor;
  Color get chipBackgroundColor;
  Color get disabledSurface;
}

class _DarkTokenResolver implements _TokenResolver {
  @override
  Brightness get brightness => Brightness.dark;

  @override
  Color get primary => AppColors.darkPrimary;
  @override
  Color get onPrimary => AppColors.white;
  @override
  Color get secondary => AppColors.darkSecondary;
  @override
  Color get onSecondary => AppColors.darkBackground;
  @override
  Color get tertiary => AppColors.darkInfo;
  @override
  Color get onTertiary => AppColors.white;

  @override
  Color get surface => AppColors.darkSurface;
  @override
  Color get onSurface => AppColors.darkTextPrimary;
  @override
  Color get surfaceContainerHighest => AppColors.darkCardElevated;
  @override
  Color get surfaceContainerHigh => AppColors.darkCardElevated;
  @override
  Color get surfaceContainerLow => AppColors.darkCard;
  @override
  Color get surfaceContainerLowest => AppColors.darkBackground;

  @override
  Color get error => AppColors.darkError;
  @override
  Color get onError => AppColors.white;
  @override
  Color get outline => AppColors.darkBorderStrong;
  @override
  Color get outlineVariant => AppColors.darkBorder;
  @override
  Color get shadow => AppColors.darkScrim;
  @override
  Color get scrim => AppColors.darkScrim;
  @override
  Color get inverseSurface => AppColors.white;
  @override
  Color get onInverseSurface => AppColors.darkBackground;
  @override
  Color get inversePrimary => AppColors.darkPrimary;

  @override
  Color get scaffoldBackground => AppColors.darkBackground;
  @override
  Color get canvasColor => AppColors.darkBackground;
  @override
  Color get textPrimary => AppColors.darkTextPrimary;
  @override
  Color get textSecondary => AppColors.darkTextSecondary;
  @override
  Color get textTertiary => AppColors.darkTextTertiary;
  @override
  Color get cardColor => AppColors.darkCard;
  @override
  double get cardElevation => 2;
  @override
  Color get cardBorder => AppColors.darkBorder;
  @override
  Color get dividerColor => AppColors.darkDivider;
  @override
  Color get inputFillColor => AppColors.darkCard;
  @override
  Color get inputBorderColor => AppColors.darkBorderStrong;
  @override
  Color get chipBackgroundColor => AppColors.darkCard;
  @override
  Color get disabledSurface => AppColors.darkDisabledSurface;
}

class _LightTokenResolver implements _TokenResolver {
  @override
  Brightness get brightness => Brightness.light;

  @override
  Color get primary => AppColors.lightPrimary;
  @override
  Color get onPrimary => AppColors.white;
  @override
  Color get secondary => AppColors.lightSecondary;
  @override
  Color get onSecondary => AppColors.white;
  @override
  Color get tertiary => AppColors.lightInfo;
  @override
  Color get onTertiary => AppColors.white;

  @override
  Color get surface => AppColors.lightSurface;
  @override
  Color get onSurface => AppColors.lightTextPrimary;
  @override
  Color get surfaceContainerHighest => AppColors.lightCardElevated;
  @override
  Color get surfaceContainerHigh => AppColors.lightCardElevated;
  @override
  Color get surfaceContainerLow => AppColors.lightCard;
  @override
  Color get surfaceContainerLowest => AppColors.lightBackground;

  @override
  Color get error => AppColors.lightError;
  @override
  Color get onError => AppColors.white;
  @override
  Color get outline => AppColors.lightBorderStrong;
  @override
  Color get outlineVariant => AppColors.lightBorder;
  @override
  Color get shadow => AppColors.lightScrim;
  @override
  Color get scrim => AppColors.lightScrim;
  @override
  Color get inverseSurface => AppColors.darkBackground;
  @override
  Color get onInverseSurface => AppColors.white;
  @override
  Color get inversePrimary => AppColors.lightPrimary;

  @override
  Color get scaffoldBackground => AppColors.lightBackground;
  @override
  Color get canvasColor => AppColors.lightBackground;
  @override
  Color get textPrimary => AppColors.lightTextPrimary;
  @override
  Color get textSecondary => AppColors.lightTextSecondary;
  @override
  Color get textTertiary => AppColors.lightTextTertiary;
  @override
  Color get cardColor => AppColors.lightCard;
  @override
  double get cardElevation => 1;
  @override
  Color get cardBorder => AppColors.lightBorder;
  @override
  Color get dividerColor => AppColors.lightDivider;
  @override
  Color get inputFillColor => AppColors.lightSurface;
  @override
  Color get inputBorderColor => AppColors.lightBorderStrong;
  @override
  Color get chipBackgroundColor => AppColors.lightCard;
  @override
  Color get disabledSurface => AppColors.lightDisabledSurface;
}