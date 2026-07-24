# Module: Admin

**Folder:** target `lib/features/admin/` (does not exist) · **Status:** not started ·
**Firestore collections today:** `feedback` (unassigned, likely belongs here), `settings`
(partly)

## Scope
Platform moderation and operations: user/seller verification review (KYC/KYB approval queue),
dispute resolution, content moderation, audit log viewer, feature flags/settings, fraud alert
review.

## Critical rule
Admin actions that change trust-sensitive state (verify a seller, resolve a dispute, ban a
user) must go through the same server-side-only pattern as payments — an admin role check
alone in the client is not security, it's UI convenience. Enforce via RLS (Postgres target,
`docs/database/07_RLS_POLICIES.md`) or Firestore rules (`docs/06_FIREBASE_RULES.md`) checking
a real role claim, not a client-supplied flag.

## Data model
`docs/database/01_DOMAIN_MODEL.md` "Admin / Security": `audit_logs`, `admin_actions`,
`security_events`, `fraud_alerts`. Build on Postgres/Supabase, not Firestore.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `docs/10_SECURITY.md`
4. `docs/database/01_DOMAIN_MODEL.md` "Admin / Security", `docs/database/11_AUDIT_LOGGING.md`
