# Performance

## Current known issues
- Product search/filtering is **client-side** (`firestore_product_data_source.dart`) — fine at
  small catalog sizes, will not scale. The Postgres migration target includes full-text search
  via `tsvector`/GIN index (`database/05_INDEXES.md`) specifically to fix this.
- No pagination pattern confirmed across list screens (products, orders) — verify before
  catalog size grows; Firestore reads are billed per document, unpaginated lists get expensive
  fast on the free tier (explicitly called out as a constraint in project history — see
  `PROGRESS.md`/`AGENT_PROGRESS.md` in repo root).

## Guidance
- Paginate every list query (Firestore `.limit()` + cursor, or Postgres `LIMIT`/`OFFSET`/
  keyset pagination).
- Cache category/brand lists client-side (Riverpod provider with a longer-lived cache) —
  they change rarely.
- Lazy-load product images; avoid loading full-resolution images in list views.
- Track Firestore read/write counts per screen while still on Firestore — the free tier is a
  real constraint per existing project notes.
- Once on Postgres, add indexes based on actual `EXPLAIN ANALYZE` output
  (`database/05_INDEXES.md`), not speculation.
