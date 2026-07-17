import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import 'social_auth_provider_type.dart';

/// Routes a [SocialAuthProviderType] to the matching [AuthRepository]
/// method. Controllers call `repository.signIn(SocialAuthProviderType.x)`
/// instead of hardcoding `repository.signInWithX()`, which is what lets
/// [LoginController] add a provider (see `signInWithGithub`) without a new
/// controller method per button.
extension SocialAuthDispatch on AuthRepository {
  Future<AppUser> signIn(SocialAuthProviderType provider) => switch (provider) {
        SocialAuthProviderType.google => signInWithGoogle(),
        SocialAuthProviderType.apple => signInWithApple(),
        SocialAuthProviderType.microsoft => signInWithMicrosoft(),
        SocialAuthProviderType.github => signInWithGithub(),
      };
}
