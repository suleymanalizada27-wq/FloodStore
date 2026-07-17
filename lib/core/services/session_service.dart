import 'package:shared_preferences/shared_preferences.dart';

/// FloodStore distinguishes two related but different opt-ins on the login
/// form, both of which already appear on [LoginScreen] or are added by this
/// part:
///
/// - **Remember me** — pre-fills the identity field (email/phone) on the
///   next visit. Doesn't change how long the session lives.
/// - **Keep me signed in** — opts the session out of the idle-timeout policy
///   below. Without it, FloodStore signs the user out after
///   [SessionService.defaultIdleTimeout] of inactivity even though
///   Firebase's own token would still be valid.
///
/// This is intentionally layered *on top of* Firebase's session, not a
/// replacement for it — [FirebaseAuthRepository] remains the source of
/// truth for "is anyone signed in at all".
class SessionService {
  SessionService({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;

  static const _keyRememberMe = 'floodstore.remember_me';
  static const _keyRememberedIdentifier = 'floodstore.remembered_identifier';
  static const _keyRememberedDisplayName = 'floodstore.remembered_display_name';
  static const _keyKeepSignedIn = 'floodstore.keep_signed_in';
  static const _keyLastActiveAtMillis = 'floodstore.last_active_at';

  /// How long a session is allowed to sit idle before FloodStore forces a
  /// re-authentication, for users who did not check "keep me signed in".
  static const Duration defaultIdleTimeout = Duration(hours: 12);

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  // -- Remember me ----------------------------------------------------

  Future<void> setRememberedIdentifier(String? identifier) async {
    final prefs = await _prefs;
    if (identifier == null || identifier.isEmpty) {
      await prefs.setBool(_keyRememberMe, false);
      await prefs.remove(_keyRememberedIdentifier);
      return;
    }
    await prefs.setBool(_keyRememberMe, true);
    await prefs.setString(_keyRememberedIdentifier, identifier);
  }

  Future<String?> getRememberedIdentifier() async {
    final prefs = await _prefs;
    if (!(prefs.getBool(_keyRememberMe) ?? false)) return null;
    return prefs.getString(_keyRememberedIdentifier);
  }

  Future<void> setRememberedDisplayName(String? name) async {
    final prefs = await _prefs;
    if (name == null || name.isEmpty) {
      await prefs.remove(_keyRememberedDisplayName);
      return;
    }
    await prefs.setString(_keyRememberedDisplayName, name);
  }

  /// Powers [RecentAccountCard]: the identifier + display name of whoever
  /// last signed in with "remember me" checked, so a returning user who
  /// got idle-timed-out sees "Welcome back, Jane" instead of a blank form.
  Future<({String identifier, String? displayName})?> getRecentAccount() async {
    final identifier = await getRememberedIdentifier();
    if (identifier == null) return null;
    final prefs = await _prefs;
    return (identifier: identifier, displayName: prefs.getString(_keyRememberedDisplayName));
  }

  // -- Keep me signed in / idle timeout --------------------------------

  Future<void> setKeepSignedIn(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyKeepSignedIn, value);
  }

  Future<bool> getKeepSignedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyKeepSignedIn) ?? false;
  }

  /// Call whenever the user does something meaningful in an authenticated
  /// area of the app (e.g. from a top-level navigation listener). Cheap
  /// enough to call on every route change.
  Future<void> touchActivity() async {
    final prefs = await _prefs;
    await prefs.setInt(
      _keyLastActiveAtMillis,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Returns true if the session has been idle longer than
  /// [defaultIdleTimeout] *and* the user did not opt in to "keep me signed
  /// in". [AuthGuards] consults this from the router redirect.
  Future<bool> isSessionExpired({Duration? idleTimeout}) async {
    if (await getKeepSignedIn()) return false;

    final prefs = await _prefs;
    final lastActiveMillis = prefs.getInt(_keyLastActiveAtMillis);
    if (lastActiveMillis == null) return false;

    final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveMillis);
    final timeout = idleTimeout ?? defaultIdleTimeout;
    return DateTime.now().difference(lastActive) > timeout;
  }

  /// Clears every session-policy flag. Call on sign-out.
  Future<void> clear() async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(_keyKeepSignedIn),
      prefs.remove(_keyLastActiveAtMillis),
      // Deliberately NOT clearing the remembered identifier here — the
      // user still wants their email pre-filled next time even after
      // signing out. Call `setRememberedIdentifier(null)` explicitly if a
      // full "forget me" is what's wanted instead.
    ]);
  }
}
