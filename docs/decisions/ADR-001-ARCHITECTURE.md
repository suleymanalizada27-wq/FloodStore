# ADR-001: Clean Architecture, feature-based folders

**Status:** Accepted (already in use — this ADR documents the existing convention)

**Decision:** Every feature under `lib/features/<name>/` uses
`domain/ → data/ → application/ → presentation/` layering. Domain has no Firebase/UI imports.
See `docs/01_ARCHITECTURE.md` for the full rules.

**Why:** Keeps business logic testable without Firebase, and — critically for this project's
current situation — makes the Firestore→Postgres migration (`docs/database/12_MIGRATIONS.md`)
tractable: a new `data/repositories/supabase_*.dart` can implement the same `domain/`
interface, so migrating a feature doesn't mean rewriting it.

**Alternatives considered:** MVC-per-screen (simpler short-term, but couples UI to Firebase,
makes the planned database migration much more expensive). Rejected.

**Consequence:** More boilerplate per feature (4 folders instead of 1). Accepted trade-off for
testability and migration flexibility.
