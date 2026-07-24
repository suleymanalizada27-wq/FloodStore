# System Map

## Domain map (current + planned)

```
USER
 │
 ├── Auth                      [built]
 │      ├── Email/Google/Apple/Phone sign-in
 │      ├── Organization (business) accounts
 │      └── Security Center (sessions, MFA)
 │
 ├── Marketplace (B2C)         [partial]
 │      ├── Products / Categories / Search
 │      ├── Cart / Wishlist
 │      ├── Checkout            ← MISSING
 │      └── Orders              ← repository exists, no UI flow
 │
 ├── Business / Seller (B2B storefront side)   [partial]
 │      ├── Business account, Seller analytics, Loyalty
 │      └── Seller dashboard UI  ← MISSING
 │
 ├── Procurement (B2B buy side)  [foundation only]
 │      ├── RFQ (entity + repo exist, no UI/flow)
 │      ├── Inventory
 │      └── Warehouse
 │
 ├── Tender / Reverse auction    [NOT STARTED — see modules/TENDER_RFQ.md]
 │
 ├── Chat & Notifications        [foundation only]
 │      ├── Chat sessions/messages (entity + repo)
 │      ├── Notifications (entity + repo)
 │      └── Visual search (entity + repo — unclear if used by any screen yet)
 │
 ├── Logistics                   [NOT STARTED]
 │
 ├── Payments                    [NOT STARTED — must be server-side, see 08_PAYMENT_ARCHITECTURE.md]
 │
 ├── Admin                       [NOT STARTED]
 │
 ├── Analytics / Market Intelligence  [NOT STARTED]
 │
 └── AI Agents                   [NOT STARTED]
```

## Data flow (standard request path)

```
User
 ↓
Flutter Widget (presentation/)
 ↓
Riverpod Provider / Controller (application/)
 ↓
Repository interface (domain/)
 ↓
Firestore Repository impl (data/)
 ↓
Firestore
```

## Planned order flow (target — not fully built yet)

```
Cart → Checkout → Payment Intent (Cloud Function) → Payment confirmed (webhook)
     → Order created → Seller notified → Fulfillment → Shipping → Delivery → Invoice
```
Today: only `Cart` and a bare `Order` entity/repository exist. Everything from Checkout
onward is a gap — see `modules/ORDERS.md` and `08_PAYMENT_ARCHITECTURE.md`.

## Planned B2B procurement flow (target — not built yet)

```
Employee → Purchase Request → Manager Approval → RFQ → Supplier Quotes
   → Compare/Negotiate → Purchase Order → Payment → Delivery → Warehouse → Invoice
```
Today: `RFQ`, `Inventory`, `Warehouse` entities/repos exist in `procurement/`. Nothing above
"repository exists" is implemented. See `modules/PROCUREMENT.md` and `modules/TENDER_RFQ.md`.

## Buyer ↔ Seller relationship layer

This is a cross-cutting concern the vision doc calls out explicitly (this is not "just a
chatbot support widget" — it's how a buyer and a specific seller communicate about a specific
product/order/RFQ). Current state: `chat` feature has `ChatSession`/`ChatMessage` entities and
a Firestore repository, but no `application/` providers or `presentation/` screens wiring it to
product pages, order pages, or RFQs. See `modules/CHAT.md`.

## Who owns what (for agent task routing)

| Area of the system | Module doc | Firestore collections touched |
|---|---|---|
| Auth, sessions, security, org accounts | `modules/AUTH.md` | `users`, `organizations`, `members`, `invitationCodes`, `sessions`, `loginHistory` |
| Product catalog, cart, wishlist, checkout, orders | `modules/MARKETPLACE.md`, `modules/ORDERS.md` | `products`, `categories`, `variants`, `carts`, `wishlist(s)`, `orders`, `coupons`, `bundles`, `reviews`, `recommendations`, `recently_viewed`, `saved_carts`, `addresses` |
| Seller/business side | `modules/SELLER.md (and modules/B2B.md for company structure)` | `business_accounts`, `sellers`, `loyalty`, `loyalty_tiers` |
| B2B buy-side procurement | `modules/PROCUREMENT.md` | `rfqs`, `rfq_items`, `rfq_responses`, `rfq_response_items`, `inventory_items`, `warehouses` |
| Tenders / reverse auction | `modules/TENDER_RFQ.md` | none yet (new collections to design) |
| Chat, notifications, visual search | `modules/CHAT.md` | `chat_sessions`, `chat_messages`, `messages`, `notifications`, `scheduled_notifications`, `visual_search_history`, `visual_search_preferences` |
| Logistics | `modules/LOGISTICS.md` | none yet |
| Admin | `modules/ADMIN.md` | `feedback`, `settings` (partly), plus new ones TBD |
| Analytics | `modules/ANALYTICS.md` | `history`, `ad_campaigns`, plus new ones TBD |
| AI agents | `modules/AI.md` | reads across modules, writes none directly |

An agent assigned to "chat module" only needs `modules/CHAT.md` + this table row — not the
full `lib/` tree.
