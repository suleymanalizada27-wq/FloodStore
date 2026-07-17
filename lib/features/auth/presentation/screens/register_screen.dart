import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../application/providers/register_wizard_controller.dart';
import '../../application/state/register_wizard_state.dart';
import '../../domain/entities/account_mode.dart';
import '../../domain/services/password_strength_service.dart';
import '../widgets/auth_helpers.dart';
import '../widgets/auth_shell.dart';
import '../widgets/register_steps/step_account_info.dart';
import '../widgets/register_steps/step_finish.dart';
import '../widgets/register_steps/step_personal_info.dart';
import '../widgets/register_steps/step_security.dart';
import '../widgets/register_steps/step_verification.dart';
import '../widgets/wizard_progress_indicator.dart';

/// A 5-step Register wizard: Personal Information → Account Information →
/// Security → Verification → Finish. Explicitly rebuilt per the brief
/// ("current Register page is too basic... add multi-step account
/// creation") rather than extended — the previous single-form version is
/// superseded entirely by this file. Field widgets themselves
/// (PremiumTextField, CountrySelectField, PasswordStrengthMeter,
/// AccountModeSelector) are all reused, unmodified, from Part 1/2.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _organizationIdController = TextEditingController();
  final _workspaceUrlController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _passwordValue = '';
  bool _draftRestoredToastShown = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyEmailController.dispose();
    _organizationIdController.dispose();
    _workspaceUrlController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _applyStateToControllers(RegisterWizardState state) {
    _firstNameController.text = state.firstName;
    _lastNameController.text = state.lastName;
    _companyNameController.text = state.companyName;
    _usernameController.text = state.username;
    _emailController.text = state.email;
    _phoneController.text = state.phone;
    _companyEmailController.text = state.companyEmail;
    _organizationIdController.text = state.organizationId;
    _workspaceUrlController.text = state.workspaceUrl;
  }

  bool _validateCurrentStep(RegisterWizardStep step) {
    return switch (step) {
      RegisterWizardStep.personalInfo => _step1Key.currentState?.validate() ?? true,
      RegisterWizardStep.accountInfo => _step2Key.currentState?.validate() ?? true,
      RegisterWizardStep.security => _step3Key.currentState?.validate() ?? true,
      RegisterWizardStep.verification => true,
      RegisterWizardStep.finish => true,
    };
  }

  void _syncControllersIntoState(WidgetRef ref) {
    ref.read(registerWizardControllerProvider.notifier).update((s) => s.copyWith(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          companyName: _companyNameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          companyEmail: _companyEmailController.text,
          organizationId: _organizationIdController.text,
          workspaceUrl: _workspaceUrlController.text,
        ));
  }

  Future<void> _handleNext(RegisterWizardState state) async {
    if (!_validateCurrentStep(state.step)) return;
    _syncControllersIntoState(ref);

    if (state.step == RegisterWizardStep.security) {
      if (_passwordController.text != _confirmPasswordController.text) return;
    }

    if (state.step == RegisterWizardStep.verification) {
      if (!state.agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the Terms & Privacy Policy.')),
        );
        return;
      }
      await ref.read(registerWizardControllerProvider.notifier).submit(_passwordController.text);
      return;
    }

    ref.read(registerWizardControllerProvider.notifier).goNext();
  }

  Future<bool> _confirmDiscardIfDirty(RegisterWizardState state) async {
    if (!state.isDirty || state.step == RegisterWizardStep.finish) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Unsaved changes'),
        content: const Text(
          'You have unsaved changes. Save a draft to continue later, or discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(registerWizardControllerProvider.notifier).discardDraft();
              if (context.mounted) Navigator.of(context).pop(true);
            },
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(registerWizardControllerProvider.notifier).saveDraftAndExit();
              if (context.mounted) Navigator.of(context).pop(true);
            },
            child: const Text('Save Draft'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerWizardControllerProvider);

    ref.listen(registerWizardControllerProvider, (previous, next) {
      if (next.draftRestored && !_draftRestoredToastShown) {
        _draftRestoredToastShown = true;
        _applyStateToControllers(next);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Draft restored — pick up where you left off.')),
          );
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscardIfDirty(state);
        if (shouldPop && context.mounted) context.pop();
      },
      child: AuthShell(
        compact: true,
        title: 'Create your account',
        subtitle: state.step.title,
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WizardProgressIndicator(
                currentIndex: state.step.index,
                totalSteps: RegisterWizardStep.values.length,
                stepTitle: state.step.title,
              ),
              const SizedBox(height: 20),
              AuthErrorBanner(message: state.errorMessage),
              AnimatedSwitcher(
                duration: AppMotion.moderate,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0.03, 0), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(state.step),
                  child: _buildStep(state),
                ),
              ),
              const SizedBox(height: 24),
              if (state.step != RegisterWizardStep.finish) ...[
                Row(
                  children: [
                    if (state.step.index > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _syncControllersIntoState(ref);
                            ref.read(registerWizardControllerProvider.notifier).goBack();
                          },
                          child: const Text('Back'),
                        ),
                      ),
                    if (state.step.index > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PremiumButton(
                        label: state.step == RegisterWizardStep.verification
                            ? 'Create Account'
                            : 'Next',
                        loading: state.isSubmitting,
                        onPressed: () => _handleNext(state),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      _syncControllersIntoState(ref);
                      await ref.read(registerWizardControllerProvider.notifier).saveDraftAndExit();
                      if (context.mounted) context.pop();
                    },
                    child: Text(
                      'Continue Later',
                      style: AppTextStyles.body(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(RegisterWizardState state) {
    switch (state.step) {
      case RegisterWizardStep.personalInfo:
        return StepPersonalInfo(
          formKey: _step1Key,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          companyNameController: _companyNameController,
          state: state,
          onAccountModeChanged: (mode) =>
              ref.read(registerWizardControllerProvider.notifier).setAccountMode(mode),
        );
      case RegisterWizardStep.accountInfo:
        return StepAccountInfo(
          formKey: _step2Key,
          usernameController: _usernameController,
          emailController: _emailController,
          phoneController: _phoneController,
          companyEmailController: _companyEmailController,
          organizationIdController: _organizationIdController,
          workspaceUrlController: _workspaceUrlController,
          state: state,
          onCountryChanged: (country) => ref
              .read(registerWizardControllerProvider.notifier)
              .update((s) => s.copyWith(country: country)),
        );
      case RegisterWizardStep.security:
        return StepSecurity(
          formKey: _step3Key,
          passwordController: _passwordController,
          confirmController: _confirmPasswordController,
          passwordValue: _passwordValue,
          obscurePassword: _obscurePassword,
          obscureConfirm: _obscureConfirm,
          onPasswordChanged: (v) => setState(() => _passwordValue = v),
          onToggleObscurePassword: () => setState(() => _obscurePassword = !_obscurePassword),
          onToggleObscureConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
          onGenerate: () {
            final generated = PasswordStrengthService.generateStrongPassword();
            _passwordController.text = generated;
            _confirmPasswordController.text = generated;
            setState(() => _passwordValue = generated);
          },
        );
      case RegisterWizardStep.verification:
        return StepVerification(
          state: state,
          agreeToTerms: state.agreeToTerms,
          onAgreeChanged: (v) => ref
              .read(registerWizardControllerProvider.notifier)
              .update((s) => s.copyWith(agreeToTerms: v)),
        );
      case RegisterWizardStep.finish:
        return StepFinish(
          accountMode: state.accountMode,
          onContinue: () {
            if (state.accountMode.requiresCompanyName) {
              context.go('/auth/organization');
            } else {
              context.go('/auth/verify-email');
            }
          },
        );
    }
  }
}
