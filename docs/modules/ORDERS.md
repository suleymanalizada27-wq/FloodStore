# Module: Orders (checkout → fulfillment)

**Folder:** `lib/features/marketplace/` (orders currently live inside marketplace, not a
separate feature folder) · **Status:** partial — order screens/repo exist, **checkout is a
stub, no payment integration** · **Firestore collections today:** `orders`

## Scope
Owns the path from Checkout through to a completed order: address, payment method selection,
order review, order confirmation, order history/detail, status tracking.

## What exists
`order.dart` entity, `firestore_order_repository.dart`, `order_confirmation_screen.dart`,
`order_detail_screen.dart`. `checkout_screen.dart` exists as a placeholder only.

## What's missing
- A real `Checkout` entity/repository (address + payment method + review step).
- Payment integration — **do not build this without reading
  `docs/08_PAYMENT_ARCHITECTURE.md` first.** Payment status must never be a client-writable
  field.
- Order status transitions wired to actual events (payment confirmed → seller notified →
  fulfillment → shipped → delivered) — currently there's no mechanism driving status changes.
- Returns/refunds flow.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `docs/08_PAYMENT_ARCHITECTURE.md` (mandatory before touching checkout/payment)
4. `lib/features/marketplace/**` (order + checkout related files only)
5. `docs/database/03_TABLES.md` `orders`/`payments` tables (target model)
