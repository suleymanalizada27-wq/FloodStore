import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../application/providers/auth_providers.dart';
import '../../application/providers/security_providers.dart';
import '../../domain/entities/device_session.dart';

class SecurityCenterScreen extends ConsumerWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final score = ref.watch(securityScoreProvider);
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Security Center', style: AppTextStyles.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          GlassCard(
            child: Row(
              children: [
                _ScoreRing(score: score.score),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Security Score', style: AppTextStyles.body(size: 12, color: AppColors.textTertiary)),
                      const SizedBox(height: 2),
                      Text(score.label, style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 8),
                      ...score.factors.take(3).map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '• $f',
                                style: AppTextStyles.body(size: 11.5, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification Status', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Email',
                  verified: user?.emailVerified ?? false,
                  detail: user?.email,
                ),
                _StatusRow(
                  label: 'Phone',
                  verified: user?.phoneNumber != null,
                  detail: user?.phoneNumber,
                ),
                const _StatusRow(
                  label: 'Two-Factor Authentication',
                  verified: false,
                  detail: 'Not enabled',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Signed-in Devices', style: AppTextStyles.titleMedium),
          const SizedBox(height: 10),
          sessionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => Text(
              'Could not load sessions.',
              style: AppTextStyles.body(size: 13, color: AppColors.textTertiary),
            ),
            data: (sessions) => Column(
              children: [
                for (final session in sessions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SessionTile(session: session),
                  ),
                if (sessions.length > 1)
                  TextButton(
                    onPressed: () async {
                      await ref.read(securityRepositoryProvider).terminateAllOtherSessions();
                      ref.invalidate(sessionsProvider);
                    },
                    child: const Text('Log out all other devices'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});
  final int score;

  Color get _color {
    if (score >= 85) return AppColors.success;
    if (score >= 65) return AppColors.info;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      width: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 6,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation(_color),
          ),
          Text('$score', style: AppTextStyles.heading(size: 20)),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.verified, this.detail});

  final String label;
  final bool verified;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            verified ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            size: 18,
            color: verified ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body(size: 13.5, weight: FontWeight.w600)),
                if (detail != null)
                  Text(detail!, style: AppTextStyles.body(size: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.session});
  final DeviceSession session;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            session.platform == 'iOS' || session.platform == 'Android'
                ? Icons.smartphone_rounded
                : Icons.desktop_windows_rounded,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(session.deviceName, style: AppTextStyles.body(size: 13.5, weight: FontWeight.w600)),
                    if (session.isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'This device',
                          style: AppTextStyles.body(size: 10, weight: FontWeight.w700, color: AppColors.success),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${session.platform} · Active ${_timeAgo(session.lastActiveAt)}',
                  style: AppTextStyles.body(size: 11.5, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          if (!session.isCurrent)
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
              onPressed: () async {
                await ref.read(securityRepositoryProvider).terminateSession(session.id);
                ref.invalidate(sessionsProvider);
              },
            ),
        ],
      ),
    );
  }
}
