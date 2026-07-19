import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_text_field.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../../application/providers/auth_providers.dart';
import '../widgets/auth_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Show error - fields required
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Sign in successful - will be handled by auth state listener
    } catch (e) {
      // Show error - will be handled by error handling in repository
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authRepositoryProvider).signInWithGoogle();
  }

  Future<void> _signInWithApple() async {
    await ref.read(authRepositoryProvider).signInWithApple();
  }

  Future<void> _signInAsGuest() async {
    await ref.read(authRepositoryProvider).signInAsGuest();
  }

  void _handleSocialPress(Future<void> Function() action) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Email field
              PremiumTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password field
              PremiumTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 24),

              // Login button
              PremiumButton(
                label: 'Sign In',
                loading: _isLoading,
                onPressed: _isLoading ? null : _signInWithEmail,
                expand: true,
              ),
              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: AppTextStyles.body(
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Social buttons
              SocialAuthButton(
                provider: SocialProvider.google,
                onPressed: () => _handleSocialPress(_signInWithGoogle),
              ),
              const SizedBox(height: 12),
              SocialAuthButton(
                provider: SocialProvider.apple,
                onPressed: () => _handleSocialPress(_signInWithApple),
              ),
              const SizedBox(height: 12),
              SocialAuthButton(
                provider: SocialProvider.phone,
                onPressed: () => context.push(AppRoutes.phoneAuth),
              ),
              const SizedBox(height: 24),

              // Forgot password / Create account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () =>
                        context.push(AppRoutes.forgotPassword),
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.body(
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Text(' | ',
                      style: TextStyle(color: AppColors.border)),
                  TextButton(
                    onPressed: () =>
                        context.push(AppRoutes.register),
                    child: Text(
                      'Create Account',
                      style: AppTextStyles.body(
                        size: 13,
                        color: AppColors.textSecondary,
                        weight: FontWeight.w600,
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