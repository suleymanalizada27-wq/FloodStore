import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/otp_code_field.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_text_field.dart';
import '../../application/providers/auth_controllers.dart';
import '../../application/providers/auth_providers.dart';
import '../../application/state/auth_flow_states.dart';
import '../widgets/auth_helpers.dart';
import '../widgets/auth_shell.dart';

/// Reached from the "Continue with Phone" button on [LoginScreen]. Two-step
/// flow inside one screen (rather than two routes) so the OTP step keeps
/// the phone number visible in context and back-navigation is a single tap.
class PhoneOtpScreen extends ConsumerStatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _codeError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(phoneAuthControllerProvider.notifier).sendCode(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneAuthControllerProvider);

    ref.listen(phoneAuthControllerProvider, (previous, next) {
      if (next.step == PhoneAuthStep.enterCode && next.errorMessage != null) {
        setState(() => _codeError = next.errorMessage);
      }
    });

    return AuthShell(
      compact: true,
      title: state.step == PhoneAuthStep.enterNumber
          ? 'Sign in with phone'
          : 'Enter your code',
      subtitle: state.step == PhoneAuthStep.enterNumber
          ? "We'll text you a one-time verification code."
          : 'Sent to ${_phoneController.text}',
      child: GlassCard(
        child: state.step == PhoneAuthStep.enterNumber
            ? _NumberStep(
                formKey: _formKey,
                controller: _phoneController,
                loading: state.isSubmitting,
                errorMessage: state.errorMessage,
                onSubmit: _sendCode,
              )
            : _CodeStep(
                loading: state.isSubmitting || state.step == PhoneAuthStep.verifying,
                errorText: _codeError,
                canResend: state.canResend,
                onCompleted: (code) {
                  setState(() => _codeError = null);
                  ref.read(phoneAuthControllerProvider.notifier).verifyCode(code);
                },
                onResend: () {
                  setState(() => _codeError = null);
                  ref
                      .read(phoneAuthControllerProvider.notifier)
                      .resendCode(_phoneController.text);
                },
                onRequestCall: () {
                  ref
                      .read(authRepositoryProvider)
                      .requestVoiceCall(_phoneController.text)
                      .catchError((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Voice call delivery isn't available yet — please use the SMS code."),
                        ),
                      );
                    }
                  });
                },
              ),
      ),
    );
  }
}

class _NumberStep extends StatelessWidget {
  const _NumberStep({
    required this.formKey,
    required this.controller,
    required this.loading,
    required this.errorMessage,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthErrorBanner(message: errorMessage),
          PremiumTextField(
            label: 'Phone number',
            controller: controller,
            hint: '+1 (555) 000-0000',
            prefixIcon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Enter your phone number';
              if (!RegExp(r'^\+?[0-9\s\-()]{7,}$').hasMatch(value)) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          PremiumButton(label: 'Send Code', loading: loading, onPressed: onSubmit),
          const SizedBox(height: 18),
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

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.loading,
    required this.errorText,
    required this.canResend,
    required this.onCompleted,
    required this.onResend,
    required this.onRequestCall,
  });

  final bool loading;
  final String? errorText;
  final bool canResend;
  final ValueChanged<String> onCompleted;
  final VoidCallback onResend;
  final VoidCallback onRequestCall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthErrorBanner(message: errorText),
        Center(
          child: OtpCodeField(onCompleted: onCompleted, errorText: errorText),
        ),
        const SizedBox(height: 22),
        if (loading)
          const Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation(AppColors.secondary),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: canResend ? onResend : null,
            child: Text(
              canResend ? "Didn't get a code? Resend" : 'Resend available shortly',
              style: AppTextStyles.body(
                size: 13,
                weight: FontWeight.w600,
                color: canResend ? AppColors.secondary : AppColors.textTertiary,
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: onRequestCall,
            child: Text(
              'Call me instead',
              style: AppTextStyles.body(size: 12.5, color: AppColors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }
}
