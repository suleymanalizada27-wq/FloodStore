# Auth System

## Providers
Email/password, Google, Apple, Phone/OTP. GitHub/Microsoft go through Firebase Auth's generic
`OAuthProvider` (`FirebaseAuthRepository`) — no dedicated package needed for either.

## Flow
```
Register (multi-step wizard) → Email Verification → Login → MFA (if enabled) → Session
   → Role/Org detection → Route Guard (auth_guards.dart)
```

## Session & security
- `secure_token_service.dart` — encrypted-at-rest token storage (Keychain/Keystore)
- `session_service.dart` — session lifecycle
- `auth_rate_limiter.dart` — throttles auth attempts
- Security Center screen surfaces active device sessions + MFA methods per user

## Organization (business) accounts
A user can belong to one or more organizations (`organization.dart`,
`firestore_organization_repository.dart`). `organization_switcher.dart` lets a user move
between personal and org context. This is the seed of the B2B company model — see
`docs/modules/B2B.md` for how it's meant to grow (departments, budgets, approvals).

## Route guards
`lib/core/router/auth_guards.dart` gates routes by auth state; extend here when adding
role-gated routes (e.g. seller dashboard, admin panel) rather than checking auth state ad-hoc
inside individual screens.

## Target (Postgres/Supabase)
**Resolved (ADR-003):** Firebase Auth stays as the identity provider. Postgres/Supabase stores
profile data keyed by the Firebase UID — see `docs/decisions/ADR-003-AUTH.md` for the full
decision and its consequence for RLS policies (no native `auth.uid()`; verify the Firebase ID
token server-side instead).
