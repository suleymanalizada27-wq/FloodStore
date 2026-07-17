/// Every third-party identity provider FloodStore can authenticate with.
///
/// This is the "Social Login abstraction" the auth expansion asked for: a
/// single enum plus a single dispatch method
/// ([SocialAuthDispatch.signIn]) so callers (controllers, and eventually
/// any future provider) don't need a bespoke `signInWithX()` call site per
/// button — one is added here only because [AuthRepository]'s existing
/// per-provider methods predate this pass and screens already call them
/// directly; new call sites should prefer dispatching through this enum.
enum SocialAuthProviderType {
  google,
  apple,
  microsoft,
  github;

  String get displayName => switch (this) {
        SocialAuthProviderType.google => 'Google',
        SocialAuthProviderType.apple => 'Apple',
        SocialAuthProviderType.microsoft => 'Microsoft',
        SocialAuthProviderType.github => 'GitHub',
      };
}
