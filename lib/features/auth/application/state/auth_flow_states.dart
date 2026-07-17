import 'package:equatable/equatable.dart';

/// Which step of the phone sign-in flow [PhoneOtpScreen] is currently on.
enum PhoneAuthStep { enterNumber, enterCode, verifying }

/// State for [PhoneAuthController] / [PhoneOtpScreen]. Kept separate from
/// [AuthFormState] because the phone flow has an extra step (code entry)
/// and its own piece of server-issued state (`verificationId`) that no
/// other auth form needs to carry.
class PhoneAuthState extends Equatable {
  const PhoneAuthState({
    this.step = PhoneAuthStep.enterNumber,
    this.isSubmitting = false,
    this.errorMessage,
    this.verificationId,
    this.succeeded = false,
    this.resendAvailableAt,
  });

  final PhoneAuthStep step;
  final bool isSubmitting;
  final String? errorMessage;
  final String? verificationId;
  final bool succeeded;

  /// When the "resend code" action becomes available again. `null` means
  /// available now.
  final DateTime? resendAvailableAt;

  bool get canResend =>
      resendAvailableAt == null || DateTime.now().isAfter(resendAvailableAt!);

  PhoneAuthState copyWith({
    PhoneAuthStep? step,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? verificationId,
    bool? succeeded,
    DateTime? resendAvailableAt,
  }) {
    return PhoneAuthState(
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      verificationId: verificationId ?? this.verificationId,
      succeeded: succeeded ?? this.succeeded,
      resendAvailableAt: resendAvailableAt ?? this.resendAvailableAt,
    );
  }

  @override
  List<Object?> get props => [
        step,
        isSubmitting,
        errorMessage,
        verificationId,
        succeeded,
        resendAvailableAt,
      ];
}

/// State for [EmailVerificationController] / [EmailVerificationScreen].
class EmailVerificationState extends Equatable {
  const EmailVerificationState({
    this.isSending = false,
    this.isChecking = false,
    this.errorMessage,
    this.justSent = false,
    this.isVerified = false,
    this.resendAvailableAt,
  });

  final bool isSending;
  final bool isChecking;
  final String? errorMessage;
  final bool justSent;
  final bool isVerified;
  final DateTime? resendAvailableAt;

  bool get canResend =>
      resendAvailableAt == null || DateTime.now().isAfter(resendAvailableAt!);

  Duration get cooldownRemaining {
    if (resendAvailableAt == null) return Duration.zero;
    final remaining = resendAvailableAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  EmailVerificationState copyWith({
    bool? isSending,
    bool? isChecking,
    String? errorMessage,
    bool clearError = false,
    bool? justSent,
    bool? isVerified,
    DateTime? resendAvailableAt,
  }) {
    return EmailVerificationState(
      isSending: isSending ?? this.isSending,
      isChecking: isChecking ?? this.isChecking,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      justSent: justSent ?? this.justSent,
      isVerified: isVerified ?? this.isVerified,
      resendAvailableAt: resendAvailableAt ?? this.resendAvailableAt,
    );
  }

  @override
  List<Object?> get props => [
        isSending,
        isChecking,
        errorMessage,
        justSent,
        isVerified,
        resendAvailableAt,
      ];
}
