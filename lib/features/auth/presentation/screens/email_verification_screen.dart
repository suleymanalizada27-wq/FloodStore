import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_text_field.dart';
import '../../application/providers/auth_controllers.dart';
import '../../application/providers/auth_providers.dart';
import '../widgets/auth_helpers.dart';
import '../widgets/auth_shell.dart';

/// Reached automatically by the router's redirect guard whenever a signed
/// in, email/password user has `emailVerified == false`. Also reachable by
/// pushing `/auth/verify-email` directly (e.g. right after Register).
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Poll in the background so the moment the user clicks the emailed
    // link, this screen moves on by itself — no manual "I've verified"
    // click required, though that button still exists below for anyone who
    // wants the instant path.
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.read(emailVerificationControllerProvider.notifier).checkVerified();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Best-effort deep link into a mail client. Falls back silently (no
  /// error shown) if the scheme isn't handled on this device — there's no
  /// reliable cross-platform way to detect "app not installed" before
  /// attempting the launch, and a launch failure here is low-stakes: the
  /// user just stays on this screen and can check their inbox manually.
  Future<void> _openMailApp(String scheme) async {
    final uri = Uri.parse(scheme);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (scheme != 'message://') {
      // Generic fallback: the platform's registered handler for `mailto:`.
      await launchUrl(Uri.parse('mailto:'), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showChangeEmailDialog() async {
    final controller = TextEditingController(
      text: ref.read(authRepositoryProvider).currentUser?.email ?? '',
    );
    final newEmail = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Change email'),
        content: PremiumTextField(
          label: 'New email',
          controller: controller,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Send Verification'),
          ),
        ],
      ),
    );
    if (newEmail == null || newEmail.isEmpty || !mounted) return;
    try {
      await ref.read(authRepositoryProvider).updateEmail(newEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification link sent to $newEmail.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update email. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailVerificationControllerProvider);
    final email = ref.watch(authRepositoryProvider).currentUser?.email ?? 'your email';

    ref.listen(emailVerificationControllerProvider, (previous, next) {
      if (next.isVerified && previous?.isVerified != true) {
        // Router redirect will take it from here once
        // authStateChangesProvider's next emission reflects it, but we
        // don't wait on that — reloadCurrentUser() already updated the
        // repository's view, so nudge navigation directly too.
        context.go('/home');
      }
    });

    return AuthShell(
      compact: true,
      title: 'Verify your email',
      subtitle: "We're just waiting on one click.",
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthErrorBanner(message: state.errorMessage),
            Container(
              height: 56,
              width: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.info,
                size: 26,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              state.justSent ? 'Verification email sent' : 'Check your inbox',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a verification link to $email. Click it, then come back '
              'here — this screen updates automatically.',
              style: AppTextStyles.body(size: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _MailAppChip(label: 'Gmail', onTap: () => _openMailApp('googlegmail://')),
                _MailAppChip(label: 'Outlook', onTap: () => _openMailApp('ms-outlook://')),
                _MailAppChip(label: 'Apple Mail', onTap: () => _openMailApp('message://')),
                _MailAppChip(label: 'Mail App', onTap: () => _openMailApp('mailto:')),
              ],
            ),
            const SizedBox(height: 20),
            PremiumButton(
              label: state.canResend ? 'Resend Email' : 'Sent — you can resend shortly',
              loading: state.isSending,
              onPressed: state.canResend
                  ? () => ref
                      .read(emailVerificationControllerProvider.notifier)
                      .sendVerification()
                  : null,
            ),
            const SizedBox(height: 14),
            PremiumButton(
              label: "I've verified my email",
              loading: state.isChecking,
              expand: true,
              onPressed: () =>
                  ref.read(emailVerificationControllerProvider.notifier).checkVerified(),
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: _showChangeEmailDialog,
                child: Text(
                  'Change email',
                  style: AppTextStyles.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/auth');
                },
                child: Text(
                  'Sign in with a different account',
                  style: AppTextStyles.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MailAppChip extends StatelessWidget {
  const _MailAppChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(size: 12, weight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
