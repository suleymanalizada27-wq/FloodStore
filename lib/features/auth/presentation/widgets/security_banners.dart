import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shown instead of [AuthErrorBanner] once [AuthFormState.isLocked] is
/// true — a locked-out attempt is a distinct situation from a single failed
/// submission, so it gets its own copy and a live countdown rather than a
/// generic error string.
class AccountLockBanner extends StatefulWidget {
  const AccountLockBanner({super.key, required this.lockedUntil});

  final DateTime? lockedUntil;

  @override
  State<AccountLockBanner> createState() => _AccountLockBannerState();
}

class _AccountLockBannerState extends State<AccountLockBanner> {
  Timer? _ticker;
  late Duration _remaining = _computeRemaining();

  Duration _computeRemaining() {
    final until = widget.lockedUntil;
    if (until == null) return Duration.zero;
    final diff = until.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining = _computeRemaining());
    });
  }

  @override
  void didUpdateWidget(covariant AccountLockBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lockedUntil != widget.lockedUntil) {
      setState(() => _remaining = _computeRemaining());
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_clock_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Too many attempts',
                  style: AppTextStyles.body(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _remaining > Duration.zero
                      ? 'For your security, this account is temporarily locked. Try again in ${_format(_remaining)}.'
                      : 'You can try signing in again now.',
                  style: AppTextStyles.body(size: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A softer, non-blocking nudge ("2 attempts left") shown once a few
/// failures have happened but before a lock kicks in — gives the user a
/// chance to stop and use "Forgot password?" instead of grinding toward a
/// lockout.
class RateLimitBanner extends StatelessWidget {
  const RateLimitBanner({super.key, required this.attemptsRemaining});

  /// `-1` (untracked) and values `< 0` render nothing; only show once the
  /// count is getting low so this doesn't nag on the very first attempt.
  final int attemptsRemaining;

  static const int _showThreshold = 2;

  @override
  Widget build(BuildContext context) {
    if (attemptsRemaining < 0 || attemptsRemaining > _showThreshold) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attemptsRemaining == 0
                  ? 'One more failed attempt will temporarily lock this account.'
                  : '$attemptsRemaining attempts remaining before a temporary lock.',
              style: AppTextStyles.body(size: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
