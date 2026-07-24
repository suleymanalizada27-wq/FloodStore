# Database Schema (Firestore — current, live system)

> **Scope of this file:** this is the **current Firestore reality only** — what collections
> exist today and who owns them. It is **not** the source of truth for the target database
> design. For target schema, relationships, RLS, and table-level detail, **`docs/database/` is
> canonical** — see `docs/database/00_DATABASE_OVERVIEW.md`. If this file and `docs/database/`
> ever appear to disagree on what the *target* looks like, `docs/database/` wins; this file
> only describes what's live in Firestore right now, and should be retired collection-by-
> collection as each one migrates (tracked in `docs/database/15_MIGRATION_MATRIX.md`).

This lists every collection currently referenced in code (found via
`grep -r ".collection("` across `lib/`), grouped by owning module. **Field-level schema is
defined by the corresponding entity class in `domain/entities/` — that file is the source of
truth for fields; this doc is the source of truth for which Firestore collections exist today
and who owns them.**

Agents: when you touch a collection, update its row here (owner module, and a one-line purpose
if missing). When you add a new collection, add a new row **and** add a rule for it in
`06_FIREBASE_RULES.md`.

## Auth / Organization

| Collection | Entity file | Purpose |
|---|---|---|
| `users` | `marketplace/domain/entities/user.dart` (shared user record — consider moving to `auth/`) | Core user profile |
| `organizations` | `auth/domain/entities/organization.dart` | Business/company accounts |
| `members` | — | Organization membership records |
| `invitationCodes` | — | Org invite codes |
| `sessions` | `auth/domain/entities/device_session.dart` | Active device sessions (Security Center) |
| `loginHistory` | — | Login audit trail |
| `addresses` | — | User/org shipping addresses |

## Marketplace (B2C)

| Collection | Entity file | Purpose |
|---|---|---|
| `products` | `marketplace/domain/entities/product.dart` | Product catalog |
| `categories` | `marketplace/domain/entities/category.dart` | Category tree |
| `variants` | `marketplace/domain/entities/product_variant.dart` | Product variants (size/color/etc.) |
| `carts` | `marketplace/domain/entities/cart.dart` | Shopping carts |
| `saved_carts` | — | Saved-for-later carts |
| `wishlist` / `wishlists` | `marketplace/domain/entities/wishlist.dart` | ⚠️ two collection names in code (`wishlist` and `wishlists`) — **needs reconciliation, likely a bug** |
| `orders` | `marketplace/domain/entities/order.dart` | Orders |
| `reviews` | `marketplace/domain/entities/review.dart` | Product reviews/ratings |
| `coupons` | `marketplace/domain/entities/coupon.dart` | Discount coupons |
| `bundles` | — | Product bundles (no dedicated entity found — verify) |
| `recommendations` | `marketplace/domain/entities/recommendation.dart` | Personalized recs |
| `recently_viewed` | — | Recently viewed products |
| `ad_campaigns` | — | Marketing/ad campaigns |
| `history` | — | Price history (`price_history.dart`) or generic activity — verify which |

## Business / Seller

| Collection | Entity file | Purpose |
|---|---|---|
| `business_accounts` | `business/domain/entities/business_account.dart` | Seller/business profile |
| `sellers` | — | Seller records (relation to `business_accounts` unclear — verify no duplication) |
| `loyalty` | `business/domain/entities/loyalty.dart` | Loyalty program state |
| `loyalty_tiers` | — | Loyalty tier definitions |

## Procurement (B2B)

| Collection | Entity file | Purpose |
|---|---|---|
| `rfqs` | `procurement/domain/entities/rfq.dart` | RFQ headers |
| `rfq_items` | — | RFQ line items |
| `rfq_responses` | — | Supplier quotes against an RFQ |
| `rfq_response_items` | — | Line items within a quote |
| `inventory_items` | `procurement/domain/entities/inventory.dart` | Inventory tracking |
| `warehouses` | `procurement/domain/entities/warehouse.dart` | Warehouse records |

## Chat / Notifications

| Collection | Entity file | Purpose |
|---|---|---|
| `chat_sessions` | `chat/domain/entities/chat_session.dart` | Conversation threads |
| `chat_messages` | `chat/domain/entities/chat_message.dart` | Messages |
| `messages` | — | ⚠️ overlaps with `chat_messages` — verify if this is legacy/dead |
| `notifications` | `chat/domain/entities/notification.dart` | In-app notifications |
| `scheduled_notifications` | — | Scheduled/queued notifications |
| `visual_search_history` / `visual_search_preferences` | `chat/domain/entities/visual_search.dart` | Visual search feature — usage in UI unconfirmed |

## Misc / unassigned (needs an owner)

| Collection | Notes |
|---|---|
| `feedback` | Likely admin/support — no module doc owns this yet, assign to `modules/ADMIN.md` |
| `settings` | App/user settings — could be `core/` or per-module; verify |
| `transactions` | Referenced but **no payment module exists yet** — this may be placeholder/dead code. Flag before building real payments on top of it; see `08_PAYMENT_ARCHITECTURE.md` |

## Known issues to resolve

1. `wishlist` vs `wishlists` — pick one on the Firestore side now (recommend keeping
   `wishlists`, plural, for consistency with `carts`/`orders`), migrate, delete the other
   reference. Target Postgres name is `wishlists` regardless — see
   `docs/database/15_MIGRATION_MATRIX.md`.
2. `messages` vs `chat_messages` — same collection twice under different names, or two
   different features colliding. **Needs investigation** before the chat module is built out
   (grep actual reads/writes, check which one has real data). Target Postgres name is
   `messages` (under `conversations`) — treat `chat_messages` as the presumed-canonical source
   to migrate and `messages` as presumed legacy/dead pending that investigation; see
   `docs/database/15_MIGRATION_MATRIX.md`.
3. ~~`sellers` vs `business_accounts`~~ — **resolved.** See
   `docs/decisions/ADR-006-IDENTITY-MODEL.md`: both merge into `organizations` +
   `seller_profiles` on the Postgres target. On Firestore they can keep running separately
   until the Seller module migrates — just don't build new features that assume they're
   permanently distinct.
4. No indexes file (`firestore.indexes.json`) exists yet — will be needed once queries with
   compound `where`/`orderBy` ship (e.g. product search + filters).
