import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The primary call-to-action button for the app.
///
/// Behavior:
/// - Scales down slightly on press (tactile, Apple-like).
/// - Lifts a soft brand-colored glow on hover (desktop/web) and on press.
/// - Shows an inline spinner in a `loading` state without changing size,
///   so the layout never jumps.
class PremiumButton extends StatefulWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool expand;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _hovering = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : 1.0;
    final glowOpacity = _enabled && _hovering ? 0.55 : 0.0;

    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: widget.expand ? double.infinity : null,
            height: 56,
            padding: widget.expand
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: _enabled
                  ? AppColors.brandGradient
                  : const LinearGradient(
                      colors: [AppColors.card, AppColors.card],
                    ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: glowOpacity),
                  blurRadius: 28,
                  spreadRadius: -4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: widget.loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: AppColors.white),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.label,
                        style: AppTextStyles.body(
                          size: 15,
                          weight: FontWeight.w700,
                          color: _enabled
                              ? AppColors.white
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
