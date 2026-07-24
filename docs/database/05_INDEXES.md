# Indexes

Baseline: every foreign key column gets a btree index (Postgres doesn't auto-index FKs).

| Table | Index | Reason |
|---|---|---|
| products | `(seller_id)` | seller dashboard listing |
| products | `(status) where status = 'active'` (partial) | catalog browse excludes drafts |
| product_variants | `(product_id)`, unique `(sku)` | lookup + uniqueness |
| orders | `(buyer_id)`, `(seller_id)`, `(status)` | order history queries per role |
| rfqs | `(company_id)`, `(status)` | dashboard filtering |
| tender_bids | `(tender_id, round)` | round-by-round evaluation |
| messages | `(conversation_id, created_at)` | paginated chat load |
| notifications | `(user_id, read_at)` where `read_at is null` (partial) | unread badge count |
| seller_reputation | PK on `seller_id` (already covering) | — |
| audit_logs | `(entity_type, entity_id)`, `(created_at)` | investigation queries |

Full-text search: use Postgres `tsvector` + GIN index on `products(name, description)` rather
than client-side filtering (current Firestore implementation is client-side-only — see
`docs/03_FEATURES.md` "Search" — this is one of the concrete wins of the Postgres migration).

Composite indexes to add once real query patterns exist: don't pre-guess beyond the above;
add via `EXPLAIN ANALYZE` on actual slow queries once traffic exists, and log the addition
here with the query it was added for.
