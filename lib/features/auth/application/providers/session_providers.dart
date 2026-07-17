import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth_rate_limiter.dart';
import '../../../../core/services/secure_token_service.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/account_mode.dart';

/// Single instances for the whole app — cheap, stateless-besides-storage
/// wrappers, so a plain [Provider] (not autoDispose) is correct here.
final secureTokenServiceProvider = Provider<SecureTokenService>((ref) {
  return SecureTokenService();
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService();
});

final authRateLimiterProvider = Provider<AuthRateLimiter>((ref) {
  return AuthRateLimiter();
});

/// The Individual / Business / Guest toggle shown on both Login and
/// Register. Lives above both screens (rather than as local `State`) so a
/// choice made on Login is still selected if the user taps through to
/// Register, and vice versa.
final accountModeProvider =
    StateProvider<AccountMode>((ref) => AccountMode.individual);

/// "Remember me" checkbox — persisted identifier pre-fill. Read on
/// [LoginScreen] init to seed the email field; written whenever the
/// checkbox or the submitted identifier changes.
final rememberMeProvider = StateProvider<bool>((ref) => true);

/// "Keep me signed in" checkbox — opts the session out of
/// [SessionService.defaultIdleTimeout]. Separate from [rememberMeProvider]
/// because they answer different questions (see [SessionService] doc).
final keepSignedInProvider = StateProvider<bool>((ref) => false);

/// Loads whatever identifier was previously remembered, so [LoginScreen]
/// can pre-fill its email field on first build.
final rememberedIdentifierProvider = FutureProvider<String?>((ref) async {
  return ref.watch(sessionServiceProvider).getRememberedIdentifier();
});

/// Backs [RecentAccountCard] — the "Quick Login / Continue as Previous
/// User" surface. `null` when nobody has ever checked "remember me" on
/// this device.
final recentAccountProvider =
    FutureProvider<({String identifier, String? displayName})?>((ref) async {
  return ref.watch(sessionServiceProvider).getRecentAccount();
});
