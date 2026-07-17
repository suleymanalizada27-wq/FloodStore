import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth_rate_limiter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/social_auth_dispatch.dart';
import '../../domain/services/social_auth_provider_type.dart';
import '../state/auth_flow_states.dart';
import '../state/auth_form_state.dart';
import 'auth_providers.dart';
import 'session_providers.dart';

/// Base controller wiring: every auth flow follows the same
/// submit -> loading -> success|error shape, so the pattern is factored
/// out once here rather than duplicated per screen.
abstract class _BaseAuthController extends StateNotifier<AuthFormState> {
  _BaseAuthController(this.ref) : super(const AuthFormState());

  final Ref ref;

  AuthRepository get repository => ref.read(authRepositoryProvider);

  Future<void> guard(Future<void> Function() action) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await action();
      state = state.copyWith(isSubmitting: false, succeeded: true);
    } on AuthFailure catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }
}

class LoginController extends _BaseAuthController {
  LoginController(super.ref);

  AuthRateLimiter get _rateLimiter => ref.read(authRateLimiterProvider);

  /// Wraps email sign-in with client-side rate limiting: checks
  /// [AuthRateLimiter] before ever hitting the network, records a failure
  /// (and reflects any resulting lock in [AuthFormState]) if the backend
  /// rejects the credential, and resets the counter on success so a
  /// legitimate user who mistyped once isn't punished going forward.
  Future<void> signInWithEmail(String email, String password) async {
    final identifier = email.trim();

    final status = await _rateLimiter.check(identifier);
    if (status.isLocked) {
      state = state.copyWith(
        isLocked: true,
        lockedUntil: status.lockedUntil,
        attemptsRemaining: 0,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearLock: true,
    );
    try {
      await repository.signInWithEmail(email: identifier, password: password);
      await _rateLimiter.reset(identifier);
      state = state.copyWith(isSubmitting: false, succeeded: true);
    } on AuthFailure catch (e) {
      final newStatus = await _rateLimiter.recordFailure(identifier);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.message,
        isLocked: newStatus.isLocked,
        lockedUntil: newStatus.lockedUntil,
        attemptsRemaining: newStatus.attemptsRemaining,
      );
    } catch (e) {
      final newStatus = await _rateLimiter.recordFailure(identifier);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
        isLocked: newStatus.isLocked,
        lockedUntil: newStatus.lockedUntil,
        attemptsRemaining: newStatus.attemptsRemaining,
      );
    }
  }

  Future<void> signInWithGoogle() => guard(repository.signInWithGoogle);

  Future<void> signInWithApple() => guard(repository.signInWithApple);

  Future<void> signInWithMicrosoft() => guard(repository.signInWithMicrosoft);

  Future<void> signInWithGithub() => guard(repository.signInWithGithub);

  /// Dispatches through [SocialAuthDispatch] — the abstraction new social
  /// providers should be added through going forward instead of a new
  /// bespoke method per button.
  Future<void> signInWithProvider(SocialAuthProviderType provider) =>
      guard(() => repository.signIn(provider));

  Future<void> continueAsGuest() => guard(repository.signInAsGuest);
}

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, AuthFormState>(
  LoginController.new,
);

class RegisterController extends _BaseAuthController {
  RegisterController(super.ref);

  Future<void> register(RegisterPayload payload) {
    return guard(() => repository.registerWithEmail(payload));
  }
}

final registerControllerProvider =
    StateNotifierProvider.autoDispose<RegisterController, AuthFormState>(
  RegisterController.new,
);

/// Drives [PhoneOtpScreen]: sends the SMS code, then verifies it. Kept as
/// its own [StateNotifier] (rather than reusing [_BaseAuthController])
/// because the phone flow has a two-step shape ([PhoneAuthState.step]) and
/// a piece of server state (`verificationId`) no other controller needs.
class PhoneAuthController extends StateNotifier<PhoneAuthState> {
  PhoneAuthController(this.ref) : super(const PhoneAuthState());

  final Ref ref;

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  static const _resendCooldown = Duration(seconds: 30);

  Future<void> sendCode(String phoneNumber) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.startPhoneVerification(
        phoneNumber: phoneNumber.trim(),
        onCodeSent: (verificationId) {
          state = state.copyWith(
            isSubmitting: false,
            step: PhoneAuthStep.enterCode,
            verificationId: verificationId,
            resendAvailableAt: DateTime.now().add(_resendCooldown),
          );
        },
        onFailed: (failure) {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not send a verification code. Please try again.',
      );
    }
  }

  Future<void> resendCode(String phoneNumber) {
    if (!state.canResend) return Future.value();
    return sendCode(phoneNumber);
  }

  Future<void> verifyCode(String smsCode) async {
    final verificationId = state.verificationId;
    if (verificationId == null) return;

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      step: PhoneAuthStep.verifying,
    );
    try {
      await _repository.verifyPhoneCode(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      state = state.copyWith(isSubmitting: false, succeeded: true);
    } on AuthFailure catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.message,
        step: PhoneAuthStep.enterCode,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Invalid or expired code. Please try again.',
        step: PhoneAuthStep.enterCode,
      );
    }
  }
}

final phoneAuthControllerProvider =
    StateNotifierProvider.autoDispose<PhoneAuthController, PhoneAuthState>(
  PhoneAuthController.new,
);

/// Drives [EmailVerificationScreen]: resend-with-cooldown plus an explicit
/// "I've verified" check that reloads the current user so
/// `emailVerified` is fresh without forcing a sign-out/sign-in.
class EmailVerificationController extends StateNotifier<EmailVerificationState> {
  EmailVerificationController(this.ref) : super(const EmailVerificationState());

  final Ref ref;

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  static const _resendCooldown = Duration(seconds: 45);

  Future<void> sendVerification() async {
    if (!state.canResend) return;
    state = state.copyWith(isSending: true, clearError: true, justSent: false);
    try {
      await _repository.sendEmailVerification();
      state = state.copyWith(
        isSending: false,
        justSent: true,
        resendAvailableAt: DateTime.now().add(_resendCooldown),
      );
    } on AuthFailure catch (e) {
      state = state.copyWith(isSending: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Could not send the verification email. Please try again.',
      );
    }
  }

  /// Re-fetches the user and reports whether they've verified yet — call
  /// from an "I've verified my email" button and from a periodic poll
  /// while the screen is visible.
  Future<bool> checkVerified() async {
    state = state.copyWith(isChecking: true, clearError: true);
    try {
      final user = await _repository.reloadCurrentUser();
      final verified = user?.emailVerified ?? false;
      state = state.copyWith(isChecking: false, isVerified: verified);
      return verified;
    } catch (e) {
      state = state.copyWith(isChecking: false);
      return false;
    }
  }
}

final emailVerificationControllerProvider = StateNotifierProvider.autoDispose<
    EmailVerificationController, EmailVerificationState>(
  EmailVerificationController.new,
);
