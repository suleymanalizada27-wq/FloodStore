import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted-at-rest storage for anything auth-sensitive: cached ID/refresh
/// tokens, the "keep me signed in" long-lived session marker, and the MFA
/// resume ticket used to survive an app restart mid-challenge.
///
/// Firebase already persists its own session internally, so this service is
/// deliberately *not* a re-implementation of that — it exists for the two
/// things Firebase doesn't do for us:
///   1. An explicit, revocable flag for "keep me signed in" that survives
///      independently of Firebase's own persistence, so [SessionService]
///      can enforce FloodStore's own idle-timeout policy on top of it.
///   2. A safe place to stash short-lived, security-relevant values (e.g. a
///      pending MFA verification id) that must never land in
///      `SharedPreferences`, which is unencrypted on most platforms.
///
/// Never store raw passwords here. Never log values read from here.
class SecureTokenService {
  SecureTokenService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _keySessionToken = 'floodstore.session_token';
  static const _keyRefreshToken = 'floodstore.refresh_token';
  static const _keyPendingMfaTicket = 'floodstore.pending_mfa_ticket';

  Future<void> saveSessionToken(String token) =>
      _storage.write(key: _keySessionToken, value: token);

  Future<String?> readSessionToken() => _storage.read(key: _keySessionToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _keyRefreshToken);

  /// Stashes the verification id / resolver handle needed to resume an
  /// in-flight MFA challenge if the app is backgrounded or killed.
  Future<void> savePendingMfaTicket(String ticket) =>
      _storage.write(key: _keyPendingMfaTicket, value: ticket);

  Future<String?> readPendingMfaTicket() =>
      _storage.read(key: _keyPendingMfaTicket);

  Future<void> clearPendingMfaTicket() =>
      _storage.delete(key: _keyPendingMfaTicket);

  /// Wipes every token this service manages. Call on sign-out, on
  /// "forget this device", and whenever [AuthRateLimiter] detects tampering.
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _keySessionToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyPendingMfaTicket),
    ]);
  }
}
