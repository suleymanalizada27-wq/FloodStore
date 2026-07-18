# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development Setup
- Install dependencies: `flutter pub get`
- Configure Firebase: `dart pub global activate flutterfire_cli` then `flutterfire configure`
- Run the app: `flutter run`
- Run tests: `flutter test`

### Development Workflow
- State management uses Flutter Riverpod (flutter_riverpod: ^2.5.1)
- Routing uses GoRouter (go_router: ^14.2.0)
- State management follows Riverpod patterns with providers in `application/providers/` and state in `application/state/`
- Firebase services are abstracted through repositories in `data/repositories/` implementing domain interfaces from `domain/repositories/`
- UI follows Material Design with custom theme in `lib/core/theme/`

## Architecture Overview

This FloodStore authentication module follows Clean Architecture principles with Riverpod for state management:

### Layer Structure
```
lib/
  core/                 # Cross-cutting concerns
    constants/          # App-wide constants
    router/             # GoRouter configuration + auth guards
    theme/              # Theme data, colors, text styles, spacing
    widgets/            # Reusable UI components (GlassCard, BreathingLogo, etc)
    services/           # Firebase services (AuthRateLimiter, SecureTokenService, etc)
  
  features/             # Feature-based organization
    auth/               # Authentication feature
      domain/           # Business logic entities & interfaces
        entities/       # AppUser, AuthFailure, RegisterPayload models
        repositories/   # Abstract repository interfaces (AuthRepository)
        services/       # Domain services if needed
      data/             # Firebase implementations
        repositories/   # Concrete implementations (FirebaseAuthRepository)
      application/      # Riverpod providers & state management
        providers/      # Riverpod providers (authProvider, etc)
        state/          # State classes (AuthFormState, etc)
      presentation/     # UI layer
        screens/        # LoginScreen, RegisterScreen, ForgotPasswordScreen
        widgets/        # Feature-specific widgets (AuthShell, AuthErrorBanner, etc)
    splash/             # Splash screen feature
```

### Key Architectural Principles
-Appropriate Practices
- Firebase dependencies are isolated to the data layer (`data/repositories/`)
- Domain layer contains pure Dart entities and interfaces (no Firebase imports)
- Presentation layer depends only on application layer (providers/states)
- Authentication guards in `core/router/auth_guards.dart` protect routes
- Theme values should be sourced from `lib/core/theme/` (app_colors.dart, app_text_styles.dart)
- Reusable UI components live in `core/widgets/` (GlassCard, BreathingLogo, etc)

## Testing
- Unit/widget tests live in `test/` directory
- Run tests with `flutter test`
- Follow existing test patterns in `widget_test.dart` using WidgetTester and pump

## Firebase Setup
After running `flutterfire configure`:
1. Enable required providers in Firebase Console (Email/Password, Google, Apple, Microsoft)
2. Add platform-specific configuration files:
   - iOS: GoogleService-Info.plist + configure Sign in with Apple capability
   - Android: google-services.json + SHA-1/256 fingerprints in Firebase console

## Code Style
- Follows `flutter_lints: ^4.0.0` (see analysis_options.yaml)
- Prefers const constructors and immutable widgets where possible
- Uses single quotes for strings
- Requires explicit return types on functions
- Domain entities should extend Equatable for value equality
