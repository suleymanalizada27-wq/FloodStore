import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// An inline, dismissible-feeling error banner shown at the top of a form
/// when a submission fails. Animates in/out with the rest of the form
/// rather than popping a snackbar over the glass card.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: message == null
          ? const SizedBox.shrink(key: ValueKey('no-error'))
          : Container(
              key: ValueKey(message),
              margin: const EdgeInsets.only(bottom: 20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message!,
                      style: AppTextStyles.body(
                        size: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// A horizontal "── or continue with ──" style divider used above the
/// social auth buttons.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = 'or continue with'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: AppTextStyles.body(size: 12, color: AppColors.textTertiary),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
