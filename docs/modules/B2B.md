# Module: B2B (company structure & project commerce)

**Folder:** target `lib/features/b2b/` (does not exist yet — currently `organization.dart`
lives under `auth/`, which covers membership but not projects/budgets) · **Status:** not
started, foundation is `auth/`'s organization model · **Firestore collections today:** none
dedicated (organizations/members live in Auth)

## Scope
This module is the company-side structure described in the product vision: a company has
employees, departments, projects, budgets, and an approval chain that purchase requests flow
through before they become RFQs.

```
Company → Employees → Projects → Purchase Requests → (approval) → RFQ
```

## What to build (greenfield)
- `Project` entity (name, organization, status, phases per the vision's Phase 1..N construction
  stages), `Budget`/`BudgetItem`, `PurchaseRequest`/`PurchaseRequestItem`, an approval workflow
  (`PurchaseRequest.status`: draft → pending_approval → approved/rejected).
- Reuse `auth`'s `Organization`/`organization_repository` for company/membership — don't
  duplicate it; extend if it's missing fields (e.g. departments, budget roles). **This is now
  formalized in `docs/decisions/ADR-006-IDENTITY-MODEL.md`: there is no separate `companies`
  table/entity — B2B extends `organizations` directly, on both the current Firestore side and
  the Postgres target.**
- UI: project dashboard, purchase request form, manager approval inbox.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `lib/features/auth/domain/entities/organization.dart` (read-only reference, don't modify
   without an ADR) for how company/membership already works
4. `docs/database/01_DOMAIN_MODEL.md` "B2B" section — **this module should probably be built
   directly against Postgres/Supabase rather than Firestore**, see
   `docs/database/12_MIGRATIONS.md` "Suggested migration order" (new modules build on target DB)

## Relationship to Procurement/Tender
B2B owns *why* a purchase happens (project, budget, approval). Procurement (`PROCUREMENT.md`)
and Tender (`TENDER_RFQ.md`) own *how* the purchase is sourced once approved. A
`purchase_request` is the handoff point.
