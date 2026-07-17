import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import '../state/password_reset_state.dart';
import 'auth_providers.dart';

/// Drives every step of [ForgotPasswordScreen]'s flow: request the reset
/// email, resend with a cooldown + attempt counter, verify the code the
/// email actually carries, and confirm the new password. Uses real
/// `firebase_auth` APIs throughout — `verifyPasswordResetCode` and
/// `confirmPasswordReset` are exactly what Firebase's own reset-password
/// web page calls.
class PasswordResetController extends StateNotifier<PasswordResetState> {
  PasswordResetController(this.ref) : super(const PasswordResetState());

  final Ref ref;

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  static const _resendCooldown = Duration(seconds: 45);
  static const _maxAttempts = 5;

  void _log(String entry) {
    state = state.copyWith(history: [...state.history, entry]);
  }

  Future<void> sendResetEmail(String email) async {
    if (state.attemptCount >= _maxAttempts) {
      state = state.copyWith(
        errorMessage: 'Too many reset requests. Please try again later.',
      );
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true, email: email.trim());
    try {
      await _repository.sendPasswordResetEmail(email.trim());
      state = state.copyWith(
        isSubmitting: false,
        step: PasswordResetStep.emailSent,
        resendAvailableAt: DateTime.now().add(_resendCooldown),
        attemptCount: state.attemptCount + 1,
      );
      _log('Reset email sent to ${email.trim()}');
    } on AuthFailure catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not send the reset email. Please try again.',
      );
    }
  }

  Future<void> resend() async {
    if (!state.canResend || state.email == null) return;
    await sendResetEmail(state.email!);
  }

  void proceedToEnterCode() {
    state = state.copyWith(step: PasswordResetStep.enterCode, clearError: true);
  }

  /// [code] is the `oobCode` query parameter from the link the email
  /// contains — see [PasswordResetState.oobCode]. Framing this step as
  /// "enter your code" matches the brief; under the hood it's the same
  /// code Firebase's own reset page reads from the URL, just typed/pasted
  /// in manually since this app doesn't yet handle deep links (see
  /// PART_3 doc).
  Future<void> verifyCode(String code) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final email = await _repository.verifyPasswordResetCode(code.trim());
      state = state.copyWith(
        isSubmitting: false,
        step: PasswordResetStep.newPassword,
        oobCode: code.trim(),
        email: email,
      );
      _log('Code verified for $email');
    } on AuthFailure catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'That code is invalid or has expired.',
      );
    }
  }

  Future<void> submitNewPassword(String newPassword) async {
    final code = state.oobCode;
    if (code == null) return;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.confirmPasswordReset(code: code, newPassword: newPassword);
      state = state.copyWith(isSubmitting: false, step: PasswordResetStep.success);
      _log('Password reset completed');
    } on AuthFailure catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not reset the password. Please try again.',
      );
    }
  }

  /// Optional "automatic login after reset" — architecture is here (just
  /// calls the normal email sign-in with the password the user just set),
  /// but [PasswordRecoveryScreen] currently keeps the explicit sign-in
  /// step instead of firing this automatically, so a shared/borrowed
  /// device doesn't silently land in the previous owner's account.
  Future<void> signInWithNewPassword(String newPassword) async {
    final email = state.email;
    if (email == null) return;
    await _repository.signInWithEmail(email: email, password: newPassword);
  }

  void reset() => state = const PasswordResetState();
}

final passwordResetControllerProvider =
    StateNotifierProvider.autoDispose<PasswordResetController, PasswordResetState>(
  PasswordResetController.new,
);
