# Migrations — Firebase → Postgres/Supabase

## Current reality
The live app runs entirely on Firestore today (`docs/04_DATABASE_SCHEMA.md`). This plan is the
target path, executed feature-by-feature, not a big-bang rewrite.

## Phased plan

**Phase 1 — Stand up Supabase, no traffic yet**
- Create Supabase project, apply `03_TABLES.md` schema as SQL migrations (versioned under a
  new `supabase/migrations/` folder in the repo).
- Apply `07_RLS_POLICIES.md`.
- No Flutter code changes yet.

**Phase 2 — Parallel repository implementation, one feature at a time**
- Pick the feature with the fewest existing users/data to migrate first (candidate: `chat`,
  since it has almost no data yet — good first migration to prove the pattern).
- Write `data/repositories/supabase_<x>_repository.dart` implementing the same
  `domain/repositories/<x>_repository.dart` interface already used by the Firestore version.
- Add a feature flag / provider override so the app can point at either implementation.
- This only works cleanly because Clean Architecture is enforced — see `docs/01_ARCHITECTURE.md`.

**Phase 3 — Backfill data**
- Write a one-off script (Node/Dart, run once) reading from Firestore, writing to Postgres,
  per collection-to-table mapping (see mapping table below).
- Validate row counts and spot-check records match.

**Phase 4 — Cut over**
- Flip the provider to the Supabase implementation for that feature.
- Keep the Firestore data read-only for a rollback window (do not delete).
- Monitor error rates before moving to the next feature.

**Phase 5 — Decommission**
- Once all features are migrated and stable, remove the Firestore repository implementations
  and the `firebase_*` dependencies still in use only for data (Auth may be migrated
  separately/later or kept — see `decisions/ADR-003-AUTH.md`).

## Suggested migration order

Updated per the decisions in `ADR-003-AUTH.md`, `ADR-004-PAYMENTS.md`, and
`ADR-006-IDENTITY-MODEL.md`. The full 13-step version (through Tender/Logistics/Admin/
Analytics/AI) lives in `15_MIGRATION_MATRIX.md` — this is the summary for the near-term:

1. **Identity / Organizations** (`users`, `organizations`, `organization_members`) — everything
   else has a foreign key into this, so it goes first, even though the current Firestore
   `organizations`/`members` collections are otherwise fine as-is. Per ADR-006, resolve the
   `organizations`/`business_accounts`/`sellers` merge conceptually here even though the full
   Seller migration happens later.
2. `chat` (least data, proves the pattern end to end)
3. **Payments** — no existing Firestore implementation to migrate away from (per ADR-004),
   build directly on Postgres/Supabase Edge Functions now rather than later
4. `procurement` (still foundation-only, cheap to redo directly in Postgres instead of
   finishing it in Firestore first — avoids double work)
5. `business` / seller (complete the `organizations`/`seller_profiles` merge from ADR-006 here)
6. `marketplace` core (products, cart, wishlist) — highest risk, most data, do last among the
   "already partially built" features
7. New modules (`b2b`, `tender`, `logistics`, `admin`, `analytics`, `ai`) — **build these
   directly on Postgres from the start**, don't build them on Firestore first. See
   `15_MIGRATION_MATRIX.md` for the detailed 7-13 breakdown of this step.

## Firestore collection → Postgres table mapping

**Canonical, full mapping now lives in `15_MIGRATION_MATRIX.md`** (this section previously
had a partial duplicate table — removed to avoid the two drifting apart, per the
"one source of truth" principle: `docs/database/` is canonical for the target model, and
within this folder, `15_MIGRATION_MATRIX.md` is canonical for the row-by-row mapping). Use
this file (`12_MIGRATIONS.md`) for the phased plan and ordering; use `15_MIGRATION_MATRIX.md`
when you're actually migrating a specific collection and need to know its target table, status,
and required action.

## Open questions to resolve before Phase 1 starts

~~Does Supabase Auth replace Firebase Auth...~~ **Resolved** — see
`decisions/ADR-003-AUTH.md` (Firebase Auth stays; Postgres stores profile data keyed by
Firebase UID).

~~`business_accounts` vs `sellers` duplication...~~ **Resolved** — see
`decisions/ADR-006-IDENTITY-MODEL.md` (merges into `organizations` + `seller_profiles`).
