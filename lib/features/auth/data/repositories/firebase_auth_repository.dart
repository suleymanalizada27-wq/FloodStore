import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:local_auth/local_auth.dart';
import 'package:platform/platform.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/mfa_method.dart';
import '../../domain/repositories/auth_repository.dart';

/// Production implementation of [AuthRepository] backed by Firebase
/// Authentication.
///
/// Setup required before this compiles against a real project:
///   1. Run `flutterfire configure` to generate `firebase_options.dart`.
///   2. Enable the Email/Password, Google, Apple and Phone providers in the
///      Firebase console.
///   3. For Microsoft and GitHub, register the respective OAuth providers
///      (`microsoft.com`, `github.com`) in the Firebase console. Both go
///      through Firebase's generic `OAuthProvider` — neither needs a
///      dedicated package. GitHub additionally requires an OAuth App
///      registered at github.com/settings/developers with the Firebase
///      auth handler URL as its callback.
///   4. Enable Anonymous auth in the Firebase console for Guest Mode.
///
/// No mock branches live in this class: every method either talks to
/// Firebase or throws. Screens should never special-case "is this real or
/// fake" — that's exactly what this abstraction exists to prevent.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    PlatformPlatform? platform,
  })  : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _platform = platform ?? const LocalPlatform();

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final PlatformPlatform _platform;

  AppUser _mapUser(fb.User user) => AppUser(
        id: user.uid,
        email: user.email,
        phoneNumber: user.phoneNumber,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        emailVerified: user.emailVerified,
      );

  AuthFailure _mapException(Object error) {
    if (error is fb.FirebaseAuthException) {
      return AuthFailure(
        error.message ?? 'Authentication failed. Please try again.',
        code: error.code,
      );
    }
    return AuthFailure(error.toString());
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map((u) => u == null ? null : _mapUser(u));
  }

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapUser(credential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> registerWithEmail(RegisterPayload payload) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: payload.email,
        password: payload.password,
      );
      final displayName = '${payload.firstName} ${payload.lastName}'.trim();
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.sendEmailVerification();
      // payload.accountMode / payload.companyName are captured on the form
      // (see AccountModeSelector) but Firebase Auth itself has nowhere to
      // persist a company profile — that belongs in a Firestore/user-profile
      // document once one exists. Wiring that write-through is a Part 3+
      // item; nothing here silently drops the field, it's just not yet
      // durable server-side beyond this payload.
      return _mapUser(credential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure(
          'Google sign-in was cancelled.',
          code: 'cancelled',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return _mapUser(userCredential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      return _mapUser(userCredential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInWithMicrosoft() async {
    try {
      final provider = fb.OAuthProvider('microsoft.com')
        ..addScope('mail.read')
        ..setCustomParameters({'prompt': 'select_account'});
      final userCredential = await _auth.signInWithProvider(provider);
      return _mapUser(userCredential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInWithGithub() async {
    try {
      final provider = fb.OAuthProvider('github.com')
        ..addScope('read:user')
        ..addScope('user:email')
        ..setCustomParameters({'allow_signup': 'true'});
      final userCredential = await _auth.signInWithProvider(provider);
      return _mapUser(userCredential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return _mapUser(userCredential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(AuthFailure failure) onFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {
        // Auto-retrieval on Android completes silently; the UI flow for
        // FloodStore always confirms via the OTP screen, so this is a
        // deliberate no-op.
      },
      verificationFailed: (e) => onFailed(_mapException(e)),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<AppUser> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return _mapUser(userCredential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final localAuth = LocalAuthentication();
      bool canCheckBiometrics = false;
      try {
        canCheckBiometrics = await localAuth.canCheckBiometrics;
      } on Exception catch (_) {
        // On some platforms, canCheckBiometrics might throw.
        canCheckBiometrics = false;
      }
      return canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AppUser> signInWithBiometrics() async {
    // First, check if biometric is available.
    final bool isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      throw const AuthFailure(
        'Biometric authentication is not available on this device.',
        code: 'biometric-not-available',
      );
    }

    // Prompt the user for biometric authentication.
    final localAuth = LocalAuthentication();
    bool didAuthenticate = false;
    try {
      didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to confirm your identity',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on Exception catch (e) {
      throw AuthFailure(
        'Biometric authentication failed: $e',
        code: 'biometric-failed',
      );
    }

    if (!didAuthenticate) {
      throw const AuthFailure(
        'Biometric authentication failed.',
        code: 'biometric-failed',
      );
    }

    // If we reach here, biometric succeeded.
    // Now, we must have a current user to return.
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure(
        'No user is currently signed in. Please sign in with email or social first.',
        code: 'no-current-user',
      );
    }
    return _mapUser(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<String> verifyPasswordResetCode(String code) async {
    try {
      return await _auth.verifyPasswordResetCode(code);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('No signed-in user.', code: 'no-current-user');
      }
      await user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('No signed-in user to verify.', code: 'no-current-user');
      }
      await user.sendEmailVerification();
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser?> reloadCurrentUser() async {
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      return user == null ? null : _mapUser(user);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

// A platform interface for testing.
abstract class PlatformPlatform {
  bool get isAndroid;
  bool get isIOS;
}

class LocalPlatform extends PlatformPlatform {
  @override
  bool get isAndroid => Platform.isAndroid;
  @override
  bool get isIOS => Platform.isIOS;
}