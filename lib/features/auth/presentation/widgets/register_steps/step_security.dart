import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/premium_text_field.dart';
import '../../../domain/services/password_strength_service.dart';
import '../password_requirements_checklist.dart';
import '../password_strength_meter.dart';

class StepSecurity extends StatelessWidget {
  const StepSecurity({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmController,
    required this.passwordValue,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onPasswordChanged,
    required this.onToggleObscurePassword,
    required this.onToggleObscureConfirm,
    required this.onGenerate,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String passwordValue;
  final bool obscurePassword;
  final bool obscureConfirm;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onToggleObscureConfirm;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumTextField(
            label: 'Password',
            controller: passwordController,
            hint: 'At least 8 characters',
            obscureText: obscurePassword,
            prefixIcon: Icons.lock_outline_rounded,
            onChanged: onPasswordChanged,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
              onPressed: onToggleObscurePassword,
            ),
            validator: (v) {
              if (PasswordStrengthService.isObviouslyCommon(v ?? '')) {
                return 'This password is too common — choose another';
              }
              return (v ?? '').length < 8 ? 'Minimum 8 characters' : null;
            },
          ),
          PasswordStrengthMeter(password: passwordValue),
          PasswordRequirementsChecklist(password: passwordValue),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome_rounded, size: 16),
              label: const Text('Generate a strong password'),
            ),
          ),
          const SizedBox(height: 8),
          PremiumTextField(
            label: 'Confirm Password',
            controller: confirmController,
            hint: 'Re-enter your password',
            obscureText: obscureConfirm,
            prefixIcon: Icons.lock_outline_rounded,
            onChanged: (_) {},
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
              onPressed: onToggleObscureConfirm,
            ),
            validator: (v) =>
                v != passwordController.text ? 'Passwords do not match' : null,
          ),
        ],
      ),
    );
  }
}
