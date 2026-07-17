import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_security_repository.dart';
import '../../domain/entities/device_session.dart';
import '../../domain/repositories/security_repository.dart';
import 'auth_providers.dart';

final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  return FirestoreSecurityRepository();
});

final sessionsProvider = FutureProvider.autoDispose<List<DeviceSession>>((ref) {
  return ref.watch(securityRepositoryProvider).listSessions();
});

final loginHistoryProvider = FutureProvider.autoDispose<List<LoginHistoryEntry>>((ref) {
  return ref.watch(securityRepositoryProvider).listLoginHistory();
});

/// Rolls up account-hygiene signals FloodStore already has on hand into a
/// single 0–100 [SecurityScore] — deliberately computed client-side rather
/// than stored, so it's always consistent with the live user/session data
/// and never goes stale.
final securityScoreProvider = Provider.autoDispose<SecurityScore>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  final sessions = ref.watch(sessionsProvider).valueOrNull ?? const [];

  var score = 100;
  final factors = <String>[];

  if (user == null) return const SecurityScore(score: 0, factors: ['Not signed in']);

  if (!user.emailVerified && user.email != null) {
    score -= 25;
    factors.add('Email not verified (-25)');
  }
  if (user.phoneNumber == null) {
    score -= 10;
    factors.add('No phone number on file (-10)');
  }
  // MFA enrollment isn't wired yet (see MfaMethod) — treated as "not
  // enrolled" for scoring purposes until Part 4 makes it real.
  score -= 15;
  factors.add('Two-factor authentication not enabled (-15)');

  final untrustedCount = sessions.where((s) => !s.isTrusted && !s.isCurrent).length;
  if (untrustedCount > 0) {
    final deduction = (untrustedCount * 5).clamp(0, 20);
    score -= deduction;
    factors.add('$untrustedCount unrecognized device(s) signed in (-$deduction)');
  }

  score = score.clamp(0, 100);
  if (factors.isEmpty) factors.add('All checks passed');

  return SecurityScore(score: score, factors: factors);
});
