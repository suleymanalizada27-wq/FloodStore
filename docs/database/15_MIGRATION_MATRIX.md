# Migration Matrix — Firebase (current) → PostgreSQL (target)

This is the single canonical mapping between every collection currently live in Firestore
(`docs/04_DATABASE_SCHEMA.md`) and its target Postgres table (`03_TABLES.md`). Build this list
into an actual migration checklist as each feature moves — don't start moving a feature's data
before its row here is `Ready`/`Map` or `Redesign`/agreed, not `Conflict`.

**Status legend:** `Ready` = clean 1:1, migrate as-is · `Partial` = exists but incomplete on
the Firestore side, finish or redesign during migration, not before · `Conflict` = two
Firestore concepts map to one target concept, resolve via the linked ADR before migrating ·
`New` = no Firestore equivalent, build directly on Postgres, nothing to migrate.

**Migration action legend:** `Map` = straightforward field mapping · `Redesign` = shape changes
meaningfully (e.g. denormalized Firestore doc becomes normalized tables) · `Merge` = two+
Firestore collections become one Postgres table · `Build` = new, no source data · `Audit
first` = investigate before deciding (dead code risk)

## Identity / Organization

| Firestore | Postgres | Status | Action | Notes |
|---|---|---|---|---|
| `users` | `users` (+ `user_profiles`) | Partial | Map | Split extended profile fields into `user_profiles` if `users` doc is large |
| `organizations` | `organizations` | Ready | Map | Becomes the canonical org table per ADR-006, add `type` column |
| `members` | `organization_members` | Ready | Map | |
| `invitationCodes` | (new table, not yet in `03_TABLES.md`) | New | Build | Add `organization_invitations` table when this migrates |
| `sessions` | not migrated — stays Firebase Auth-side | N/A | — | Per ADR-003, Firebase Auth (and its session model) is not replaced |
| `loginHistory` | `security_events` (Admin/Security context) or stays Firebase-side | Partial | Redesign | Decide when Admin module is built |
| `addresses` | `organization_addresses` / `delivery_addresses` / `seller_addresses` depending on use | Partial | Redesign | Current single collection likely needs to split by owner type — audit usage first |

## Marketplace — Catalog

| Firestore | Postgres | Status | Action | Notes |
|---|---|---|---|---|
| `products` | `products` | Ready | Map | |
| `categories` | `categories` | Ready | Map | |
| `variants` | `product_variants` | Ready | Map | |
| — | `product_images`, `attributes`, `product_attributes`, `product_categories`, `brands` | New | Build | Firestore likely stores these as embedded fields on `products` — will need `Redesign`, not pure `Build`, once the actual `product.dart` entity shape is reviewed field-by-field |

## Shopping / Orders

