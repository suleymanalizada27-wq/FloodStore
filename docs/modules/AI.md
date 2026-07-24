# Module: AI Agents

**Folder:** target `lib/features/ai/` (does not exist) · **Status:** not started

## Scope (from the product vision) — build these as separate, narrow agents, not one big bot
- **AI Buyer Agent** — takes a budget/goal, finds products, compares prices, builds a cart.
- **AI Procurement Agent** — assists a company's procurement employee (RFQ drafting, supplier
  shortlisting).
- **AI Seller Agent** — sales analytics narration ("3 products have low conversion").
- **AI Tender Agent** — scores tender bids on price + reliability, not just lowest price
  (feeds `tender_evaluations`, see `docs/database/01_DOMAIN_MODEL.md` "Tender").
- **AI Fraud Agent** — flags suspicious patterns into `fraud_alerts` for `modules/ADMIN.md` to
  review — this agent should only ever *flag*, never auto-act, given the trust/money stakes.
- **AI Construction Assistant** — the "Project Cart" feature in `modules/MARKETPLACE.md`
  (project description → material list).

## Design principle
Each agent is a narrow, single-purpose service with a clear input/output contract (see
`docs/09_API_CONTRACTS.md` once defined) — not a shared do-everything assistant. This mirrors
the whole point of this docs system: narrow scope per agent, whether that agent is an AI
teammate working on the codebase or an AI feature running in production.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. The module doc for whichever domain the specific AI agent serves (e.g. building the AI
   Tender Agent → also read `docs/modules/TENDER_RFQ.md`)
