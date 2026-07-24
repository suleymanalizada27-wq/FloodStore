# Constraints

## Foreign keys
Default `on delete restrict` unless explicitly noted. Exceptions:
- `product_variants.product_id` → `on delete cascade` (variant has no meaning without product)
- `cart_items.cart_id`, `wishlist_items.wishlist_id` → `on delete cascade`
- `order_items.order_id` → `on delete restrict` (never cascade-delete order history)

## Check constraints
- `orders.total >= 0`, `payments.amount > 0`
- `tender_bids.price > 0`
- `products.base_price >= 0`
- `seller_reputation.trust_score between 0 and 100`

## Uniqueness
- `users.email`, `users.phone` (nullable-safe unique — allow multiple nulls)
- `product_variants.sku`
- `company_members (company_id, user_id)` — one membership row per user per company
- `tender_participants (tender_id, seller_id)`

## Not-null discipline
Every FK that isn't explicitly optional in `01_DOMAIN_MODEL.md` / `02_ENTITY_RELATIONSHIPS.md`
is `not null`. If you're adding a nullable FK, document *why* right next to the column (e.g.
`conversations.context_id` is nullable because a conversation can exist without a linked
product/order/rfq/tender — general support chat).
