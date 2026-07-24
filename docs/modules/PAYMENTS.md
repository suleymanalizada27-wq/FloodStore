# Module: Payments

**Folder:** target `lib/features/payments/` (does not exist) · **Status:** not started ·
**This module has zero client-side business logic by design.**

See `docs/08_PAYMENT_ARCHITECTURE.md` for the full architecture — this file is a short pointer
so it shows up in module routing.

## One-line summary
The client creates a payment intent request and displays a payment UI (hosted by whatever
provider is chosen — e.g. Stripe). It never decides or writes `paid`/`failed`/`refunded`
status. That happens server-side (Cloud Function today has none — this is why Cloud Functions
or a Supabase Edge Function is a **prerequisite**, not optional, for this module — see
`docs/05_FIREBASE.md` and `docs/database/09_DATABASE_FUNCTIONS.md`).

## What an agent working on this module needs to read
1. `docs/08_PAYMENT_ARCHITECTURE.md` (full read, not optional)
2. `docs/database/03_TABLES.md` `payments` table, `07_RLS_POLICIES.md` payments row
3. `docs/modules/ORDERS.md` for the checkout handoff point
