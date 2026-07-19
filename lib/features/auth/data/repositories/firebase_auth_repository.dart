import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'dart:io' show Platform;
import '../../domain/entities/app_user.dart';
import '../../domain/entities/mfa_method.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final LocalAuthentication _localAuth;

  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    LocalAuthentication? localAuth,
  })  : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: 'com.firebase.floodstore',
              scopes: ['email', 'profile'],
            ),
        _localAuth = localAuth ?? LocalAuthentication();

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) => user != null ? _mapUser(user) : null);
  }

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user != null ? _mapUser(user) : null;
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
      await _writeTestUser(credential.user!);
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
      await _writeTestUser(credential.user!);
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
        throw fb.FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);
      await _writeTestUser(userCredential.user!);
      return _mapUser(userCredential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInWithApple() async {
    try {
      // Define the scopes we want
      final List<AppleIDAuthorizationScopes> scopes = [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ];

      // Prepare web authentication options for non-Apple platforms (Android and Web)
      final WebAuthenticationOptions? webAuthenticationOptions =
          kIsWeb || Platform.isAndroid
              ? WebAuthenticationOptions(
                  clientId: 'com.firebase.floodstore.signin',
                  redirectUri: Uri.parse(
                      'https://floodstore-fbece.firebaseapp.com/__/auth/handler'),
                )
              : null;

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: scopes,
        webAuthenticationOptions: webAuthenticationOptions,
      );

      final oAuthCredential = fb.OAuthProvider('apple').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential =
          await _auth.signInWithCredential(oAuthCredential);
      await _writeTestUser(userCredential.user!);
      return _mapUser(userCredential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInWithMicrosoft() async {
    try {
      final microsoftProvider = fb.OAuthProvider('microsoft.com');
      final credential = await _auth.signInWithProvider(microsoftProvider);
      await _writeTestUser(credential.user!);
      return _mapUser(credential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInWithGithub() async {
    try {
      final githubProvider = fb.OAuthProvider('github.com');
      final credential = await _auth.signInWithProvider(githubProvider);
      await _writeTestUser(credential.user!);
      return _mapUser(credential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      await _writeTestUser(credential.user!);
      return _mapUser(credential.user!);
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
      verificationCompleted: (phoneAuthCredential) async {
        final userCredential =
            await _auth.signInWithCredential(phoneAuthCredential);
        await _writeTestUser(userCredential.user!);
      },
      verificationFailed: (fb.FirebaseAuthException error) {
        onFailed(_mapException(error));
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-reset timeout
      },
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
      await _writeTestUser(userCredential.user!);
      return _mapUser(userCredential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> requestVoiceCall(String phoneNumber) async {
    throw UnimplementedError('Voice call OTP is not implemented yet.');
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
      final email = await _auth.verifyPasswordResetCode(code);
      return email;
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
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> sendMagicLink(String email) async {
    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: fb.ActionCodeSettings(
          url: 'https://floodstore-fbece.firebaseapp.com/__/auth/handler',
          handleCodeInApp: true,
          androidPackageName: 'com.example.flood_store',
          androidInstallApp: true,
          iOSBundleId: 'com.example.floodStore',
        ),
      );
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<bool> isMagicLink(String link) async {
    return _auth.isSignInWithEmailLink(link);
  }

  @override
  Future<AppUser> signInWithMagicLink({
    required String email,
    required String link,
  }) async {
    try {
      final credential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: link,
      );
      await _writeTestUser(credential.user!);
      return _mapUser(credential.user!);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw fb.FirebaseAuthException(
          code: 'ERROR_NOT_AUTHENTICATED',
          message: 'User not authenticated',
        );
      }
      await user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      if (!kIsWeb) {
        return await _localAuth.canCheckBiometrics ||
            await _localAuth.isDeviceSupported();
      }
      return false; // Web doesn't support local_auth biometrics
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AppUser> signInWithBiometrics() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw fb.FirebaseAuthException(
        code: 'ERROR_NOT_AUTHENTICATED',
        message: 'User must be signed in to use biometric authentication',
      );
    }

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to verify identity',
      );

      if (!didAuthenticate) {
        throw fb.FirebaseAuthException(
          code: 'ERROR_USER_CANCELLED',
          message: 'Biometric authentication failed',
        );
      }

      return _mapUser(user);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInWithPasskey() async {
    throw UnimplementedError('Passkey sign-in is not implemented yet.');
  }

  @override
  Future<List<String>> generateBackupCodes() async {
    throw UnimplementedError('Backup codes generation is not implemented yet.');
  }

  @override
  Future<AppUser> signInWithBackupCode(String code) async {
    throw UnimplementedError('Backup code sign-in is not implemented yet.');
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw fb.FirebaseAuthException(
          code: 'ERROR_NOT_AUTHENTICATED',
          message: 'User not authenticated',
        );
      }
      await user.sendEmailVerification();
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser?> reloadCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      await user.reload();
      return _mapUser(user);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<List<MfaMethod>> getEnrolledMfaMethods() async {
    throw UnimplementedError('Getting enrolled MFA methods is not implemented yet.');
  }

  @override
  Future<void> enrollMfa(MfaMethod method) async {
    throw UnimplementedError('MFA enrollment is not implemented yet.');
  }

  @override
  Future<AppUser> resolveMfaChallenge({
    required MfaChallenge challenge,
    required String code,
  }) async {
    throw UnimplementedError('MFA challenge resolution is not implemented yet.');
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw _mapException(e);
    }
  }

  // Helper methods
  AppUser _mapUser(fb.User user) {
    return AppUser(
      id: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  Future<void> _writeTestUser(fb.User user) async {
    if (!kDebugMode) return;

    try {
      debugPrint('Firebase connection verified for user: ${user.uid}');
    } catch (e) {
      // Ignore errors in debug mode
    }
  }

  AuthFailure _mapException(dynamic e) {
    if (e is fb.FirebaseAuthException) {
      return AuthFailure(
        e.message ?? 'An unknown error occurred',
        code: e.code,
      );
    }
    return const AuthFailure('An unknown error occurred', code: 'ERROR_UNKNOWN');
  }
}