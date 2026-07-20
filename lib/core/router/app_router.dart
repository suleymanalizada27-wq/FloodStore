import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/providers/auth_providers.dart';
import '../../features/auth/application/providers/session_providers.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/organization_onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/security_center_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/marketplace/presentation/screens/cart_screen.dart';
import '../../features/marketplace/presentation/screens/checkout_screen.dart';
import '../../features/marketplace/presentation/screens/order_confirmation_screen.dart';
import '../../features/marketplace/presentation/screens/order_detail_screen.dart';
import '../../features/marketplace/presentation/screens/home_screen.dart';
import '../../features/marketplace/presentation/screens/products_screen.dart';
import '../../features/marketplace/presentation/screens/product_detail_screen.dart';
import '../../features/marketplace/presentation/screens/business_account_registration_screen.dart';
import 'auth_guards.dart';

abstract final class AppRoutes {
  static const splash = '/';

  /// The primary authentication destination. Renders the hero (logo,
  /// wordmark, tagline) plus the sign-in card — see [LoginScreen].
  static const auth = '/auth';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const phoneAuth = '/auth/phone';
  static const verifyEmail = '/auth/verify-email';
  static const organizationOnboarding = '/auth/organization';
  static const securityCenter = '/security';

  /// Placeholder destination reached only after a successful sign in —
  /// swap for the real home/marketplace shell route when it exists.
  static const home = '/home';
  static const marketplaceProducts = '/marketplace/products';
  static const productDetail = '/marketplace/products/:productId';

  // Marketplace routes
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderConfirmation = '/order/confirmation';
  static const orderDetail = '/order/detail';
  static const businessAccountRegister = '/business/register';
}

/// Bridges a Riverpod [Stream] provider to a [Listenable] so GoRouter can
/// react to auth changes without a manual polling shim.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    _subscription = ref.listen(authStateChangesProvider, (_, __) {
      notifyListeners();
    });
  }

  late final ProviderSubscription _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier(ref);
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final authState = ref.read(authStateChangesProvider);
      final user = authState.asData?.value;
      final location = state.matchedLocation;

      // Let the splash screen own its own timing/navigation.
      if (location == AppRoutes.splash) return null;

      // 1. Not signed in at all -> auth flow.
      final authRedirect = AuthGuards.requireAuth(user: user, location: location);
      if (authRedirect != null) return authRedirect;

      // 2. Signed in but idling on a sign-in/register screen -> home.
      final awayFromAuthRedirect = AuthGuards.redirectSignedInAwayFromAuth(
        user: user,
        location: location,
      );
      if (awayFromAuthRedirect != null) return awayFromAuthRedirect;

      // 3. Signed in, email/password, not verified -> verify-email.
      final verifyRedirect =
          AuthGuards.requireEmailVerified(user: user, location: location);
      if (verifyRedirect != null) return verifyRedirect;

      // 4. Idle-timeout: signed in without "keep me signed in" and past
      //    the idle window gets signed out and sent back to auth. Guests
      //    are exempt — there's no session to protect.
      if (user != null && user.email != null && location != AppRoutes.auth) {
        final sessionService = ref.read(sessionServiceProvider);
        final expired = await sessionService.isSessionExpired();
        if (AuthGuards.shouldForceReauth(sessionExpired: expired)) {
          await ref.read(authRepositoryProvider).signOut();
          await sessionService.clear();
          return AppRoutes.auth;
        }
        await sessionService.touchActivity();
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => _heroPage(const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) =>
            _heroPage(const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: AppRoutes.phoneAuth,
        pageBuilder: (context, state) => _heroPage(const PhoneOtpScreen()),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        pageBuilder: (context, state) =>
            _heroPage(const EmailVerificationScreen()),
      ),
      GoRoute(
        path: AppRoutes.organizationOnboarding,
        pageBuilder: (context, state) =>
            _heroPage(const OrganizationOnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.securityCenter,
        pageBuilder: (context, state) => _heroPage(const SecurityCenterScreen()),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
       GoRoute(
         path: AppRoutes.marketplaceProducts,
         pageBuilder: (context, state) => _heroPage(const ProductsScreen()),
       ),
       GoRoute(
         path: AppRoutes.productDetail,
         builder: (context, state) {
           final productId = state.pathParameters['productId']!;
           return ProductDetailScreen(productId: productId);
         },
       ),
      GoRoute(
        path: AppRoutes.cart,
        pageBuilder: (context, state) => _heroPage(const CartScreen()),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (context, state) => _heroPage(const CheckoutScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderConfirmation,
        pageBuilder: (context, state) => _heroPage(const OrderConfirmationScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        pageBuilder: (context, state) => _heroPage(const OrderDetailScreen()),
      ),
      GoRoute(
        path: AppRoutes.businessAccountRegister,
        pageBuilder: (context, state) => _heroPage(const BusinessAccountRegistrationScreen()),
      ),
    ],
  );
});

CustomTransitionPage _heroPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}