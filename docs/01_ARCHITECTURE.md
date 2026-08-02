# Architecture

## Layering (Clean Architecture, per-feature)

Every feature under `lib/features/<name>/` follows the same four layers:

```
presentation/   → screens/, widgets/            (UI only, no Firebase imports)
        ↓
application/    → providers/, state/            (Riverpod controllers, glue)
        ↓
domain/         → entities/, repositories/       (pure Dart, no Firebase/UI imports —
                                                     repositories/ here are ABSTRACT contracts)
        ↓
data/           → repositories/ (Firestore impl), sources/
        ↓
Firebase (Auth / Firestore / Storage)
```

Rules:
- `domain/repositories/*.dart` defines an **interface**. `data/repositories/*.dart` provides
  the **Firestore implementation** of that interface. Nothing outside `data/` should import
  `cloud_firestore` or `firebase_auth`.
- `application/providers/*.dart` wires the interface to the implementation via Riverpod
  (`Provider`, `StateNotifierProvider`, etc.) and exposes state to the UI.
- `presentation/` only depends on `application/` (providers) and `domain/` (entities for
  typing). It never imports `data/`.
- Cross-feature imports are a smell. If `marketplace` needs something from `business`, that's
  a sign the entity is misplaced or needs to move to `core/` as a shared primitive.


## Actual folder structure (current)
 ```

lib/
core/
constants/ app_constants.dot
enums/ inventory_status.dot
router/ app_router.dot, auth_guards.dot
services/ auth_rate_limiter.dot, draft_storage_service.dot
secure_token_service.dot, session_service.dot
theme/ app_colors.dot, app_effects.dot, app_motion.dot
app_spacing.dot, app_text_styles.dot, app_theme.dot
widgets/ shared UI primitives (GlassCard, PremiumButton, etc.)
features/
splash/ presentation/ only
auth/ domain/ data/ application/ presentation/ (see modules/AUTH.md)
business/ domain/ data/ application/ presentation/ (see modules/SELLER.md and modules/B2B.md)
chat/ domain/ data/ application/ presentation/ (see modules/CHAT.md)
marketplace/ domain/ data/ application/ presentation/ (see modules/MARKETPLACE.md)
procurement/ domain/ data/ application/ (no presentation/ yet — see modules/PROCUREMENT.md)
recommendation/ domain/ only
review/ domain/ data/
user/ domain/ only
Note: All features now have the four layers (domain, data, application, presentation). See `03_FEATURES.md` for details on completion.

## Adding a new feature module

1. Create `lib/features/<name>/{domain,data,application,presentation}/`
2. Write the domain entity + abstract repository first.
3. Write the Firestore repository implementation in `data/`.
4. Wire a Riverpod provider in `application/`.
5. Build the screen(s) in `presentation/`.
6. Register routes in `lib/core/router/app_router.dart`.
7. Document the collection(s) you used in `docs/04_DATABASE_SCHEMA.md`.
8. Add/update Firestore rules in `docs/06_FIREBASE_RULES.md` (and the real rules file once
   it exists — see that doc for the current gap).
9. Create or update `docs/modules/<NAME>.md`.

## State management conventions

- Riverpod providers live in `application/providers/`.
- Immutable state classes (often `Equatable`) live in `application/state/`.
- Prefer `StateNotifier` + a state class over ad-hoc `StateProvider<T>` for anything with more
  than one field.

## Naming conventions

- Files: `snake_case.dart`. Classes: `PascalCase`.
- Repositories: `XRepository` (abstract, domain) / `FirestoreXRepository` (impl, data).
- Providers: `xProvider`, controllers: `xControllerProvider`.
- Entities are plain Dart classes, no Firebase types leak into their fields (use `DateTime`,
  not `Timestamp`; convert in the data layer).

## Error handling

There is currently **no unified Result/Either pattern** in the codebase — repositories mostly
throw or return nullable values inconsistently. Standardizing this (e.g. adopting a
`Result<T, Failure>` type) is an open decision — see `docs/decisions/` for the ADR once someone
picks an approach, and don't invent a second competing pattern without writing one.