| Firestore | Postgres | Status | Action | Notes |
|---|---|---|---|---|
| `carts` | `carts` + `cart_items` | Partial | Redesign | Firestore cart likely embeds items as an array — normalize into `cart_items` rows |
| `saved_carts` | folded into `carts` with a `status='saved'` or similar, or a separate flag | Partial | Redesign | Decide during Marketplace migration, avoid a permanent parallel table if a status column suffices |
| `wishlist` / `wishlists` | `wishlists` + `wishlist_items` | Conflict | Merge | Resolve the duplicate-collection issue (`04_DATABASE_SCHEMA.md` #1) *before* migrating — migrating both would just move the bug |
| `orders` | `orders` + `order_items` | Partial | Redesign | Current `orders` has no working checkout flow yet (`docs/modules/ORDERS.md`) — design `order_items` fresh rather than reverse-engineering an incomplete source shape |
| `reviews` | `reviews` + `ratings` | Partial | Redesign | Confirm whether rating is embedded in review or separate today |
| `coupons` | `coupons` | Partial | Map | No target table explicitly defined yet in `03_TABLES.md` — add one when this migrates (not in the original vision list, but real in Firestore) |
| `bundles` | (no target table defined yet) | Partial | Audit first | No dedicated entity found in code — confirm this is real and in use before designing a target table |
| `recommendations` | (no target table — likely computed, not stored) | Partial | Redesign | Consider making this a materialized view/query result rather than a stored table, once `docs/modules/ANALYTICS.md` exists |
| `recently_viewed` | (client-local or a lightweight table) | Partial | Redesign | Candidate for client-side-only storage (no server table needed) — decide based on whether cross-device sync is a real requirement |
| `ad_campaigns` | (no target table yet) | Partial | Audit first | Confirm current usage before designing |
| `history` | ambiguous — price history vs generic activity log | Partial | Audit first | `docs/04_DATABASE_SCHEMA.md` already flags this ambiguity — resolve before migrating |

## Sellers / Business

| Firestore | Postgres | Status | Action | Notes |
|---|---|---|---|---|
| `business_accounts` | `organizations` (profile fields) + `seller_profiles` | Conflict | Merge | Resolved by ADR-006 — split fields: company-identity fields → `organizations`, store-specific fields → `seller_profiles` |
| `sellers` | `seller_profiles` | Conflict | Merge | Resolved by ADR-006 — likely the majority of `seller_profiles` fields come from here |
| `loyalty` | `loyalty` program tables (not yet in `03_TABLES.md`) | Partial | Build | Add `loyalty_accounts`/`loyalty_transactions` when Seller module reaches this |
| `loyalty_tiers` | same as above | Partial | Build | |

## Procurement

| Firestore | Postgres | Status | Action | Notes |
|---|---|---|---|---|
| `rfqs` | `rfqs` | Partial | Redesign | Foundation-only on Firestore side (`docs/modules/PROCUREMENT.md`) — recommend building the real RFQ flow directly on Postgres rather than finishing it on Firestore first, per `12_MIGRATIONS.md` "Suggested migration order" |
| `rfq_items` | `rfq_items` | Partial | Redesign | Same as above |
| `rfq_responses` | `supplier_responses` + `quotes` | Partial | Redesign | Target splits "a supplier responded" from "the quote line items" — current Firestore shape unconfirmed |
| `rfq_response_items` | `quote_items` | Partial | Redesign | |
| `inventory_items` | `warehouse_inventory` | Partial | Map/Redesign | |
| `warehouses` | `warehouses` | Ready | Map | |

## Tender, B2B, Payments, Logistics, Admin, Analytics, AI

| Firestore | Postgres | Status | Action | Notes |
|---|---|---|---|---|
| *(none exist)* | `tenders`, `tender_bids`, etc. (`docs/modules/TENDER_RFQ.md`) | New | Build | |
| *(none exist)* | `projects`, `budgets`, `purchase_requests`, etc. (`docs/modules/B2B.md`) | New | Build | |
| `transactions` (referenced, likely dead) | `payments`, `payment_transactions`, etc. | New | Audit first, then Build | Confirm `transactions` collection is genuinely unused before ignoring it — if it has real data, that's a scope surprise |
| *(none exist)* | `shipments`, `carriers`, etc. (`docs/modules/LOGISTICS.md`) | New | Build | |
| `feedback` | `reports` / `disputes` (Admin/Trust context) | Partial | Redesign | Assign proper owner once Admin module design starts |
| `settings` | split across relevant tables or an `app_settings` table | Partial | Audit first | Confirm what's actually stored here — likely a grab-bag today |
| *(none exist)* | Analytics: materialized views over transactional tables | New | Build | Don't create source-of-truth tables for analytics until the transactional tables it summarizes have real data |
| *(none exist)* | AI agents: read-only across modules, write only to their own tables (`fraud_alerts`, etc.) | New | Build | |

## Chat / Notifications

| Firestore | Postgres | Status | Action | Notes |
|---|---|---|---|---|
| `chat_sessions` | `conversations` | Ready | Map | |
| `chat_messages` | `messages` | Partial | Map (pending audit) | Presumed canonical source — see `04_DATABASE_SCHEMA.md` #2 |
| `messages` (Firestore) | — | Conflict | Audit first | Presumed legacy/dead — confirm before dropping; do **not** merge blindly with `chat_messages` without checking for real data first |
| `notifications` | `notifications` | Ready | Map | |
| `scheduled_notifications` | folded into `notifications` with a `scheduled_for` column, or kept separate | Partial | Redesign | Decide based on actual query patterns once Notifications module is built |
| `visual_search_history` / `visual_search_preferences` | no target table yet | Partial | Audit first | Confirm this feature is actually used by any screen before migrating (`docs/modules/CHAT.md` already flags this as unclear) |

## Migration order (repeats `12_MIGRATIONS.md`, kept here for one-glance reference)

```
1. Database foundation (this schema, RLS, functions/triggers — no data yet)
2. Identity / Organizations   (users, organizations, organization_members — per ADR-006)
3. Chat                        (least data, proves the pattern end-to-end)
4. Payments                    (no Firestore source to migrate — build directly, per ADR-004)
5. Procurement                  (foundation-only on Firestore — build directly, don't finish there first)
6. Seller / Business            (resolve business_accounts/sellers merge per ADR-006 as part of this)
7. Marketplace core              (products, cart, wishlist, orders — highest risk/data, do after the above are proven)
8. B2B                            (new, build directly)
9. Tender                          (new, build directly, include audit tables from day one)
10. Logistics                       (new, build directly)
11. Admin                            (new, build directly)
12. Analytics                         (new, build after transactional tables have real data)
13. AI agents                          (new, build last — depends on most other modules existing)
```

Every row in every table above should end in `Ready`/`Map` before that feature's migration
Phase 4 (cutover, `12_MIGRATIONS.md`) starts. Rows still `Conflict` or `Audit first` are
blockers for that feature, not for the whole migration — resolve per-feature, not all at once.
