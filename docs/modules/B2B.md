## What to build (greenfield - updated for current progress)

We have built the domain and presentation layers for the B2B module, with a mock data layer for UI preview and testing. The real backend (Supabase) integration is pending.

### Completed (Domain + Presentation layers with mock data)

- **Entities** (in `lib/features/b2b/domain/entities/`):
  - `Project` (id, organizationId, name, description, status, phases, startDate, endDate)
  - `ProjectPhase` (id, projectId, name, description, startDate, endDate, budget, status)
  - `Budget` (id, name, description, items, totalAmount getter)
  - `BudgetItem` (id, name, description, amount, unit, category)
  - `PurchaseRequest` (id, projectId, phaseId, requesterId, requestDate, status, items)
  - `PurchaseRequestItem` (id, description, quantity, unitPrice, unit, vendorSuggestion)

- **Repositories** (in `lib/features/b2b/domain/repositories/`):
  - `ProjectRepository` (abstract interface with methods: getProjects, createProject, getProjectDetail, createPurchaseRequest, approvePurchaseRequest, rejectPurchaseRequest)

- **Data Layer (Mock)** (in `lib/features/b2b/data/repositories/`):
  - `FirestoreProjectRepository` (implements ProjectRepository using Cloud Firestore - **NOTE**: This is a placeholder; replace with Supabase implementation once provisioned)
    - Includes methods for CRUD operations on projects and purchase requests
    - TODO: Replace with Supabase-backed implementation once Supabase project is provisioned (see docs/decisions/ADR-004-PAYMENTS.md, docs/database/12_MIGRATIONS.md)

- **Application Layer** (in `lib/features/b2b/application/providers/`):
  - `b2b_providers.dart` - Riverpod providers for repository and business logic (using FirestoreProjectRepository as implementation)

- **Presentation Layer** (in `lib/features/b2b/presentation/screens/`):
  - `projects_screen.dart` - List of projects for an organization
  - `project_detail_screen.dart` - Detailed view of a project with phases, budget, and actions
  - `create_purchase_request_screen.dart` - Form to create a purchase request for a project/phase
  - `approval_inbox_screen.dart` - List of purchase requests pending approval (for managers)

### Pending (Real Backend Integration)

- Replace `FirestoreProjectRepository` with a Supabase-backed implementation (`SupabaseProjectRepository`) once the Supabase project is set up (see docs/decisions/ADR-004-PAYMENTS.md and docs/database/12_MIGRATIONS.md for migration guidance).
- Implement actual data persistence using Supabase (PostgreSQL) instead of Firestore.
- Ensure Row Level Security (RLS) policies are in place for data protection.

### Updated "What to build" (from original greenfield)

The original greenfield plan remains valid, but we have completed the domain and presentation layers with a mock/Firestore data layer for development and testing. The next step is to replace the data layer with a Supabase implementation.

```
- `Project` entity (name, organization, status, phases per the vision's Phase 1..N construction stages), `Budget`/`BudgetItem`, `PurchaseRequest`/`PurchaseRequestItem`, an approval workflow (`PurchaseRequest.status`: draft → pending_approval → approved/rejected).
- Reuse `auth`'s `Organization`/`organization_repository` for company/membership — don't duplicate it; extend if it's missing fields (e.g. departments, budget roles). **This is now formalized in `docs/decisions/ADR-006-IDENTITY-MODEL.md`: there is no separate `companies` table/entity — B2B extends `organizations` directly, on both the current Firestore side and the Postgres target.**
- UI: project dashboard, purchase request form, manager approval inbox.
```