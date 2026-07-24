# Seed Data

For local dev and the Supabase local emulator (once `12_MIGRATIONS.md` Phase 1 is underway),
seed a minimal realistic dataset so agents/developers don't test against an empty database:

- 3 organizations (1 verified, 1 pending, 1 unverified) with 2-3 members each
- 10-15 products across 3-4 categories with variants, at least one out-of-stock
- 2 open RFQs, 1 with supplier responses already submitted
- 1 tender in each mode (open, sealed, reverse_auction) at different stages
- A handful of orders across different statuses (pending, paid, shipped, delivered, refunded)
  so status-dependent UI can be tested without manually walking every order through its
  lifecycle each time
- A couple of conversations with message history, linked to a product and an order

Seed script location (once created): `supabase/seed.sql` or a Dart script under `tool/`.
Keep it idempotent (safe to re-run) and clearly separate from any production data path.
