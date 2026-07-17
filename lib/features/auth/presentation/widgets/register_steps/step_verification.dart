import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../application/state/register_wizard_state.dart';

class StepVerification extends StatelessWidget {
  const StepVerification({
    super.key,
    required this.state,
    required this.agreeToTerms,
    required this.onAgreeChanged,
  });

  final RegisterWizardState state;
  final bool agreeToTerms;
  final ValueChanged<bool> onAgreeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Review your details before we create your account.",
          style: AppTextStyles.body(size: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow(label: 'Name', value: '${state.firstName} ${state.lastName}'),
              _SummaryRow(label: 'Account type', value: state.accountMode.label),
              if (state.accountMode.requiresCompanyName)
                _SummaryRow(label: 'Company', value: state.companyName),
              _SummaryRow(label: 'Username', value: state.username),
              _SummaryRow(label: 'Email', value: state.email),
              _SummaryRow(label: 'Phone', value: state.phone),
              _SummaryRow(label: 'Country', value: state.country ?? '—'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "After this, we'll email a verification link to ${state.email.isEmpty ? 'your address' : state.email}.",
          style: AppTextStyles.body(size: 12, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Checkbox(
                value: agreeToTerms,
                onChanged: (v) => onAgreeChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'I agree to the Terms of Service and Privacy Policy.',
                style: AppTextStyles.body(size: 12.5, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: AppTextStyles.body(size: 12, color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.body(size: 12.5, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
