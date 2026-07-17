import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A labeled, animated step bar — "Step 2 of 5 · Account Information" plus
/// a segmented progress track. Generic over step count so it isn't
/// Register-specific, even though Register's 5-step wizard is its first
/// use.
class WizardProgressIndicator extends StatelessWidget {
  const WizardProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    required this.stepTitle,
  });

  final int currentIndex;
  final int totalSteps;
  final String stepTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentIndex + 1} of $totalSteps',
              style: AppTextStyles.body(size: 11.5, weight: FontWeight.w600, color: AppColors.textTertiary),
            ),
            Text(
              stepTitle,
              style: AppTextStyles.body(size: 11.5, weight: FontWeight.w600, color: AppColors.secondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(totalSteps, (i) {
            final filled = i <= currentIndex;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 4),
                child: AnimatedContainer(
                  duration: AppMotion.base,
                  curve: AppMotion.entrance,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: filled ? AppColors.brandGradient : null,
                    color: filled ? null : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
