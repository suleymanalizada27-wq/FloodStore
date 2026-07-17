import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/premium_text_field.dart';
import '../../../application/state/register_wizard_state.dart';
import '../../../domain/entities/account_mode.dart';
import '../country_select_field.dart';

class StepAccountInfo extends StatelessWidget {
  const StepAccountInfo({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.phoneController,
    required this.companyEmailController,
    required this.organizationIdController,
    required this.workspaceUrlController,
    required this.state,
    required this.onCountryChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController companyEmailController;
  final TextEditingController organizationIdController;
  final TextEditingController workspaceUrlController;
  final RegisterWizardState state;
  final ValueChanged<String> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    final isBusiness = state.accountMode == AccountMode.business;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumTextField(
            label: 'Username',
            controller: usernameController,
            hint: 'janedoe',
            prefixIcon: Icons.alternate_email_rounded,
            validator: (v) => (v ?? '').trim().length < 3 ? 'At least 3 characters' : null,
          ),
          const SizedBox(height: 18),
          PremiumTextField(
            label: 'Email',
            controller: emailController,
            hint: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty || !value.contains('@') || !value.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          PremiumTextField(
            label: 'Phone',
            controller: phoneController,
            hint: '+1 555 000 0000',
            prefixIcon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
            validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 18),
          CountrySelectField(value: state.country, onChanged: onCountryChanged),
          if (isBusiness) ...[
            const SizedBox(height: 22),
            Text(
              'Company Details',
              style: AppTextStyles.body(size: 12, weight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            PremiumTextField(
              label: 'Company Email',
              controller: companyEmailController,
              hint: 'you@company.com',
              prefixIcon: Icons.business_center_outlined,
              validator: (v) {
                if (!isBusiness) return null;
                final value = (v ?? '').trim();
                if (value.isEmpty || !value.contains('@')) return 'Enter your company email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            PremiumTextField(
              label: 'Organization ID (optional)',
              controller: organizationIdController,
              hint: 'If you already have one',
              prefixIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: 14),
            PremiumTextField(
              label: 'Workspace URL (optional)',
              controller: workspaceUrlController,
              hint: 'acme',
              prefixIcon: Icons.link_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
