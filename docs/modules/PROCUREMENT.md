# Module: Procurement (B2B buy-side)

**Folder:** `lib/features/procurement/` · **Status:** foundation with UI mock (entities, repos, providers, and mock presentation layer exist) · **Firestore collections today:** `rfqs`, `rfq_items`, `rfq_responses`, `rfq_response_items`, `inventory_items`, `warehouses`

## What exists
`RFQ`, `Inventory`, `Warehouse` domain entities and their Firestore repository
implementations. Application providers and presentation screens exist using mock
data for development and testing.

## What's missing
- Replace mock providers and repositories with real Firestore/Supabase implementations.
- Connect UI to real backend (once available).
- Implement supplier comparison table (price/delivery/rating/reliability), per the vision doc.
- Integrate RFQ response flow with seller side (requires SELLER module dashboard to invite responses).

## Recommendation
Given this module is still using mock data, **consider migrating the
application`/`presentation` layers to the target Postgres/Supabase schema
instead of finishing them on Firestore first** — see `docs/database/12_MIGRATIONS.md`
"Suggested migration order," which lists procurement as a good candidate to build fresh on the
target DB rather than migrate later. If that's the chosen path, the existing Firestore
entities/repos become reference material for the domain model, not code to extend.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `lib/features/procurement/**`
4. `docs/database/01_DOMAIN_MODEL.md` "Procurement" section, `docs/database/03_TABLES.md`
   `rfqs` table
5. `docs/modules/TENDER_RFQ.md` for how RFQ relates to Tender (RFQ can escalate to a Tender)
6. `docs/modules/SELLER.md` for seller-side RFQ response handling.