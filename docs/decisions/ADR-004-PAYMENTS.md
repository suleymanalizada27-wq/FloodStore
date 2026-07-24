# ADR-004: Payment provider & server runtime

**Status:** 🟡 Partially accepted (2026-07) — runtime decided, provider still open

**Decision (runtime — Accepted):** Payments are built directly on **Supabase Edge Functions +
PostgreSQL**, not Firebase Cloud Functions. Payments has no existing Firestore implementation
to migrate away from, so building it once on the target stack is strictly less work than
building it on Firebase Functions first and migrating later.

```
Flutter
   ↓
Supabase Edge Function  (createPaymentIntent, handles webhook)
   ↓
Payment Provider
   ↓
Webhook → Supabase Edge Function → confirm_order_payment() (Postgres function)
   ↓
PostgreSQL (payments, orders.status, order_status_history)
```

This makes Payments (along with `chat`, per `docs/database/12_MIGRATIONS.md`) one of the
first real features on the Postgres/Supabase stack — reference `orders.id` as a plain
UUID/text foreign key even while `orders` itself is still Firestore-backed, until the
marketplace/orders migration (Phase in `12_MIGRATIONS.md`) catches up. Do not build a second
Firebase-Functions-based payment path "in the meantime" — there is no meantime; nothing ships
until the Edge Function runtime exists regardless of which platform it's on, so pick the
target one now.

**Decision (auth boundary — Accepted, follows ADR-003):** Payment Edge Functions verify the
Firebase ID token (not a Supabase session) to identify the caller, consistent with ADR-003.

**Open — provider not yet chosen:** Stripe remains the working placeholder in
`docs/database/03_TABLES.md` (`payments.provider`), but is **not confirmed**. Before
implementation starts, confirm:
- Regional payment method coverage for Azerbaijan (cards, local payment rails)
- Payout currency / cross-border seller payout support
- Platform commission / split-payment model fit (Stripe Connect vs. manual payout batching
  via `seller_payouts`, `docs/database/03_TABLES.md`)

**This ADR moves to fully Accepted once the provider line above is filled in and confirmed.**
