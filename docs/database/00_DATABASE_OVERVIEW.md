# Database Overview

> **This folder (`docs/database/`) is the canonical source of truth for the target database
> design** — domain model, table definitions, relationships, RLS, migrations. `docs/04_DATABASE_SCHEMA.md`
> is a separate, narrower document: it only describes the **current live Firestore state** and
> should not be treated as a competing schema authority. If you're designing or changing the
> target schema, edit files in this folder. If you're documenting what Firestore does *today*,
> edit `docs/04_DATABASE_SCHEMA.md`. See `decisions/ADR-006-IDENTITY-MODEL.md` for a worked
> example of this folder resolving a conflict that `04_DATABASE_SCHEMA.md` had only flagged.

## Decision: PostgreSQL-first target, Supabase as current backend platform

FloodStore currently runs on **Firebase (Firestore)**. This is being kept for the parts
already built (auth, marketplace foundation) while the **target long-term database is
PostgreSQL**, accessed through **Supabase** as the concrete platform (Postgres + Auth + RLS +
Storage + Edge Functions).

Why Postgres-first instead of "Supabase-first": the schema, relationships, constraints and
RLS policies are designed as **standard PostgreSQL**, documented independently of Supabase.
Supabase is treated as *a* hosting/runtime choice for that Postgres schema, not as the source
of truth for the data model. This means:
- If FloodStore ever needs to leave Supabase for a self-hosted Postgres, RDS, or another
  Postgres provider, the schema and RLS policies in `docs/database/` port with minimal change.
- Nothing in this schema should depend on a Supabase-proprietary feature that doesn't have a
  plain-Postgres equivalent, except where explicitly noted (e.g. `auth.uid()` in RLS policies
  — Supabase-specific, documented in `07_RLS_POLICIES.md` with the plain-Postgres equivalent
  noted alongside).

See `decisions/ADR-002-DATABASE.md` for the full reasoning and alternatives considered.

## Relationship to the current Firebase system

This is **not a rewrite plan for today**. It's the target model new work should be measured
against, plus a phased migration path. `04_DATABASE_SCHEMA.md` (top-level docs, not this
folder) is the **current, real Firestore schema** — keep reading/writing there for any task
touching the live app right now. This `database/` folder is the **target**.

Migration phases (see `12_MIGRATIONS.md` for detail):
```
Phase 0 — Document current Firebase state (docs/04_DATABASE_SCHEMA.md)         [done]
Phase 1 — Design target Postgres schema (this folder)                          [in progress]
Phase 2 — Stand up Supabase project, apply schema, RLS policies                [not started]
Phase 3 — Build a data-access abstraction in Flutter (repository interfaces
           already exist per docs/01_ARCHITECTURE.md — swap Firestore impl
           for Supabase impl behind the same interface, feature by feature)    [not started]
Phase 4 — Dual-write / backfill for features being migrated                    [not started]
Phase 5 — Cut over reads, decommission the Firestore path per feature          [not started]
```

Because the app already uses the repository-interface pattern (`domain/repositories/*.dart`
abstract, `data/repositories/firestore_*.dart` concrete), migrating a feature means writing a
`data/repositories/supabase_*.dart` implementation of the *same* interface and swapping it in
the Riverpod provider — not rewriting the feature. This is the main payoff of Clean
Architecture being enforced from day one (`01_ARCHITECTURE.md`).

## How to read this folder

1. `01_DOMAIN_MODEL.md` — the conceptual model (what the entities are and how they relate),
   read this first, it's diagram-level, not SQL.
2. `02_ENTITY_RELATIONSHIPS.md` — ER diagrams per bounded context.
3. `03_TABLES.md` — actual table definitions (columns, types).
4. `04_ENUMS.md`, `05_INDEXES.md`, `06_CONSTRAINTS.md` — supporting detail.
5. `07_RLS_POLICIES.md` — row-level security (the Postgres equivalent of
   `docs/06_FIREBASE_RULES.md`).
6. `08_TRANSACTIONS.md`, `09_DATABASE_FUNCTIONS.md`, `10_DATABASE_TRIGGERS.md` — business logic
   that belongs in the database layer (e.g. atomic stock reservation, order total calculation).
7. `11_AUDIT_LOGGING.md`, `13_SEED_DATA.md`, `14_DATA_RETENTION.md` — operational concerns.
8. `12_MIGRATIONS.md` — the actual Firebase → Postgres migration plan and phased order.
9. `15_MIGRATION_MATRIX.md` — the full collection-by-collection mapping (current Firestore →
   target Postgres, status, and migration action per collection). This is the canonical
   reference when actually executing a feature's migration — `12_MIGRATIONS.md` has the
   phased plan, this file has the row-by-row detail.

Agents: if your task is "design the tenders table," you need `01_DOMAIN_MODEL.md` (Tender
section) + `03_TABLES.md` (Tender section) + `07_RLS_POLICIES.md` (Tender section). You do not
need to read all 14 files.
