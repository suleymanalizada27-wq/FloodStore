import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum SocialProvider { google, apple, microsoft, github, phone, guest }

/// A single row-style button for third-party auth providers.
///
/// Icons are drawn with lightweight custom painters / built-in glyphs
/// rather than bundled brand SVGs, so the widget has zero extra asset
/// dependencies while still being visually correct.
class SocialAuthButton extends StatefulWidget {
  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  final SocialProvider provider;
  final VoidCallback onPressed;

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton> {
  bool _hovering = false;

  ({IconData icon, String label}) get _meta => switch (widget.provider) {
        SocialProvider.google => (
            icon: Icons.g_mobiledata_rounded,
            label: 'Continue with Google',
          ),
        SocialProvider.apple => (
            icon: Icons.apple_rounded,
            label: 'Continue with Apple',
          ),
        SocialProvider.microsoft => (
            icon: Icons.window_rounded,
            label: 'Continue with Microsoft',
          ),
        SocialProvider.github => (
            icon: Icons.code_rounded,
            label: 'Continue with GitHub',
          ),
        SocialProvider.phone => (
            icon: Icons.phone_iphone_rounded,
            label: 'Continue with Phone',
          ),
        SocialProvider.guest => (
            icon: Icons.group_outlined,
            label: 'Continue as Guest',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final meta = _meta;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            color: _hovering ? AppColors.cardElevated : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovering ? AppColors.borderStrong : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(meta.icon, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 10),
              Text(
                meta.label,
                style: AppTextStyles.body(size: 14, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
