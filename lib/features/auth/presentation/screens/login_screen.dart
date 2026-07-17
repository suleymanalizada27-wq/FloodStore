import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/guest_mode_button.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_text_field.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../../application/providers/auth_controllers.dart';
import '../../application/providers/auth_providers.dart';
import '../../application/providers/session_providers.dart';
import '../../domain/entities/account_mode.dart';
import '../widgets/account_mode_selector.dart';
import '../widgets/auth_helpers.dart';
import '../widgets/auth_shell.dart';
import '../widgets/premium_login_options.dart';
import '../widgets/recent_account_card.dart';
import '../widgets/security_banners.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _keepSignedIn = false;
  bool _prefilledEmail = false;
  bool _dismissedRecentAccount = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(loginControllerProvider.notifier).signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
  }

  Future<void> _persistSessionPreferences() async {
    final session = ref.read(sessionServiceProvider);
    await session.setRememberedIdentifier(
      _rememberMe ? _emailController.text.trim() : null,
    );
    if (_rememberMe) {
      await session.setRememberedDisplayName(
        ref.read(authRepositoryProvider).currentUser?.displayName,
      );
    }
    await session.setKeepSignedIn(_keepSignedIn);
    if (_keepSignedIn) await session.touchActivity();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginControllerProvider);
    final accountMode = ref.watch(accountModeProvider);

    final rememberedEmail = ref.watch(rememberedIdentifierProvider).valueOrNull;
    if (!_prefilledEmail && rememberedEmail != null && rememberedEmail.isNotEmpty) {
      _emailController.text = rememberedEmail;
      _prefilledEmail = true;
    }

    ref.listen(loginControllerProvider, (previous, next) {
      if (next.succeeded && previous?.succeeded != true) {
        _persistSessionPreferences();
      }
    });

    final recentAccount = ref.watch(recentAccountProvider).valueOrNull;

    return AuthShell(
      child: GlassCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (recentAccount != null && !_dismissedRecentAccount)
                RecentAccountCard(
                  identifier: recentAccount.identifier,
                  displayName: recentAccount.displayName,
                  onContinue: () {
                    setState(() {
                      _emailController.text = recentAccount.identifier;
                      _prefilledEmail = true;
                      _dismissedRecentAccount = true;
                    });
                  },
                  onNotYou: () async {
                    await ref
                        .read(sessionServiceProvider)
                        .setRememberedIdentifier(null);
                    ref.invalidate(recentAccountProvider);
                    setState(() => _dismissedRecentAccount = true);
                  },
                ),
              AccountModeSelector(
                value: accountMode,
                onChanged: (mode) =>
                    ref.read(accountModeProvider.notifier).state = mode,
              ),
              const SizedBox(height: 20),
              AccountLockBanner(
                lockedUntil: formState.isLocked ? formState.lockedUntil : null,
              ),
              if (!formState.isLocked)
                RateLimitBanner(attemptsRemaining: formState.attemptsRemaining),
              AuthErrorBanner(message: formState.isLocked ? null : formState.errorMessage),
              Text('Welcome back', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 4),
              Text(
                accountMode.loginSubtitle,
                style: AppTextStyles.body(
                  size: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              PremiumTextField(
                label: 'Email',
                controller: _emailController,
                hint: 'you@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Enter your email';
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              PremiumTextField(
                label: 'Password',
                controller: _passwordController,
                hint: '••••••••',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) return 'Enter your password';
                  return null;
                },
                onChanged: (_) {},
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Semantics(
                    label: 'Remember me',
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: AppTextStyles.body(
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Semantics(
                    label: 'Keep me signed in on this device',
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: Checkbox(
                        value: _keepSignedIn,
                        onChanged: (v) =>
                            setState(() => _keepSignedIn = v ?? false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep me signed in on this device',
                      style: AppTextStyles.body(
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              PremiumButton(
                label: 'Sign In',
                loading: formState.isSubmitting,
                onPressed: formState.isLocked ? null : _submit,
              ),
              const SizedBox(height: 26),
              const OrDivider(),
              const SizedBox(height: 18),
              // Social auth buttons
              SocialAuthButton(
                provider: SocialProvider.google,
                onPressed: () =>
                    ref.read(loginControllerProvider.notifier).signInWithGoogle(),
              ),
              const SizedBox(height: 12),
              SocialAuthButton(
                provider: SocialProvider.apple,
                onPressed: () =>
                    ref.read(loginControllerProvider.notifier).signInWithApple(),
              ),
              const SizedBox(height: 12),
              SocialAuthButton(
                provider: SocialProvider.microsoft,
                onPressed: () => ref
                    .read(loginControllerProvider.notifier)
                    .signInWithMicrosoft(),
              ),
              const SizedBox(height: 12),
              SocialAuthButton(
                provider: SocialProvider.github,
                onPressed: () =>
                    ref.read(loginControllerProvider.notifier).signInWithGithub(),
              ),
              const SizedBox(height: 12),
              SocialAuthButton(
                provider: SocialProvider.phone,
                onPressed: () =>
                    context.push(AppRoutes.phoneAuth),
              ),
              const SizedBox(height: 12),
              // Magic link button (passwordless email sign‑in)
              IconButton(
                icon: Icon(
                  Icons.email_outlined,
                  size: 28,
                  color: AppColors.secondary,
                ),
                tooltip: 'Send magic link to email',
                onPressed: (_emailController.text.isEmpty)
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(authRepositoryProvider)
                              .sendMagicLink(_emailController.text.trim());
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Magic link sent! Check your inbox.'),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to send link: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
              ),
              const SizedBox(width: 12),
              // Biometric info button (not for login, but to check availability and explain)
              IconButton(
                icon: Icon(
                  Icons.fingerprint,
                  size: 28,
                  color: AppColors.secondary,
                ),
                tooltip: 'Biometric info',
                onPressed: () async {
                  final isAvailable =
                      await ref.read(authRepositoryProvider).isBiometricAvailable();
                  final currentUser =
                      ref.read(authRepositoryProvider).currentUser;
                  if (!mounted) return;
                  if (!isAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Biometric authentication is not available on this device.'),
                      ),
                    );
                    return;
                  }
                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please sign in with email or social first to enable biometric unlock.'),
                      ),
                    );
                    return;
                  }
                  // Show a dialog to confirm biometric check
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Biometric Verification'),
                      content: const Text(
                          'Press OK to verify your identity with biometrics.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              await ref
                                  .read(authRepositoryProvider.notifier)
                                  .signInWithBiometrics();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Biometric verification successful.'),
                                ),
                              );
                            } on AuthFailure catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.message),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          child: const Text('Verify'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              const OrDivider(),
              const SizedBox(height: 18),
              const PremiumLoginOptions(),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTextStyles.body(
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.register),
                    child: Text(
                      'Create Account',
                      style: AppTextStyles.body(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}