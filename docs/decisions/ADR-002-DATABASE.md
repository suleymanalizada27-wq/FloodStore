# ADR-002: PostgreSQL-first schema, Supabase as current platform

**Status:** Accepted (design decision — implementation not yet started, see
`docs/database/12_MIGRATIONS.md`)

**Decision:** The target database is Postgres, designed and documented independently of any
specific host. Supabase is adopted as the concrete platform (Postgres + Auth + RLS + Storage +
Edge Functions) for practical reasons (managed Postgres, built-in RLS tooling, Edge Functions
give the server-side runtime this project currently lacks — see `08_PAYMENT_ARCHITECTURE.md`).
The existing Firebase/Firestore system stays live for already-built features during a phased
migration; new modules (`tender`, `logistics`, `admin`, `analytics`, `payments`, `b2b`) are
built directly on the Postgres target rather than first on Firestore.

**Why not stay on Firestore indefinitely:**
- No relational joins — the B2B/procurement/tender domain (companies → projects → purchase
  requests → RFQs → quotes → POs → invoices) is deeply relational; modeling it in Firestore
  means either heavy denormalization or many round-trip reads.
- No native full-text search, no compound transactional guarantees across collections the way
  Postgres functions/triggers provide (`docs/database/08_TRANSACTIONS.md`).
- No RLS-equivalent row-level policy language as expressive as Postgres RLS for the layered
  trust model this project needs (buyer/seller/company-member/admin).

**Why not Supabase-only (proprietary) design:** documenting the schema as plain Postgres
(`docs/database/` folder) means leaving Supabase later — for a self-hosted Postgres or another
provider — is a hosting change, not a schema rewrite.

**Alternatives considered:** Stay on Firestore and model relational data via subcollections +
denormalization (rejected — doesn't scale to the tender/procurement complexity in the vision
doc). MongoDB (rejected — same relational-modeling problem as Firestore, no clear advantage).
Self-hosted Postgres from day one, skip Supabase (rejected for now — Supabase's managed
Auth/RLS/Edge Functions reduce the immediate operational burden; revisit if/when self-hosting
becomes cost-effective).

**Consequence:** Two databases running during migration (`docs/database/12_MIGRATIONS.md`),
real operational complexity during the transition. Accepted because building the B2B/tender
domain on Firestore first, then migrating it, would be strictly more work than building it on
Postgres once.
