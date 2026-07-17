import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Swap this single provider to point the whole app at a different backend
/// (e.g. an in-memory fake for widget tests) — nothing downstream needs to
/// change.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Live stream of the signed-in user, `null` when signed out. [GoRouter]'s
/// redirect logic listens to this via [authStateChangeNotifierProvider].
final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
