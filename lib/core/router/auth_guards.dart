import '../../features/auth/domain/entities/app_user.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'app_router.dart';

/// The "authentication middleware" for FloodStore: a small, pure set of
/// functions the router's `redirect` calls in order. Kept out of
/// `app_router.dart` so each rule is independently testable and reads as a
/// checklist instead of one long `if` chain.
///
// Every guard takes the same three things — the signed-in user (or
// `null`), the location being navigated to, and whether the session has
// gone idle — and returns either a redirect path or `null` ("this guard
// has no opinion, ask the next one").
abstract final class AuthGuards {
  /// Unauthenticated users may only be on an `/auth/*` route.
  static String? requireAuth({
    required AppUser? user,
    required String location,
  }) {
    final isOnAuthFlow = location.startsWith(AppRoutes.auth);
    if (user == null && !isOnAuthFlow) return AppRoutes.auth;
    return null;
  }

  /// Signed-in users shouldn't be able to sit on the sign-in/register
  /// screens — but they *are* allowed on `/auth/verify-email` and
  /// `/auth/phone`, which are themselves part of finishing sign-in.
  static String? redirectSignedInAwayFromAuth({
    required AppUser? user,
    required String location,
  }) {
    final isOnAuthFlow = location.startsWith(AppRoutes.auth);
    final isOnAuthSubflow = location == AppRoutes.verifyEmail ||
        location == AppRoutes.phoneAuth ||
        location == AppRoutes.organizationOnboarding ||
        location == AppRoutes.register;
    if (user != null && isOnAuthFlow && !isOnAuthSubflow) return AppRoutes.home;
    return null;
  }

  /// Email/password users with an unverified address are confined to
  /// `/auth/verify-email` until they click the link. Guests, phone users,
  /// and every OAuth provider (whose emails Firebase already verified
  /// upstream, or who have no email at all) are exempt.
  ///
  /// In debug mode, email verification is bypassed to facilitate development.
  static String? requireEmailVerified({
    required AppUser? user,
    required String location,
  }) {
    if (user == null) return null;
    if (user.email == null) return null; // guest / phone-only account
    if (user.emailVerified) return null;
    // In debug mode, allow bypassing email verification for easier testing
    if (kDebugMode) return null;
    if (location == AppRoutes.verifyEmail) return null;
    // The Register wizard signs the user in as the very last step of
    // registerWithEmail, then shows its own "Finish" screen before
    // navigating onward on the user's own tap — don't yank them away
    // mid-animation the instant Firebase's auth state updates.
    if (location == AppRoutes.register) return null;
    return AppRoutes.verifyEmail;
  }

  /// Idle-timeout enforcement for users who did not check "keep me signed
  /// in" — see [SessionService]. Call site is responsible for actually
  /// signing the user out; this guard only decides *whether* to.
  static bool shouldForceReauth({required bool sessionExpired}) => sessionExpired;
}