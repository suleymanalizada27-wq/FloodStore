import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/providers/auth_providers.dart';

/// "Premium Login Experience" row: Magic Link is real (Firebase email-link
/// auth); Passkeys/Biometric/QR are shown as disabled chips rather than
/// hidden entirely, so the surface area the brief asked for is visible and
/// honestly labeled instead of silently missing. See AuthRepository for
/// why each of those three isn't wired yet.
class PremiumLoginOptions extends ConsumerStatefulWidget {
  const PremiumLoginOptions({super.key});

  @override
  ConsumerState<PremiumLoginOptions> createState() => _PremiumLoginOptionsState();
}

class _PremiumLoginOptionsState extends ConsumerState<PremiumLoginOptions> {
  bool _sending = false;
  bool _sent = false;

  Future<void> _sendMagicLink() async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign in with Magic Link'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'you@example.com'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty || !mounted) return;

    setState(() => _sending = true);
    try {
      await ref.read(authRepositoryProvider).sendMagicLink(email);
      if (mounted) setState(() { _sending = false; _sent = true; });
    } catch (_) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send the magic link. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OptionTile(
          icon: Icons.bolt_rounded,
          label: _sent ? 'Magic link sent — check your inbox' : 'Sign in with Magic Link',
          loading: _sending,
          onTap: _sent ? null : _sendMagicLink,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _ComingSoonChip(icon: Icons.fingerprint_rounded, label: 'Biometric')),
            const SizedBox(width: 8),
            Expanded(child: _ComingSoonChip(icon: Icons.key_rounded, label: 'Passkey')),
            const SizedBox(width: 8),
            Expanded(child: _ComingSoonChip(icon: Icons.qr_code_rounded, label: 'QR Code')),
          ],
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            if (loading)
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(size: 13, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonChip extends StatelessWidget {
  const _ComingSoonChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.body(size: 9.5, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}
