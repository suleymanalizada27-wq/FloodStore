# Module: Tender / Reverse Auction

**Folder:** target `lib/features/tender/` (does not exist) · **Status:** not started —
greenfield, build directly on Postgres/Supabase (see `docs/database/12_MIGRATIONS.md`)

## Scope (from the product vision)
A tender is an escalated RFQ with structured competitive bidding:
- **Reverse auction** — sellers see the current best price (not each other's identity) and can
  undercut it until the deadline.
- **Sealed bidding** — bids are hidden from all bidders until the tender closes.
- **Multi-round** — round 1 narrows to top N suppliers, round 2 narrows further, then final
  negotiation.
- **AI Tender Assistant** — a scoring pass that weighs price against reliability/on-time
  delivery (not just lowest price wins) — see `docs/modules/AI.md`.

## Data model
`docs/database/01_DOMAIN_MODEL.md` "Tender" section: `tenders`, `tender_participants`,
`tender_bids`, `tender_evaluations`, `tender_awards`. Table definitions:
`docs/database/03_TABLES.md` (`tenders`, `tender_bids`). RLS for sealed-bid visibility:
`docs/database/07_RLS_POLICIES.md`.

**Audit tables (required, not optional)** — tender outcomes involve real money and can be
disputed, so build these alongside the core tables from the start, not as an afterthought:
`tender_events` (every state change, timestamped, by whom), `tender_rounds` (per-round
metadata for multi-round tenders), `bid_revisions` (history of a bid changing, not just its
current value), `bid_attachments` (certificates/spec sheets attached to a bid),
`bid_evaluation_criteria` (the weighted criteria — price/reliability/delivery — behind
`tender_evaluations`, so "why did the AI pick Supplier A" is reconstructable later). See
`docs/database/03_TABLES.md` "All other tables" for where these are listed.

## Build order (suggested)
1. `tenders` + `tender_participants` (invite flow, reuse RFQ invitation pattern)
2. Open-mode bidding first (simplest: all bids visible) — prove the UI end to end
3. Sealed-mode (add the RLS visibility rule)
4. Reverse-auction mode (add "current best price" read model, real-time updates)
5. Multi-round (add round tracking + narrowing logic)
6. Evaluation/award (`award_tender` database function, see `docs/database/09_DATABASE_FUNCTIONS.md`)
7. AI scoring pass (`docs/modules/AI.md` "AI Tender Agent")

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `docs/database/01_DOMAIN_MODEL.md` (Tender section), `03_TABLES.md`, `07_RLS_POLICIES.md`,
   `09_DATABASE_FUNCTIONS.md`
Do not read `lib/features/procurement/**` beyond checking how RFQ invitations are structured
for consistency — this module doesn't extend procurement's Firestore code, it's built fresh.
