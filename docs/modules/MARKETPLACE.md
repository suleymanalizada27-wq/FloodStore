# Module: Marketplace (B2C)

**Folder:** `lib/features/marketplace/` · **Status:** partial · **Firestore collections today:**
`products`, `categories`, `variants`, `carts`, `saved_carts`, `wishlist`/`wishlists`, `orders`,
`reviews`, `coupons`, `bundles`, `recommendations`, `recently_viewed`, `ad_campaigns`, `history`

## What exists
Product catalog/listing, category browsing, client-side search, cart, wishlist, a stub
checkout screen, order confirmation/detail screens, product image upload.
See `docs/03_FEATURES.md` "Marketplace" table for the file-level checklist.

## What's missing (in priority order for the B2C side)
1. Real checkout flow (entity + repo + screens) — see `docs/modules/ORDERS.md` for where
   Checkout/Orders boundary sits.
2. Reconcile `wishlist` vs `wishlists` collection naming (`docs/04_DATABASE_SCHEMA.md`).
3. Advanced filters (price range, brand, in-stock).
4. Reviews UI (entity exists in review feature, no screen/provider wiring confirmed in marketplace).
5. **Project Cart** (vision differentiator): user describes a project ("100m² house"), system
   computes a material list, adds it as one unit to cart. This needs: a materials-estimation
   ruleset or AI call, a `ProjectCart`/`ProjectCartItem` concept, and UI. Treat as its own
   sub-feature, don't bolt it onto the regular cart entity.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `lib/features/marketplace/**` only
4. The relevant rows of `docs/04_DATABASE_SCHEMA.md` (Marketplace section)
Checkout/payment work also requires `docs/08_PAYMENT_ARCHITECTURE.md`.

## Postgres target
`docs/database/01_DOMAIN_MODEL.md` "Marketplace — Catalog" and "Shopping"/"Orders" sections.
