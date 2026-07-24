# Module: Analytics / Market Intelligence

**Folder:** target `lib/features/analytics/` (does not exist; a seller-facing analytics repo
exists inside `marketplace/data/repositories/firestore_analytics_repository.dart` but no
dashboard) · **Status:** not started as a real module

## Scope (from the product vision)
- Seller-facing: sales trends, conversion rate per product, price-vs-market-average signal
  ("your price is 8% above market average").
- Platform-facing: demand trend signals ("cement demand up 23% this month"), regional
  breakdowns, price trend alerts to buyers.
- Feeds the AI Seller Assistant and AI Buyer Agent (`docs/modules/AI.md`).

## Data model
Mostly derived/aggregated data — likely materialized views or scheduled aggregation jobs over
`orders`, `products`, `rfqs` (Postgres target) rather than its own primary tables. Design this
after the underlying transactional tables (`docs/database/03_TABLES.md`) have real data flowing
through them; don't build the analytics layer before the modules it summarizes exist.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. Whichever transactional module you're aggregating over (read only that module's doc, not
   all of them)
