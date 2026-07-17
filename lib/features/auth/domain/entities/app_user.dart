import 'package:equatable/equatable.dart';

/// Domain-level representation of an authenticated user.
///
/// This type is deliberately decoupled from `firebase_auth`'s `User` class
/// — the presentation and application layers only ever see [AppUser], so
/// the backend (Firebase today, anything else tomorrow) can change without
/// touching UI code.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  final String id;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        displayName,
        photoUrl,
        emailVerified,
      ];
}
