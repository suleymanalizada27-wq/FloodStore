import 'package:shared_preferences/shared_preferences.dart';

/// Result of a lock check — everything the UI needs to render
/// [AccountLockBanner] / [RateLimitBanner] without reaching back into this
/// service.
class LockStatus {
  const LockStatus({
    required this.isLocked,
    required this.attemptsRemaining,
    this.lockedUntil,
  });

  final bool isLocked;
  final int attemptsRemaining;
  final DateTime? lockedUntil;

  Duration? get remaining =>
      lockedUntil == null ? null : lockedUntil!.difference(DateTime.now());

  static const notLocked = LockStatus(isLocked: false, attemptsRemaining: -1);
}

/// A client-side, per-identifier (email or phone) failed-attempt tracker.
///
/// This is a UX affordance, not a security boundary — the real rate limit
/// must always be enforced server-side (Firebase Auth already throttles
/// `signInWithEmailAndPassword` and returns `too-many-requests`). What this
/// class adds is the ability to show a countdown / "N attempts left" *before*
/// the backend would reject the request, which is what turns a wall of
/// generic error text into an actual account-lock experience.
///
/// Backoff is exponential, capped at [_maxLockout]: 30s, 1m, 2m, 4m, ... up
/// to 15 minutes, resetting entirely on a successful sign-in.
class AuthRateLimiter {
  AuthRateLimiter({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;

  static const int maxAttemptsBeforeLock = 5;
  static const Duration _baseLockout = Duration(seconds: 30);
  static const Duration _maxLockout = Duration(minutes: 15);

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  String _attemptsKey(String id) => 'floodstore.rl.attempts.${id.trim().toLowerCase()}';
  String _lockedUntilKey(String id) =>
      'floodstore.rl.locked_until.${id.trim().toLowerCase()}';

  Future<LockStatus> check(String identifier) async {
    if (identifier.trim().isEmpty) return LockStatus.notLocked;
    final prefs = await _prefs;

    final lockedUntilMillis = prefs.getInt(_lockedUntilKey(identifier));
    if (lockedUntilMillis != null) {
      final lockedUntil = DateTime.fromMillisecondsSinceEpoch(lockedUntilMillis);
      if (DateTime.now().isBefore(lockedUntil)) {
        return LockStatus(
          isLocked: true,
          attemptsRemaining: 0,
          lockedUntil: lockedUntil,
        );
      }
      // Lock window elapsed — clear it, attempts counter resets too.
      await prefs.remove(_lockedUntilKey(identifier));
      await prefs.remove(_attemptsKey(identifier));
    }

    final attempts = prefs.getInt(_attemptsKey(identifier)) ?? 0;
    return LockStatus(
      isLocked: false,
      attemptsRemaining: (maxAttemptsBeforeLock - attempts).clamp(0, maxAttemptsBeforeLock),
    );
  }

  /// Records a failed attempt and returns the resulting status so the
  /// caller can immediately show the right banner without a second lookup.
  Future<LockStatus> recordFailure(String identifier) async {
    if (identifier.trim().isEmpty) return LockStatus.notLocked;
    final prefs = await _prefs;

    final attempts = (prefs.getInt(_attemptsKey(identifier)) ?? 0) + 1;
    await prefs.setInt(_attemptsKey(identifier), attempts);

    if (attempts < maxAttemptsBeforeLock) {
      return LockStatus(
        isLocked: false,
        attemptsRemaining: maxAttemptsBeforeLock - attempts,
      );
    }

    final lockNumber = attempts - maxAttemptsBeforeLock; // 0, 1, 2, ...
    final backoff = _baseLockout * (1 << lockNumber.clamp(0, 5));
    final lockDuration = backoff > _maxLockout ? _maxLockout : backoff;
    final lockedUntil = DateTime.now().add(lockDuration);

    await prefs.setInt(_lockedUntilKey(identifier), lockedUntil.millisecondsSinceEpoch);
    return LockStatus(isLocked: true, attemptsRemaining: 0, lockedUntil: lockedUntil);
  }

  /// Clears all lockout state for [identifier]. Call on a successful sign-in.
  Future<void> reset(String identifier) async {
    if (identifier.trim().isEmpty) return;
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(_attemptsKey(identifier)),
      prefs.remove(_lockedUntilKey(identifier)),
    ]);
  }
}
