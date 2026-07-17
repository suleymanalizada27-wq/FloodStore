import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_motion.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/premium_button.dart';
import '../../../domain/entities/account_mode.dart';

class StepFinish extends StatelessWidget {
  const StepFinish({
    super.key,
    required this.accountMode,
    required this.onContinue,
  });

  final AccountMode accountMode;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppMotion.slow,
            curve: AppMotion.spring,
            builder: (context, value, child) => Transform.scale(scale: value, child: child),
            child: Container(
              height: 72,
              width: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text('Account created!', style: AppTextStyles.headlineMedium),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            accountMode.requiresCompanyName
                ? "Next, let's set up your organization."
                : "We've sent a verification link to your email.",
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 13, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 26),
        PremiumButton(
          label: accountMode.requiresCompanyName ? 'Set Up Organization' : 'Verify Email',
          onPressed: onContinue,
        ),
      ],
    );
  }
}
