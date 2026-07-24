# Module: Chat & Buyer↔Seller Communication

**Folder:** `lib/features/chat/` · **Status:** foundation only (entities + Firestore repos,
no `application/`/`presentation/`) · **Firestore collections today:** `chat_sessions`,
`chat_messages`, `messages` (⚠️ overlap, see below), `notifications`, `scheduled_notifications`,
`visual_search_history`, `visual_search_preferences`

## Scope
This is the direct buyer↔seller relationship layer called out explicitly in the product
vision — not a generic support widget. A conversation should be linkable to a specific
product, order, or RFQ so context isn't lost.

## Known issue to resolve first
`messages` vs `chat_messages` — two collections that look like the same concept. Investigate
which is actually read/written before building UI on either (see `docs/04_DATABASE_SCHEMA.md`).

## What to build
1. `application/providers/` wiring the existing `ChatRepository`/`NotificationRepository`.
2. Conversation list + message thread UI (`presentation/`).
3. Entry points from product detail, order detail, and RFQ screens ("message seller"/
   "message buyer") — this is what makes it a relationship layer instead of a standalone
   inbox.
4. Push notifications (FCM not yet wired — see `docs/05_FIREBASE.md`).

## Migration note
This module is a **good first candidate for the Postgres/Supabase migration** (see
`docs/database/12_MIGRATIONS.md`) since it has almost no production data yet — consider
building the `application`/`presentation` layers directly against the target
`conversations`/`messages` schema (`docs/database/01_DOMAIN_MODEL.md` "Communication") instead
of finishing them on Firestore.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `lib/features/chat/**`
4. `docs/database/01_DOMAIN_MODEL.md` "Communication"/"Notifications" sections if building on
   the target DB instead
