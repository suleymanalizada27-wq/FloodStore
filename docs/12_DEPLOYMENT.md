# Deployment

## Current state
No deployment pipeline exists. `firebase.json` configures Android + Web Firebase apps
(project `floodstore-fbece`). `.github/workflows/opencode.yml` is an agent-runner config, not
a CI/CD pipeline.

## Target pipeline

```
Development → Staging → Production
```

- **CI (on every PR)**: `flutter analyze`, `flutter test`, `flutter build` (at least for one
  target platform) as a merge gate.
- **CD**: on merge to `main`, build + deploy web to Firebase Hosting (or wherever web is
  served), and produce signed Android/iOS builds for store submission (manual promotion to
  production recommended until the app is stable).
- **Secrets**: store provider keys, Supabase service role key (once it exists), and any AI
  provider keys in GitHub Actions secrets / Firebase environment config — never in the repo.
- **Environments**: at minimum separate Firebase projects (or Supabase projects, post-
  migration) for staging vs production so testing never touches real user/payment data.
- **Rollback**: keep the previous build's artifacts addressable; for the Postgres migration
  specifically, keep the Firestore data path readable during each feature's cutover window
  (`database/12_MIGRATIONS.md` Phase 4) as the rollback plan.

## Not yet decided
Hosting target for web (Firebase Hosting vs. other) is still open. Server runtime is
**resolved** — Supabase Edge Functions, per `decisions/ADR-004-PAYMENTS.md` — but the CI/CD
pipeline for deploying Edge Functions (Supabase CLI in GitHub Actions) doesn't exist yet and
blocks a deployment pipeline for anything beyond the current Firestore-backed client. See
`08_PAYMENT_ARCHITECTURE.md`.

**CI Pipeline Status**: ✅ Implemented - GitHub Actions workflow at `.github/workflows/ci.yml` runs `flutter analyze` and `flutter test` on every push and PR to main branch.
