import 'package:equatable/equatable.dart';

/// Represents the lifecycle of an in-flight auth form submission
/// (sign in, register, password reset, phone verification).
///
/// Screens read this to drive button loading spinners and inline error
/// banners without ever touching a `try/catch` themselves.
class AuthFormState extends Equatable {
  const AuthFormState({
    this.isSubmitting = false,
    this.errorMessage,
    this.succeeded = false,
    this.isLocked = false,
    this.lockedUntil,
    this.attemptsRemaining = -1,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final bool succeeded;

  /// True once [AuthRateLimiter] has locked the identifier currently being
  /// submitted. Drives [AccountLockBanner] — the submit button itself
  /// stays enabled/disabled based on this, not just [isSubmitting].
  final bool isLocked;

  /// When [isLocked] is true, how long until the lock clears. `null` means
  /// "unknown" (should not normally happen alongside `isLocked: true`).
  final DateTime? lockedUntil;

  /// Attempts left before a lock kicks in. `-1` means "not tracked yet for
  /// this identifier" (distinct from `0`, which means "next failure locks
  /// the account") — [RateLimitBanner] only renders for values `>= 0`.
  final int attemptsRemaining;

  AuthFormState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? succeeded,
    bool? isLocked,
    DateTime? lockedUntil,
    bool clearLock = false,
    int? attemptsRemaining,
  }) {
    return AuthFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      succeeded: succeeded ?? this.succeeded,
      isLocked: clearLock ? false : (isLocked ?? this.isLocked),
      lockedUntil: clearLock ? null : (lockedUntil ?? this.lockedUntil),
      attemptsRemaining: clearLock
          ? -1
          : (attemptsRemaining ?? this.attemptsRemaining),
    );
  }

  @override
  List<Object?> get props => [
        isSubmitting,
        errorMessage,
        succeeded,
        isLocked,
        lockedUntil,
        attemptsRemaining,
      ];
}
