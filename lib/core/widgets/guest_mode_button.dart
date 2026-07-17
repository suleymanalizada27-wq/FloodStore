import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// "Continue as Guest" — deliberately styled as a quiet text action rather
/// than another filled/outlined button, so it doesn't visually compete with
/// the primary sign-in CTA or the OAuth provider buttons above it. Guest
/// mode is an escape hatch, not a fourth equally-weighted choice.
class GuestModeButton extends StatelessWidget {
  const GuestModeButton({super.key, required this.onPressed, this.loading = false});

  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.textSecondary),
                ),
              )
            : const Icon(Icons.explore_outlined, size: 16, color: AppColors.textSecondary),
        label: Text(
          'Continue as Guest',
          style: AppTextStyles.body(
            size: 13,
            weight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
