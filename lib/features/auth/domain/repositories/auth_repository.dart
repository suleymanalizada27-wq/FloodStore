import '../entities/account_mode.dart';
import '../entities/app_user.dart';
import '../entities/mfa_method.dart';

/// Immutable payload for the "Create Account" form.
class RegisterPayload {
  const RegisterPayload({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.country,
    this.accountMode = AccountMode.individual,
    this.companyName,
  });

  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String password;
  final String country;
  final AccountMode accountMode;
  final String? companyName;
}

/// A typed failure surfaced from the auth backend, kept independent of any
/// particular SDK's exception type so the UI layer never has to import
/// `firebase_auth`.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthFailure($code): $message';
}

/// Contract for every authentication operation FloodStore needs.
///
/// The presentation layer (screens, controllers) only ever talks to this
/// interface via Riverpod providers — never to a concrete implementation
/// directly. Swap [FirebaseAuthRepository] for a fake in tests, or for a
/// different backend entirely, without touching a single screen.
abstract class AuthRepository {
  /// Emits the current user whenever auth state changes, or `null` when
  /// signed out.
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmail(RegisterPayload payload);

  Future<AppUser> signInWithGoogle();

  Future<AppUser> signInWithApple();

  Future<AppUser> signInWithMicrosoft();

  Future<AppUser> signInWithGithub();

  /// Anonymous / "Guest Mode" sign-in. Produces a real [AppUser] (Firebase
  /// anonymous auth), so guarded routes and the router's redirect logic
  /// don't need a separate "no user at all" branch — a guest is simply an
  /// [AppUser] whose [AppUser.email] is `null`.
  Future<AppUser> signInAsGuest();

  /// Starts phone verification; the backend implementation is responsible
  /// for triggering the SMS code and, on completion, handing back a
  /// callback used by [verifyPhoneCode].
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(AuthFailure failure) onFailed,
  });

  Future<AppUser> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  });

  /// "Voice Call fallback" — Firebase Auth's phone provider is SMS-only;
  /// a voice OTP delivery channel needs a separate telephony provider
  /// (e.g. Twilio Verify) behind a Cloud Function this client can't call
  /// directly yet. Architecture stub, same treatment as the MFA methods.
  Future<void> requestVoiceCall(String phoneNumber);

  Future<void> sendPasswordResetEmail(String email);

  /// Resolves the `oobCode` from a password-reset link to the email
  /// address it was issued for, and confirms the code is still valid —
  /// call before showing the "new password" step so an expired/garbled
  /// code is caught early instead of after the user has typed a new
  /// password.
  Future<String> verifyPasswordResetCode(String code);

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  });

  /// Emails a one-tap sign-in link (Firebase's "email link" auth) — the
  /// "Magic Link Login" premium option. [FirebaseAuthRepository] wires
  /// this for real; it's genuine Firebase functionality, not an
  /// architecture stub like the biometric/passkey/QR options.
  Future<void> sendMagicLink(String email);

  Future<bool> isMagicLink(String link);

  Future<AppUser> signInWithMagicLink({required String email, required String link});

  /// Sends a re-verification link to [newEmail]; the address only takes
  /// effect once the user clicks it. Used by "Change Email" on
  /// [EmailVerificationScreen].
  Future<void> updateEmail(String newEmail);

  /// -- Premium login options (architecture only) ------------------------
  ///
  /// Biometric/Passkey both need a native platform plugin (`local_auth`,
  /// WebAuthn credential APIs) this pass doesn't add — see PART_3 doc for
  /// why. Backup codes need a place to durably store one-time-use codes
  /// (Firestore, same pattern as OrganizationRepository) that isn't wired
  /// yet either. All three throw deliberately rather than faking success.

  Future<bool> isBiometricAvailable();

  Future<AppUser> signInWithBiometrics();

  Future<AppUser> signInWithPasskey();

  Future<List<String>> generateBackupCodes();

  Future<AppUser> signInWithBackupCode(String code);

  /// Sends (or re-sends) a verification link to [currentUser]'s email.
  /// [EmailVerificationController] wraps this with the cooldown UI needs;
  /// this layer is intentionally cooldown-unaware.
  Future<void> sendEmailVerification();

  /// Re-fetches the current user from the backend so
  /// `currentUser.emailVerified` reflects a just-completed verification
  /// without requiring a full sign-out/sign-in.
  Future<AppUser?> reloadCurrentUser();

  /// -- Multi-factor authentication (architecture only) -----------------
  ///
  /// These three methods define the *shape* Part 3+ will implement against;
  /// see MfaChallenge for why. FirebaseAuthRepository intentionally throws
  /// UnimplementedError rather than silently no-op-ing, so nothing pretends
  /// to be secure before it is.

  Future<List<MfaMethod>> getEnrolledMfaMethods();

  Future<void> enrollMfa(MfaMethod method);

  Future<AppUser> resolveMfaChallenge({
    required MfaChallenge challenge,
    required String code,
  });

  Future<void> signOut();
}