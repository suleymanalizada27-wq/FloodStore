# Module: Auth

**Folder:** `lib/features/auth/` · **Status:** mostly built · **Firestore collections today:**
`users`, `organizations`, `members`, `invitationCodes`, `sessions`, `loginHistory`

## What exists
Email/password, Google/Apple/Microsoft, phone/OTP sign-in; multi-step registration wizard;
forgot password; organization (business) accounts with onboarding + switcher; Security Center
(device sessions, MFA methods). See `03_FEATURES.md` "Auth" table for the file-level checklist.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `lib/features/auth/**` only
4. `docs/07_AUTH_SYSTEM.md` for the full flow diagrams
Do not read `marketplace`, `procurement`, `business`, or `chat` unless your task explicitly
says it touches shared auth state used by them.

## Known gaps
- Email verification: screen exists, backend trigger for the actual verification email needs
  confirming (no Cloud Functions in the project yet — see `05_FIREBASE.md`).
- `users` collection currently lives under `marketplace/domain/entities/user.dart` — it's a
  cross-cutting entity, arguably belongs to `auth/`. Don't silently move it; if you touch this,
  write a short ADR first (`docs/decisions/`).

## Postgres target
See `docs/database/01_DOMAIN_MODEL.md` "Identity" and "Business" sections
(`users`, `user_profiles`, `roles`/`permissions`, `organizations`, `organization_members`).
