import 'package:flutter/material.dart';

import '../../../../../core/widgets/premium_text_field.dart';
import '../../../application/state/register_wizard_state.dart';
import '../../../domain/entities/account_mode.dart';
import '../account_mode_selector.dart';

class StepPersonalInfo extends StatelessWidget {
  const StepPersonalInfo({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.companyNameController,
    required this.state,
    required this.onAccountModeChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController companyNameController;
  final RegisterWizardState state;
  final ValueChanged<AccountMode> onAccountModeChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccountModeSelector(
            value: state.accountMode,
            includeGuest: false,
            onChanged: onAccountModeChanged,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PremiumTextField(
                  label: 'First Name',
                  controller: firstNameController,
                  hint: 'Jane',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: PremiumTextField(
                  label: 'Last Name',
                  controller: lastNameController,
                  hint: 'Doe',
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          if (state.accountMode.requiresCompanyName) ...[
            const SizedBox(height: 18),
            PremiumTextField(
              label: 'Company Name',
              controller: companyNameController,
              hint: 'Acme Corp',
              prefixIcon: Icons.apartment_rounded,
              validator: (v) => state.accountMode.requiresCompanyName && (v ?? '').trim().isEmpty
                  ? 'Enter your company name'
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
