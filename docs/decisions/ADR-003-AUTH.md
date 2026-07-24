# ADR-003: Auth strategy during/after Postgres migration

**Status:** ✅ Accepted (2026-07) — this unblocks `docs/database/12_MIGRATIONS.md` Phase 1

**Decision:** Firebase Auth stays as the identity provider. Postgres/Supabase does **not**
take over authentication. Every Postgres table that needs to know "which user" stores the
Firebase UID as a plain `text`/`uuid`-compatible foreign key (`users.id = firebase_uid`).

```
Firebase Auth
      │  (Firebase UID)
      ▼
Supabase PostgreSQL
      │
      ├── users (id = firebase_uid)
      ├── organizations
      ├── roles
      └── memberships
```

**Why:** The existing auth feature (`docs/modules/AUTH.md`) is the most complete part of the
codebase — email/social/phone/OTP, MFA, Security Center, rate limiting, session management.
Rebuilding it on Supabase Auth would be pure risk (password re-hash isn't portable between
providers; existing users would need a forced reset) for no functional gain, since Option B
gets the relational database benefit (ADR-002) without touching auth at all.

**Consequence — RLS policies cannot use Supabase's native `auth.uid()` helper.** Every RLS
policy in `docs/database/07_RLS_POLICIES.md` must instead:
1. Verify the Firebase ID token server-side (in the Edge Function / API layer sitting in front
   of Postgres — see ADR-004), and
2. Set a Postgres session variable / use a `security definer` function that reads a verified
   claim, rather than relying on Supabase's built-in JWT-to-`auth.uid()` mapping.

This is more work per RLS policy than the Supabase-Auth-native path would have been — accepted
trade-off for not touching a working auth system.

**Revisit if:** Supabase Auth's feature parity is later confirmed sufficient AND a clean,
low-risk user migration path exists (e.g. Supabase supports importing Firebase Auth users
directly with password hashes intact — verify this before ever reopening this ADR).

**Alternatives considered:** Migrate to Supabase Auth (Option A) — rejected, see above.
