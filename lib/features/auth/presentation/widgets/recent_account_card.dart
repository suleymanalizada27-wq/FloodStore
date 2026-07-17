import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shown above the sign-in form when [SessionService] has a remembered
/// identity — "One Tap Login / Quick Login / Continue as Previous User"
/// from the brief, scoped to what's actually safe to do without a stored
/// credential: pre-fill the identity and focus the password field, not a
/// truly silent sign-in (Firebase never hands this app a reusable
/// password, by design).
class RecentAccountCard extends StatelessWidget {
  const RecentAccountCard({
    super.key,
    required this.identifier,
    this.displayName,
    required this.onContinue,
    required this.onNotYou,
  });

  final String identifier;
  final String? displayName;
  final VoidCallback onContinue;
  final VoidCallback onNotYou;

  @override
  Widget build(BuildContext context) {
    final label = (displayName != null && displayName!.isNotEmpty) ? displayName! : identifier;
    final initial = label.isNotEmpty ? label[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.cardElevated,
            child: Text(initial, style: AppTextStyles.body(size: 14, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, $label', style: AppTextStyles.body(size: 13, weight: FontWeight.w700)),
                Text(
                  'Continue with $identifier',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(size: 11.5, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
          IconButton(
            iconSize: 16,
            icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
            onPressed: onNotYou,
          ),
        ],
      ),
    );
  }
}
