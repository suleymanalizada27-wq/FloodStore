# Module: Logistics

**Folder:** target `lib/features/logistics/` (does not exist) · **Status:** not started

## Scope
Shipment tracking from seller/warehouse to buyer/construction site:
```
Order confirmed → Preparing → Loaded → In transit → Arrived at site → Unloading → Delivered
```
Construction-specific concerns: tonnage, volume, weight, pallet count, truck capacity,
delivery windows, GPS tracking (per the product vision).

## Data model
`docs/database/01_DOMAIN_MODEL.md` "Logistics" section: `shipments`, `shipment_items`,
`delivery_addresses`, `delivery_events`, `carriers`. Build directly on Postgres/Supabase.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `docs/database/01_DOMAIN_MODEL.md` "Logistics" section, `docs/database/03_TABLES.md`
4. `docs/modules/ORDERS.md` for the order → shipment handoff, `docs/modules/PROCUREMENT.md`
   for the PO → shipment handoff (B2B side)
