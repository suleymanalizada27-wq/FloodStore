import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/account_mode.dart';

/// A three-way segmented control for [AccountMode]. Used at the top of both
/// [LoginScreen] and [RegisterScreen] — [includeGuest] is turned off on
/// Register since "guest" isn't a thing you sign *up* for.
class AccountModeSelector extends StatelessWidget {
  const AccountModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.includeGuest = true,
  });

  final AccountMode value;
  final ValueChanged<AccountMode> onChanged;
  final bool includeGuest;

  @override
  Widget build(BuildContext context) {
    final modes = [
      AccountMode.individual,
      AccountMode.business,
      if (includeGuest) AccountMode.guest,
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: modes.map((mode) {
          final selected = mode == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(mode),
              child: AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.entrance,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.cardElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: selected
                      ? Border.all(color: AppColors.borderStrong)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  mode.label,
                  style: AppTextStyles.body(
                    size: 13,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
