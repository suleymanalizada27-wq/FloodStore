import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A frosted-glass surface used for the authentication card and any other
/// "floating panel" content.
///
/// Glassmorphism is applied deliberately and only here — per the brand
/// brief it should be the exception, not the wallpaper.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.borderRadius = 28,
    this.blurSigma = 24,
    this.borderColor = AppColors.border,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurSigma;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: AppColors.glassGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
