import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/services/password_strength_service.dart';

/// A thin, segmented strength bar shown under the password field on
/// Register. Purely reactive — the screen owns the [TextEditingController]
/// and passes the latest raw password in on every keystroke; this widget
/// never reads the controller itself, so it stays trivially testable.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  Color _colorFor(PasswordStrength strength) => switch (strength) {
        PasswordStrength.empty => AppColors.textTertiary,
        PasswordStrength.weak => AppColors.error,
        PasswordStrength.fair => AppColors.warning,
        PasswordStrength.good => AppColors.info,
        PasswordStrength.strong => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final strength = PasswordStrengthService.score(password);
    final hint = PasswordStrengthService.nextHint(password);
    final color = _colorFor(strength);

    if (password.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (index) {
              final filled = strength.fraction * 4 > index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == 3 ? 0 : AppSpacing.xs,
                  ),
                  child: AnimatedContainer(
                    duration: AppMotion.base,
                    curve: AppMotion.entrance,
                    height: 4,
                    decoration: BoxDecoration(
                      color: filled ? color : AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Text(
              hint ?? strength.label,
              key: ValueKey('${strength.name}-${hint ?? ''}'),
              style: AppTextStyles.body(size: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
