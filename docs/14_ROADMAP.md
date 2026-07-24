# Roadmap

The repo root also has `ROADMAP.md` — a standing agent-operating prompt (session budget rules,
repository ownership instructions). That file governs *how* an agent session behaves
mechanically (tool-call budget, commit discipline). This file governs *what order* work
happens in. Read both if you're running an autonomous agent session; this docs/ system exists
specifically to keep each session's actual reading small enough to fit that tool-call budget —
see "Agent Onboarding Protocol" in `00_PROJECT_OVERVIEW.md`.

## Phase 0 — Foundation hardening (do this before new features)
- Ship `firestore.rules` (currently missing entirely)
- Resolve the collection-naming issues (`wishlist`/`wishlists`, `messages`/`chat_messages`)
- ~~Write ADR-003 (Auth strategy)~~ — **resolved**, see `decisions/ADR-003-AUTH.md`
- ~~Resolve `organizations`/`business_accounts`/`sellers` identity model~~ — **resolved**, see
  `decisions/ADR-006-IDENTITY-MODEL.md`
- Confirm payment provider (runtime is resolved — ADR-004 — provider selection is not)

## Phase 1 — Complete B2C core
- Real checkout + a server function runtime (Cloud Functions or Supabase Edge Functions)
- Payments (`08_PAYMENT_ARCHITECTURE.md`)
- Reviews, coupons UI, advanced filters
- Seller Dashboard MVP (products + orders view)

## Phase 2 — B2B foundation
- Company structure: projects, budgets, purchase requests, approvals (`modules/B2B.md`)
- Procurement application/presentation layers (`modules/PROCUREMENT.md`) — built on Postgres
  target per `database/12_MIGRATIONS.md`
- Buyer↔seller chat wired into product/order/RFQ context (`modules/CHAT.md`)

## Phase 3 — Tender & trust
- Tender module, all four modes (`modules/TENDER_RFQ.md`)
- Seller verification / trust score (`modules/SELLER.md`, `database` "Sellers"/"Trust")
- Admin panel for verification + dispute review (`modules/ADMIN.md`)

## Phase 4 — Logistics & scale
- Shipment tracking (`modules/LOGISTICS.md`)
- Analytics / market intelligence (`modules/ANALYTICS.md`)
- Full-text product search on Postgres (fixes the current client-side search limitation,
  `13_PERFORMANCE.md`)

## Phase 5 — AI layer
- AI Buyer/Procurement/Seller/Tender/Fraud agents, Project Cart (`modules/AI.md`,
  `modules/MARKETPLACE.md` §Project Cart)

## Running in parallel throughout
- Postgres/Supabase migration (`database/12_MIGRATIONS.md`) — feature by feature, starting
  with `chat`, per the suggested migration order in that doc
- Test coverage growing alongside each phase (`11_TESTING.md`)

This is a sequencing guide, not a committed schedule — reprioritize as real usage data comes
in, and update this file (not just `15_TODO.md`) when the phase order changes materially.
