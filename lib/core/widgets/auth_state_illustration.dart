import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AuthStateKind {
  offline,
  serverError,
  timeout,
  tooManyAttempts,
  invalidCredentials,
  expiredSession,
  maintenance,
  unknown,
}

extension _AuthStateKindVisuals on AuthStateKind {
  IconData get icon => switch (this) {
        AuthStateKind.offline => Icons.wifi_off_rounded,
        AuthStateKind.serverError => Icons.cloud_off_rounded,
        AuthStateKind.timeout => Icons.hourglass_bottom_rounded,
        AuthStateKind.tooManyAttempts => Icons.lock_clock_rounded,
        AuthStateKind.invalidCredentials => Icons.no_accounts_rounded,
        AuthStateKind.expiredSession => Icons.timer_off_rounded,
        AuthStateKind.maintenance => Icons.build_circle_rounded,
        AuthStateKind.unknown => Icons.error_outline_rounded,
      };

  String get title => switch (this) {
        AuthStateKind.offline => "You're offline",
        AuthStateKind.serverError => 'Something went wrong on our end',
        AuthStateKind.timeout => 'That took too long',
        AuthStateKind.tooManyAttempts => 'Too many attempts',
        AuthStateKind.invalidCredentials => "That didn't match",
        AuthStateKind.expiredSession => 'Your session expired',
        AuthStateKind.maintenance => "We'll be right back",
        AuthStateKind.unknown => 'Unexpected error',
      };

  String get subtitle => switch (this) {
        AuthStateKind.offline => 'Check your connection and try again.',
        AuthStateKind.serverError => "We're looking into it — please try again shortly.",
        AuthStateKind.timeout => 'The request timed out. Please try again.',
        AuthStateKind.tooManyAttempts => 'Please wait a moment before trying again.',
        AuthStateKind.invalidCredentials => 'Double-check your email and password.',
        AuthStateKind.expiredSession => 'Please sign in again to continue.',
        AuthStateKind.maintenance => 'FloodStore is undergoing scheduled maintenance.',
        AuthStateKind.unknown => 'Please try again — if this keeps happening, let us know.',
      };
}

/// A full-width, icon-based empty/error state — no external image assets,
/// consistent with the rest of the icon-driven design language
/// ([AccountLockBanner], [GuestModeButton], etc). Covers the "Empty / Error
/// States" catalogue from the brief: offline, server error, timeout, too
/// many attempts, invalid credentials, expired session, maintenance,
/// unknown.
class AuthStateIllustration extends StatelessWidget {
  const AuthStateIllustration({
    super.key,
    required this.kind,
    this.onRetry,
  });

  final AuthStateKind kind;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(kind.icon, size: 30, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Text(kind.title, style: AppTextStyles.heading(size: 16)),
          const SizedBox(height: 6),
          Text(
            kind.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 12.5, color: AppColors.textTertiary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            TextButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ],
      ),
    );
  }
}
