# Module: Orders (checkout → fulfillment)

**Folder:** `lib/features/marketplace/` (orders currently live inside marketplace, not a
separate feature folder) · **Status:** partial — order screens/repo exist, **checkout is a
stub, no payment integration** · **Firestore collections today:** `orders`

## Scope
Owns the path from Checkout through to a completed order: address, payment method selection,
order review, order confirmation, order history/detail, status tracking.

## What exists
`order.dart` entity, `firestore_order_repository.dart`, `order_confirmation_screen.dart`,
`order_detail_screen.dart`, and a **fully built** `checkout_screen.dart` (address form,
delivery option, payment method selection, order review).

## 🔴 Known live security hole — fix before anything else in this module
`checkout_screen.dart`'s `_placeOrder()` writes `PaymentInfo(status: 'paid',
providerPaymentId: 'mock_payment_<timestamp>')` directly to Firestore via
`orderRepositoryProvider.addPaymentInfo()`, and separately calls `updateOrderStatus(orderId,
OrderStatus.confirmed)` — both client-side, both fully forgeable, with no real payment provider
call anywhere in the flow. Combined with the missing `firestore.rules`
(`docs/06_FIREBASE_RULES.md`), any client can currently mark any order "paid" for free. **Do
not treat this as "checkout is unfinished" — treat it as "checkout has a live exploit."**

## What's missing / must change
- Remove the client-side `status: 'paid'` write. Order/payment status must never be
  client-writable — see `docs/08_PAYMENT_ARCHITECTURE.md`.
- Real payment provider integration (server-verified) before `_placeOrder()` is allowed to
  reach `OrderStatus.confirmed`.
- Until real payment integration ships, the mock path should either be removed or explicitly
  gated (e.g. behind a dev-only flag) so it can't ship to production as-is.
- Order status transitions wired to actual events (payment confirmed → seller notified →
  fulfillment → shipped → delivered) — currently there's no mechanism driving status changes.
- Returns/refunds flow.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `docs/08_PAYMENT_ARCHITECTURE.md` (mandatory before touching checkout/payment)
4. `lib/features/marketplace/**` (order + checkout related files only)
5. `docs/database/03_TABLES.md` `orders`/`payments` tables (target model)
