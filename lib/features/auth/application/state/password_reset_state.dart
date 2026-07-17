import 'package:equatable/equatable.dart';

enum PasswordResetStep { enterEmail, emailSent, enterCode, newPassword, success }

class PasswordResetState extends Equatable {
  const PasswordResetState({
    this.step = PasswordResetStep.enterEmail,
    this.isSubmitting = false,
    this.errorMessage,
    this.email,
    this.oobCode,
    this.resendAvailableAt,
    this.attemptCount = 0,
    this.history = const [],
  });

  final PasswordResetStep step;
  final bool isSubmitting;
  final String? errorMessage;
  final String? email;

  /// Firebase's password-reset "code" — technically the `oobCode` query
  /// parameter carried by the link in the reset email, not a short numeric
  /// code. See [PasswordResetController] for why the UI still frames this
  /// as "enter your code".
  final String? oobCode;

  final DateTime? resendAvailableAt;

  /// How many reset emails have been requested this session — surfaced as
  /// "Recovery history" isn't a stored server log (Firebase Auth keeps
  /// none), so this in-memory counter is what's actually inspectable here.
  final int attemptCount;

  /// Timestamped log of actions taken this session — the "recovery
  /// history" the brief asked for, scoped to what's real: this device,
  /// this attempt, not a durable server-side audit trail.
  final List<String> history;

  bool get canResend =>
      resendAvailableAt == null || DateTime.now().isAfter(resendAvailableAt!);

  PasswordResetState copyWith({
    PasswordResetStep? step,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? email,
    String? oobCode,
    DateTime? resendAvailableAt,
    int? attemptCount,
    List<String>? history,
  }) {
    return PasswordResetState(
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      email: email ?? this.email,
      oobCode: oobCode ?? this.oobCode,
      resendAvailableAt: resendAvailableAt ?? this.resendAvailableAt,
      attemptCount: attemptCount ?? this.attemptCount,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        step,
        isSubmitting,
        errorMessage,
        email,
        oobCode,
        resendAvailableAt,
        attemptCount,
        history,
      ];
}
