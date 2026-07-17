import 'package:equatable/equatable.dart';

/// Every second factor FloodStore's architecture anticipates supporting.
/// Only the *shape* is added in this part — no method has a working
/// enrollment screen yet, matching the "MFA (architecture)" scope of this
/// pass. [FirebaseAuthRepository]'s MFA methods are wired to Firebase's
/// multi-factor APIs but intentionally surface `UnimplementedError` until
/// the enrollment UI (Part 3+) exists, so nothing silently no-ops.
enum MfaMethod {
  sms,
  authenticatorApp,
  email;

  String get label => switch (this) {
        MfaMethod.sms => 'SMS code',
        MfaMethod.authenticatorApp => 'Authenticator app',
        MfaMethod.email => 'Email code',
      };
}

/// A second-factor challenge issued mid sign-in, once a user has at least
/// one [MfaMethod] enrolled. [AuthRepository.signInWithEmail] (and the
/// social/phone equivalents) will, once fully wired, either resolve with an
/// [AppUser] directly or throw an [MfaChallengeRequired] carrying one of
/// these so the controller can route to a (future) challenge screen instead
/// of surfacing a generic [AuthFailure].
class MfaChallenge extends Equatable {
  const MfaChallenge({
    required this.method,
    required this.resolverTicket,
    this.maskedDestination,
  });

  /// Which factor the user needs to complete.
  final MfaMethod method;

  /// Opaque handle (Firebase's `MultiFactorResolver` session id, in the
  /// real implementation) needed to finish the challenge. Stored via
  /// [SecureTokenService.savePendingMfaTicket] so it survives a
  /// backgrounded app.
  final String resolverTicket;

  /// e.g. "+1 •••• ••92" or "j••••@example.com" — safe to render directly.
  final String? maskedDestination;

  @override
  List<Object?> get props => [method, resolverTicket, maskedDestination];
}

/// Thrown by the repository when a credential was valid but a second
/// factor is still required to complete sign-in.
class MfaChallengeRequired implements Exception {
  const MfaChallengeRequired(this.challenge);

  final MfaChallenge challenge;
}
