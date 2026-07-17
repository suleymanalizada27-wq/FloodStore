import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/breathing_logo.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/particle_background.dart';

/// The common scaffold every auth screen sits inside: ambient particle
/// backdrop, breathing logo, wordmark + tagline, then a scrollable,
/// width-constrained content column so the same layout reads correctly on
/// phone, tablet and desktop alike.
///
/// [compact] shrinks the hero (used on Register/Forgot Password so the
/// form itself gets more room) while still keeping a consistent brand
/// presence across every screen.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.title = 'FloodStore',
    this.subtitle = 'Everything Starts Here.',
    this.compact = false,
  });

  final Widget child;
  final String title;
  final String subtitle;
  final bool compact;

  static const double _maxContentWidth = 440;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 56.0 : 92.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ParticleBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 64,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _maxContentWidth),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FadeSlideIn(
                              child: Center(
                                child: BreathingLogo(size: logoSize),
                              ),
                            ),
                            SizedBox(height: compact ? 16 : 24),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 80),
                              child: Center(
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: (compact
                                          ? AppTextStyles.headlineLarge
                                          : AppTextStyles.display(size: 34))
                                      .copyWith(letterSpacing: -0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 140),
                              child: Center(
                                child: Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body(
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 28 : 36),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 200),
                              child: child,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
