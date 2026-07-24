# Module: Notifications

**Folder:** currently inside `lib/features/chat/` (entity: `notification.dart`) ·
**Status:** entity + Firestore repo exist, no delivery mechanism, no UI

## Scope
In-app notification center + push notifications (order status changes, RFQ responses, tender
updates, chat messages, admin/dispute actions).

## What's missing
- FCM integration (push delivery) — see `docs/05_FIREBASE.md`.
- Notification center UI.
- A single place other modules call into to create a notification (avoid every module writing
  directly to the `notifications` collection/table with inconsistent shapes) — define a small
  `NotificationService` interface other modules depend on.

## What an agent working on this module needs to read
1. `docs/00_PROJECT_OVERVIEW.md`, `docs/01_ARCHITECTURE.md`
2. This file
3. `lib/features/chat/domain/entities/notification.dart`,
   `lib/features/chat/data/repositories/firestore_notification_repository.dart`
4. `docs/database/01_DOMAIN_MODEL.md` "Notifications" section (target model)
