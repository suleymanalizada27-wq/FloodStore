# Testing

## Current state
Only the default `test/widget_test.dart` placeholder exists. No unit, integration, or
Firestore-rules tests.

## Target strategy

```
Feature → Unit tests (domain logic, repositories with fakes)
        → Widget tests (screens in isolation)
        → Integration tests (multi-screen flows: browse → cart → checkout)
        → Security rules tests (Firestore Emulator / Postgres RLS tests)
```

## Priorities (in order)

1. **Firestore/RLS rules tests** — as soon as `06_FIREBASE_RULES.md`/`database/07_RLS_POLICIES.md`
   have real rules, test them against the Emulator Suite (`05_FIREBASE.md`) or a local Supabase
   instance. This is the highest-leverage test category given the current lack of rules.
2. **Payment webhook idempotency tests** — before payments ship, per `08_PAYMENT_ARCHITECTURE.md`.
3. **Repository unit tests** with fake/in-memory implementations of the domain repository
   interfaces (the interface-based Clean Architecture already in place makes this cheap).
4. **Critical-path widget/integration tests**: register/login, add-to-cart, checkout, RFQ
   submission, tender bid submission.

## Convention
Test files mirror `lib/` structure under `test/`, e.g.
`test/features/marketplace/domain/entities/product_test.dart`.

## CI
`.github/workflows/opencode.yml` exists but is an agent-runner config, not a build/test
pipeline. Add a real `flutter test` + `flutter analyze` GitHub Actions workflow — see
`12_DEPLOYMENT.md`.
