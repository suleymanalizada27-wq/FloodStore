# FloodStore — Authentication Experience

A premium, production-ready authentication flow for the FloodStore
marketplace: Splash → Sign In → Create Account → Forgot Password, built
with Flutter, Material 3, Riverpod, GoRouter and Firebase Auth.

## What's included

- **Splash Screen** — fade-in from black, breathing logo, ambient
  particles, 2.5s timed hero transition into the auth flow.
- **Login Screen** — email/password, remember me, forgot password,
  Google / Apple / Microsoft / Phone continue buttons, glassmorphic card.
- **Register Screen** — first/last name, username, email, phone, password
  + confirm, country picker, terms agreement.
- **Forgot Password Screen** — email submission with an animated success
  confirmation state.
- **Reusable UI kit** — `GlassCard`, `PremiumButton`, `PremiumTextField`,
  `SocialAuthButton`, `BreathingLogo`, `ParticleBackground`, `FadeSlideIn`.
- **Clean Architecture** — `domain` (entities + repository contracts),
  `data` (Firebase implementation), `application` (Riverpod controllers /
  providers), `presentation` (screens + widgets). No feature ever imports
  `firebase_auth` directly except the one repository implementation.

## Folder structure

```
lib/
  core/
    constants/        # cross-cutting constants
    router/            # GoRouter config + auth-aware redirects
    theme/              # colors, type scale, ThemeData
    widgets/            # brand-agnostic reusable UI primitives
  features/
    splash/
      presentation/
    auth/
      domain/
        entities/       # AppUser
        repositories/   # AuthRepository contract, RegisterPayload, AuthFailure
      data/
        repositories/   # FirebaseAuthRepository
      application/
        providers/      # Riverpod providers + StateNotifier controllers
        state/           # AuthFormState
      presentation/
        screens/         # LoginScreen, RegisterScreen, ForgotPasswordScreen
        widgets/          # AuthShell, AuthErrorBanner, OrDivider, CountrySelectField
  main.dart
```

## Setup

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Wire up Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`. Then in `lib/main.dart`,
   uncomment the import and pass
   `options: DefaultFirebaseOptions.currentPlatform` to
   `Firebase.initializeApp`.

3. **Enable providers in the Firebase console**
   - Authentication → Sign-in method → enable Email/Password, Google,
     Apple, Phone.
   - For Microsoft: register an OAuth app in Azure AD, then add
     `microsoft.com` as an OAuth provider in the Firebase console (this
     app already calls it via `FirebaseAuth.signInWithProvider`, no extra
     package needed).

4. **Platform-specific config**
   - iOS: add the `GoogleService-Info.plist`, enable Sign in with Apple
     capability in Xcode, configure the URL scheme for Google Sign-In.
   - Android: add `google-services.json`, set the SHA-1/256 fingerprints
     in the Firebase console for Google Sign-In.

5. **Run**
   ```bash
   flutter run
   ```

## Design tokens

All colors live in `lib/core/theme/app_colors.dart` and all type styles in
`lib/core/theme/app_text_styles.dart` — never hardcode a hex value or a
`TextStyle` inline in a screen; extend those two files instead.

## Extending the flow

- **Phone auth**: `AuthRepository.startPhoneVerification` /
  `verifyPhoneCode` are already implemented in `FirebaseAuthRepository`.
  Wire the "Continue with Phone" button (currently a `TODO` in
  `login_screen.dart`) to a new OTP entry screen using the same
  `AuthShell` + `GlassCard` pattern as the other screens.
- **Post sign-in destination**: replace `_HomePlaceholder` in
  `app_router.dart` with the real marketplace shell.
