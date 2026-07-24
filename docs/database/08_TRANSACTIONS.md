# Transactions

Operations that must be atomic (wrap in a single Postgres transaction / stored function):

| Operation | Why atomic |
|---|---|
| Checkout: create order + order_items + decrement/reserve stock + create payment intent record | Partial failure must not create an order without a stock reservation, or reserve stock without an order |
| Tender award: set `tender_awards` + `tenders.status='awarded'` + create `purchase_order` | Award and PO creation must not diverge |
| Payment webhook handling: update `payments.status` + `orders.status` + insert `order_status_history` row | Payment confirmation and order status must move together |
| Stock reservation release on cart/RFQ expiry | Prevent stock being held forever on abandoned carts |
| Seller payout run: mark `seller_payouts` paid + decrement outstanding balance | Never double-pay |

Implement these as Postgres functions (`09_DATABASE_FUNCTIONS.md`) called via RPC from Edge
Functions, not as multi-step client-side writes — the client should never be able to leave one
of these halfway done.
