import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_text_field.dart';
import '../../application/providers/password_reset_controller.dart';
import '../../application/state/password_reset_state.dart';
import '../../domain/services/password_strength_service.dart';
import '../widgets/auth_helpers.dart';
import '../widgets/auth_shell.dart';
import '../widgets/password_requirements_checklist.dart';
import '../widgets/password_strength_meter.dart';

/// The complete password recovery experience:
/// Forgot Password → Email Sent → Verification Code → New Password → Success.
///
/// Explicitly rebuilt per the brief ("replace it with a complete recovery
/// flow") rather than extended — the previous single-field version is
/// superseded entirely by this file.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _passwordValue = '';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetControllerProvider);
    final notifier = ref.read(passwordResetControllerProvider.notifier);

    return AuthShell(
      compact: true,
      title: _titleFor(state.step),
      subtitle: _subtitleFor(state.step),
      child: GlassCard(
        child: AnimatedSwitcher(
          duration: AppMotion.moderate,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0.04, 0), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
          ),
          child: switch (state.step) {
            PasswordResetStep.enterEmail => _EnterEmailStep(
                key: const ValueKey('enterEmail'),
                formKey: _formKey,
                controller: _emailController,
                state: state,
                onSubmit: () {
                  if (_formKey.currentState!.validate()) {
                    notifier.sendResetEmail(_emailController.text);
                  }
                },
              ),
            PasswordResetStep.emailSent => _EmailSentStep(
                key: const ValueKey('emailSent'),
                email: state.email ?? '',
                state: state,
                onResend: notifier.resend,
                onHaveCode: notifier.proceedToEnterCode,
              ),
            PasswordResetStep.enterCode => _EnterCodeStep(
                key: const ValueKey('enterCode'),
                controller: _codeController,
                state: state,
                onSubmit: () => notifier.verifyCode(_codeController.text),
              ),
            PasswordResetStep.newPassword => _NewPasswordStep(
                key: const ValueKey('newPassword'),
                passwordController: _newPasswordController,
                confirmController: _confirmPasswordController,
                passwordValue: _passwordValue,
                obscure: _obscurePassword,
                state: state,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                onPasswordChanged: (v) => setState(() => _passwordValue = v),
                onGenerate: () {
                  final generated = PasswordStrengthService.generateStrongPassword();
                  _newPasswordController.text = generated;
                  _confirmPasswordController.text = generated;
                  setState(() => _passwordValue = generated);
                },
                onSubmit: () {
                  if (_newPasswordController.text != _confirmPasswordController.text) return;
                  notifier.submitNewPassword(_newPasswordController.text);
                },
              ),
            PasswordResetStep.success => const _SuccessStep(key: ValueKey('success')),
          },
        ),
      ),
    );
  }

  String _titleFor(PasswordResetStep step) => switch (step) {
        PasswordResetStep.enterEmail => 'Reset your password',
        PasswordResetStep.emailSent => 'Check your inbox',
        PasswordResetStep.enterCode => 'Enter your code',
        PasswordResetStep.newPassword => 'Create a new password',
        PasswordResetStep.success => 'All set',
      };

  String _subtitleFor(PasswordResetStep step) => switch (step) {
        PasswordResetStep.enterEmail => "We'll email you a secure link to get back in.",
        PasswordResetStep.emailSent => "It may take a minute to arrive.",
        PasswordResetStep.enterCode => 'Paste the code from the link in your email.',
        PasswordResetStep.newPassword => 'Make it something you have not used before.',
        PasswordResetStep.success => 'Your password has been updated.',
      };
}

