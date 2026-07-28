# Payment Architecture

## Current state: no real payment integration — and an active fake-payment security hole

There is no real payment provider integration in the codebase. But `checkout_screen.dart` is
**not** a stub — it's a complete UI that calls `_placeOrder()`, which writes
`PaymentInfo(status: 'paid', providerPaymentId: 'mock_payment_<timestamp>')` straight to
Firestore client-side and marks the order `OrderStatus.confirmed`. Combined with the missing
`firestore.rules` (`06_FIREBASE_RULES.md`), this is a live, exploitable "free order" path
today, not a future risk. See `docs/modules/ORDERS.md` for the fix required before anything
else in that module. A `transactions` collection is also referenced in code but appears to be
placeholder/dead — verify before building on it (`docs/04_DATABASE_SCHEMA.md`).

## Non-negotiable rule

**Payment status is never decided or written by the Flutter client.** The client's job stops
at "display a payment UI and tell the server a payment attempt started." Confirmation,
success/failure, and any state that unlocks money (order marked paid, seller payout released)
must be written by server-side code that verifies the payment provider's own signal (webhook),
not by the client saying "I paid."

This is currently a **blocking gap**: the project has no Cloud Functions (`05_FIREBASE.md`)
and no Postgres/Supabase Edge Functions yet. Payments cannot ship safely until one of those
exists.

## Target flow

```
Buyer → Checkout → create Payment Intent (server-side call)
     → Payment Provider UI (client)
     → Provider sends webhook to server on success/failure
     → Server verifies webhook signature, calls confirm_order_payment()
        (docs/database/09_DATABASE_FUNCTIONS.md)
     → orders.status updated, order_status_history row inserted, buyer/seller notified
```

## Required pieces (in build order)

1. **Resolved (ADR-004):** server-side runtime is **Supabase Edge Functions**, not Firebase
   Cloud Functions — see `docs/decisions/ADR-004-PAYMENTS.md`. Payments is built directly on
   the Postgres/Supabase target from the start.
2. Payment provider selection — **still open.** Stripe is the default placeholder in
   `docs/database/03_TABLES.md`; confirm regional coverage (Azerbaijan), payout currency, and
   commission model before committing (`docs/decisions/ADR-004-PAYMENTS.md` "Open" section).
3. `payments`/`payment_transactions`/`payment_webhooks` tables + RLS
   (`docs/database/07_RLS_POLICIES.md`) — server-only writes.
4. Idempotent webhook handler (safe against provider retry/redelivery).
5. Split payments / platform commission / seller payout logic
   (`seller_payouts`, `platform_commissions` in `docs/database/03_TABLES.md`).
6. Refund/partial refund flow tied to `returns`/`refunds`.

## Do not

- Store card details anywhere in Firestore/Postgres directly — use the provider's tokenization
  (Stripe Elements/PaymentSheet or equivalent) so raw card data never touches FloodStore's
  servers.
- Let a client set `orders.status = 'paid'` directly, in Firestore rules or Postgres RLS.

## Coupon Handling Note

Coupon discount calculation is currently client-side for UI purposes in the cart screen;
server-side validation must be performed when creating the order (via Cloud Functions/Supabase
Edge Functions) to prevent tampering. The coupon application flow in the UI should be
considered a preview only, with final validation occurring server-side during order creation.
