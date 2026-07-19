import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/breathing_logo.dart';
import '../../../core/widgets/particle_background.dart';
import '../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onNavigate});
  
  /// Called when splash duration completes. In production this navigates to auth.
  /// In tests, this can be overridden to avoid timer issues.
  final VoidCallback? onNavigate;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _backgroundFade = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeIn,
  );
  late final Animation<double> _wordmarkFade = CurvedAnimation(
    parent: _fadeController,
    curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _fadeController.forward();
    Future.delayed(AppConstants.splashDuration, () {
      if (mounted) {
        if (widget.onNavigate != null) {
          widget.onNavigate!();
        } else {
          context.go(AppRoutes.auth);
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _backgroundFade,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ParticleBackground(particleCount: 26),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BreathingLogo(size: 108),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _wordmarkFade,
                    child: Column(
                      children: [
                        Text('FLOODSTORE', style: AppTextStyles.overline(
                          color: AppColors.textSecondary,
                          size: 13,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