class _EnterEmailStep extends StatelessWidget {
  const _EnterEmailStep({
    super.key,
    required this.formKey,
    required this.controller,
    required this.state,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final PasswordResetState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthErrorBanner(message: state.errorMessage),
          PremiumTextField(
            label: 'Email',
            controller: controller,
            hint: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Enter your email';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 24),
          PremiumButton(label: 'Send Reset Link', loading: state.isSubmitting, onPressed: onSubmit),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to Sign In'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailSentStep extends StatelessWidget {
  const _EmailSentStep({
    super.key,
    required this.email,
    required this.state,
    required this.onResend,
    required this.onHaveCode,
  });

  final String email;
  final PasswordResetState state;
  final VoidCallback onResend;
  final VoidCallback onHaveCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthErrorBanner(message: state.errorMessage),
        Container(
          height: 56,
          width: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 26),
        ),
        const SizedBox(height: 18),
        Text(
          'We sent a password reset link to $email.',
          style: AppTextStyles.body(size: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          'Requests used: ${state.attemptCount}/5',
          style: AppTextStyles.body(size: 11.5, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 22),
        PremiumButton(label: 'I have my code', onPressed: onHaveCode),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: state.canResend ? onResend : null,
            child: Text(
              state.canResend ? 'Resend email' : 'You can resend shortly',
              style: AppTextStyles.body(
                size: 13,
                weight: FontWeight.w600,
                color: state.canResend ? AppColors.secondary : AppColors.textTertiary,
              ),
            ),
          ),
        ),
        Center(
          child: TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Back to Sign In'),
          ),
        ),
      ],
    );
  }
}

class _EnterCodeStep extends StatelessWidget {
  const _EnterCodeStep({
    super.key,
    required this.controller,
    required this.state,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final PasswordResetState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthErrorBanner(message: state.errorMessage),
        PremiumTextField(
          label: 'Verification Code',
          controller: controller,
          hint: 'Paste the code from your email',
          prefixIcon: Icons.vpn_key_outlined,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),
        Text(
          "Open the email and paste the code from the reset link's \"oobCode\" "
          'parameter — or tap the link directly if your device has FloodStore installed.',
          style: AppTextStyles.body(size: 11.5, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 22),
        PremiumButton(label: 'Verify Code', loading: state.isSubmitting, onPressed: onSubmit),
      ],
    );
  }
}

class _NewPasswordStep extends StatelessWidget {
  const _NewPasswordStep({
    super.key,
    required this.passwordController,
    required this.confirmController,
    required this.passwordValue,
    required this.obscure,
    required this.state,
    required this.onToggleObscure,
    required this.onPasswordChanged,
    required this.onGenerate,
    required this.onSubmit,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String passwordValue;
  final bool obscure;
  final PasswordResetState state;
  final VoidCallback onToggleObscure;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onGenerate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final passwordsMatch =
        confirmController.text.isEmpty || confirmController.text == passwordController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthErrorBanner(message: state.errorMessage),
        PremiumTextField(
          label: 'New Password',
          controller: passwordController,
          hint: 'At least 8 characters',
          obscureText: obscure,
          prefixIcon: Icons.lock_outline_rounded,
          onChanged: onPasswordChanged,
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: AppColors.textTertiary,
            ),
            onPressed: onToggleObscure,
          ),
        ),
        PasswordStrengthMeter(password: passwordValue),
        PasswordRequirementsChecklist(password: passwordValue),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: const Text('Generate a strong password'),
          ),
        ),
        const SizedBox(height: 10),
        PremiumTextField(
          label: 'Confirm New Password',
          controller: confirmController,
          hint: 'Re-enter your password',
          obscureText: obscure,
          prefixIcon: Icons.lock_outline_rounded,
          onChanged: (_) {},
        ),
        if (!passwordsMatch)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Passwords do not match',
              style: AppTextStyles.body(size: 12, color: AppColors.error),
            ),
          ),
        const SizedBox(height: 22),
        PremiumButton(
          label: 'Reset Password',
          loading: state.isSubmitting,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _SuccessStep extends ConsumerWidget {
  const _SuccessStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.slow,
          curve: AppMotion.spring,
          builder: (context, value, child) => Transform.scale(scale: value, child: child),
          child: Container(
            height: 64,
            width: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.success, size: 32),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'Your password has been reset.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 13, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 22),
        PremiumButton(
          label: 'Back to Sign In',
          onPressed: () {
            ref.read(passwordResetControllerProvider.notifier).reset();
            context.go('/auth');
          },
        ),
      ],
    );
  }
}
