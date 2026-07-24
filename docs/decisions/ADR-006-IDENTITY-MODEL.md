# ADR-006: Unified Identity & Organization model

**Status:** ✅ Accepted (2026-07) — resolves the `organizations` / `companies` /
`business_accounts` / `sellers` ambiguity flagged across `docs/04_DATABASE_SCHEMA.md`,
`docs/modules/SELLER.md`, and `docs/database/01_DOMAIN_MODEL.md` prior to this ADR

## Problem

Before this decision, four separate concepts existed or were planned that all represented
"an entity that isn't just an individual user":
- `organizations` (Firestore, already live — Auth's org accounts)
- `companies` (planned for the B2B module — projects/budgets/procurement owner)
- `business_accounts` (Firestore, already live — seller-side business profile)
- `sellers` (Firestore, already live — unclear relationship to `business_accounts`)

Left unresolved, this guarantees duplicate/conflicting data models as B2B and Seller Dashboard
get built, and makes the Postgres migration (`docs/database/12_MIGRATIONS.md`) redesign the
same concept four times.

## Decision

**One entity, `organizations`, is the sole company/business-entity table.** Everything else
becomes an extension or a role on top of it.

```
User
 │
 ├── Personal Account (no extra table — a user acting as themself)
 │
 └── Organization Membership (organization_members)
          │
          ▼
      Organization                 ← replaces "companies", absorbs Auth's existing
          │                          "organizations" collection as-is
          ├── Company Profile        (name, legal_name, tax_id, verification_status
          │                           — was scattered across business_accounts/companies)
          ├── Departments             (new, for B2B module)
          ├── Projects                (new, for B2B module)
          ├── Budgets                 (new, for B2B module)
          └── Procurement context     (RFQs/tenders reference organization_id, not a
                                        separate "company_id")

Seller (a role an Organization can have, not a separate entity):
Organization
      │
      └── Seller Profile (seller_profiles)      ← replaces business_accounts + sellers
             │
             └── Store / listings (products.seller_id → seller_profiles.id)
```

**Individual (non-company) sellers still get an `organizations` row** — a lightweight one
(`organizations.type = 'individual'`) representing "this person's selling identity," kept
separate from their personal user account. This is what makes "Seller Profile hangs off
Organization" work uniformly for both a one-person seller and a real company, per the target
diagram above.

## What this replaces

| Old concept | New home |
|---|---|
| `organizations` (Firestore, Auth) | Stays as `organizations` — this is now the canonical table, not just an Auth-side concept |
| `members` (Firestore, Auth) | `organization_members` |
| Planned `companies`, `company_members`, `company_roles` (B2B module, was in `01_DOMAIN_MODEL.md`) | **Removed as separate tables.** B2B builds directly on `organizations`/`organization_members`, adding `organization_roles`, `departments`, `projects`, `budgets` as extensions |
| `business_accounts` (Firestore) | Fields merge into `organizations` (company profile fields) + `seller_profiles` (seller-specific fields) |
| `sellers` (Firestore) | Merges into `seller_profiles`, `organization_id` foreign key required |

## Consequences

- `docs/database/01_DOMAIN_MODEL.md`, `02_ENTITY_RELATIONSHIPS.md`, `03_TABLES.md` are updated
  to reflect `organizations` + `seller_profiles` as the identity backbone (done as part of
  this ADR — see those files' current content, not a "Business" bounded context anymore).
- `docs/modules/B2B.md` no longer introduces a `companies` table — it extends `organizations`.
- `docs/modules/SELLER.md`'s "known issue to resolve first" is resolved by this ADR; the
  migration action is "merge `business_accounts` + `sellers` into `organizations` +
  `seller_profiles`" — see `docs/database/15_MIGRATION_MATRIX.md`.
- On the **current Firestore side**, nothing needs to change immediately — `business_accounts`
  and `sellers` can keep running as-is until their feature (Seller Dashboard) is migrated to
  Postgres per `docs/database/12_MIGRATIONS.md`. This ADR governs the **target** model and
  should stop anyone from building new Firestore fields that assume `business_accounts` and
  `sellers` are separate concepts going forward.

## Alternatives considered

Keep `companies` (B2B) and `organizations` (Auth) as two separate tables, linked 1:1 —
rejected: guarantees drift (which one is "the" verification status? which one do RFQs
reference?) for no real benefit, since every company in this domain is, structurally, an
organization.
