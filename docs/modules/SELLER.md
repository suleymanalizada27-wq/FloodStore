# Module: Seller (storefront + dashboard)

**Folder:** `lib/features/business/` (entities/data only today) · **Status:** partial —
entities exist, **no dashboard UI at all** · **Firestore collections today:**
`business_accounts`, `sellers`, `loyalty`, `loyalty_tiers`

## What exists
`BusinessAccount`, `SellerAnalytics`, `Loyalty` entities + Firestore repos. No
`application/`/`presentation/` layers.

## What to build
Seller Dashboard per the product vision: Sales, Orders, Products, Inventory, Warehouses,
Customers, Analytics, RFQ/Tender Invitations, Quotes, Invoices, Payouts, Shipping, Returns,
Reviews. Build incrementally — start with Products + Orders (ties directly into
`modules/MARKETPLACE.md` and `modules/ORDERS.md`), then Analytics, then the B2B-facing pieces
(RFQ/Tender invitations) once `PROCUREMENT.md`/`TENDER_RFQ.md` exist.

## Known issue — resolved by ADR-006
`business_accounts` vs `sellers` (two Firestore collections, unclear relationship) is now
**resolved at the target-model level**: `docs/decisions/ADR-006-IDENTITY-MODEL.md` merges both
into `organizations` (company/business profile) + `seller_profiles` (seller-specific
extension, one per organization). On the **current Firestore side**, the two collections can
keep running as-is until this module's Postgres migration — don't add new fields assuming
they're separate concepts going forward, and don't build the dashboard's data layer assuming
today's Firestore split is permanent.

## Trust / KYC-KYB
Not started. See `docs/database/01_DOMAIN_MODEL.md` "Sellers" (`seller_verifications`,
`seller_reputation`) — this is Postgres-target-first, don't build KYC on Firestore.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `lib/features/business/**`
4. `docs/database/01_DOMAIN_MODEL.md` "Sellers" section
