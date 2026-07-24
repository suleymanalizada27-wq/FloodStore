# Database Functions

Functions that should live in Postgres (as `security definer` where they need to bypass RLS
for a controlled write), not in the Flutter client.

| Function | Purpose |
|---|---|
| `confirm_order_payment(order_id, payment_ref)` | Called by the payment webhook Edge Function. Atomically updates `payments.status`, `orders.status`, inserts `order_status_history`. |
| `award_tender(tender_id, winning_bid_id)` | Sets `tender_awards`, `tenders.status`, creates `purchase_orders` row. Only callable by the tender's owning company (checked inside the function, not just RLS). |
| `recompute_seller_reputation(seller_id)` | Recalculates `trust_score`, `on_time_delivery_pct`, `cancellation_rate`, `dispute_rate` from `orders`/`disputes`/`reviews`. Called by a trigger after relevant inserts, or on a schedule. |
| `reserve_stock(variant_id, qty, cart_id)` / `release_stock_reservation(reservation_id)` | Atomic stock hold/release, prevents overselling during checkout. |
| `submit_sealed_bid(tender_id, seller_id, price, delivery_days)` | Enforces one bid per (tender, seller, round) and blocks visibility to other bidders until evaluation phase — belt-and-suspenders alongside the RLS policy in `07_RLS_POLICIES.md`. |

Each function should be idempotent where it can be (safe to retry on webhook redelivery, for
example) — note this explicitly in the function's SQL comment when implemented.
