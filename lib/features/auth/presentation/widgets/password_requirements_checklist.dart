import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/services/password_strength_service.dart';

/// Renders every [PasswordStrengthService.requirements] rule with a live
/// checkmark — the "Password requirements checklist... Live updates" item.
/// Sits alongside (not instead of) [PasswordStrengthMeter]: the meter
/// answers "how strong overall", this answers "what specifically is
/// missing".
class PasswordRequirementsChecklist extends StatelessWidget {
  const PasswordRequirementsChecklist({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final requirements = PasswordStrengthService.requirements(password);
    final entropy = PasswordStrengthService.entropyBits(password);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...requirements.map((r) => _RequirementRow(requirement: r)),
          if (password.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Entropy: ~${entropy.round()} bits',
              style: AppTextStyles.body(size: 11, color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.requirement});
  final PasswordRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final color = requirement.isMet ? AppColors.success : AppColors.textTertiary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Icon(
              requirement.isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
              key: ValueKey(requirement.isMet),
              size: 14,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(requirement.label, style: AppTextStyles.body(size: 12, color: color)),
        ],
      ),
    );
  }
}
