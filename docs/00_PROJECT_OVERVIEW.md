# FloodStore — Project Overview

> **Read this file first. Always.** Every other doc in `docs/` builds on this one.
> If you are an AI agent picking up a task, see **"Agent Onboarding Protocol"** at the bottom —
> it tells you exactly which files to read and which to skip.

## Vision

FloodStore is not "Amazon for construction materials." It is the **Operating System for
Construction Commerce**: a single ecosystem where individuals, contractors, suppliers,
manufacturers and logistics providers buy, sell, negotiate, tender, procure and manage
construction projects.

## Mission

Give the construction industry what generic marketplaces can't:
- Project-aware buying (tell us the project, we calculate the materials)
- Real B2B procurement (RFQ → tender → PO → invoice → delivery, not just "checkout")
- Trust infrastructure (supplier verification, KYC/KYB, ratings)
- A direct **buyer ↔ seller relationship layer** (chat, negotiation, order-linked messaging),
  not just an anonymous cart

## Target Users

| User | Needs |
|---|---|
| B2C Buyer | Browse, buy, track orders, chat with seller |
| Contractor / Company (B2B) | Procurement, RFQ, tenders, budgets, approvals |
| Seller / Supplier | Storefront, inventory, orders, analytics, RFQ responses |
| Manufacturer / Distributor | Bulk supply, tender participation |
| Logistics Provider | Delivery, tracking |
| Admin | Platform moderation, disputes, verification |

## Core Products (current + planned)

| Product | Status | Owning module doc |
|---|---|---|
| Authentication (email, Google, Apple, phone, MFA, org accounts) | 🟢 Mostly built | [`modules/AUTH.md`](modules/AUTH.md) |
| B2C Marketplace (catalog, cart, wishlist, search) | 🟡 Partial | [`modules/MARKETPLACE.md`](modules/MARKETPLACE.md) |
| Checkout & Orders | 🔴 Missing | [`modules/ORDERS.md`](modules/ORDERS.md) |
| Payments | 🔴 Missing | [`08_PAYMENT_ARCHITECTURE.md`](08_PAYMENT_ARCHITECTURE.md) |
| Business / Seller accounts | 🟡 Partial | [`modules/SELLER.md`](modules/SELLER.md) / [`modules/B2B.md`](modules/B2B.md) |
| Procurement (RFQ, warehouse, inventory) | 🟡 Foundation only | [`modules/PROCUREMENT.md`](modules/PROCUREMENT.md) |
| Tender / Reverse auction | 🔴 Not started | [`modules/TENDER_RFQ.md`](modules/TENDER_RFQ.md) |
| Buyer ↔ Seller Chat & Notifications | 🟡 Foundation only | [`modules/CHAT.md`](modules/CHAT.md) |
| Logistics / Delivery tracking | 🔴 Not started | [`modules/LOGISTICS.md`](modules/LOGISTICS.md) |
| Admin panel | 🔴 Not started | [`modules/ADMIN.md`](modules/ADMIN.md) |
| Analytics / Market intelligence | 🔴 Not started | [`modules/ANALYTICS.md`](modules/ANALYTICS.md) |
| AI Agents (buyer/seller/procurement/tender assistants) | 🔴 Not started | [`modules/AI.md`](modules/AI.md) |
| Project-based Commerce (project → material list → cart) | 🔴 Not started | [`modules/MARKETPLACE.md`](modules/MARKETPLACE.md) §Project Cart |

🟢 = production-usable · 🟡 = entities/repos exist, UI/logic incomplete · 🔴 = not started

See [`03_FEATURES.md`](03_FEATURES.md) for the granular, file-level breakdown.

## Technology Stack

- **Client**: Flutter 3.19+ / Dart 3.3+, Material 3
- **State management**: Riverpod (`flutter_riverpod`)
- **Routing**: GoRouter with auth-aware redirects
- **Backend**: Firebase — Auth, Cloud Firestore, Storage. Cloud Functions **not yet used**
  (see [`08_PAYMENT_ARCHITECTURE.md`](08_PAYMENT_ARCHITECTURE.md) for why this has to change
  before real payments can ship)
- **Security**: `flutter_secure_storage`, `local_auth` (biometrics), custom rate limiter

## Supported Platforms

Android, iOS, Web, Windows, macOS, Linux (Flutter multi-platform scaffold present in repo)

## Project Status (as of this doc's generation)

- ~146 Dart files, ~27.5k lines in `lib/`
- 6 features currently exist under `lib/features/`: `splash`, `auth`, `marketplace`,
  `procurement`, `business`, `chat`
- No `firestore.rules` file exists yet in the repo — **this is a critical gap**, see
  [`06_FIREBASE_RULES.md`](06_FIREBASE_RULES.md)
- No automated test suite beyond the default `test/widget_test.dart` placeholder
- No Cloud Functions — all payment/business logic currently would have to run client-side,
  which is unsafe for money-related features (see `08_PAYMENT_ARCHITECTURE.md`)

## Important Rules (non-negotiable, apply to every module)

1. **Never put secrets, payment logic, or trust decisions (KYC approval, payout release) in
   the Flutter client.** They belong in Cloud Functions / server-side code.
2. **Never bypass the repository layer.** UI talks to providers, providers talk to
   repositories, repositories talk to Firebase. No screen imports `cloud_firestore` directly.
3. **Domain layer has zero Firebase/UI imports.** See `01_ARCHITECTURE.md`.
4. **One feature folder = one bounded context.** Don't reach into another feature's
   `domain/entities` from your feature; if you need shared data, it belongs in `core/` or a
   clearly-owned shared feature.
5. **Every new Firestore collection must be documented in `04_DATABASE_SCHEMA.md` and covered
   by a rule in `06_FIREBASE_RULES.md` before it ships.**

---

## Agent Onboarding Protocol

**This is the whole point of this `docs/` folder: agents should not read the entire
repository to do one task.**

When you (an AI agent) are assigned a task:

1. Read **this file** (`00_PROJECT_OVERVIEW.md`) — 5 minutes, gives you the map.
2. Read **`01_ARCHITECTURE.md`** — the structural rules you must follow, regardless of module.
3. Identify which module you're working in (marketplace, auth, procurement, business, chat,
   tender, logistics, admin, analytics, AI) and read **only that file** in `docs/modules/`.
4. If your task touches Firestore, read **only the relevant collections' section** of
   `04_DATABASE_SCHEMA.md` — not the whole file if it's long.
5. If your task touches payments, security, or auth flows, also read the matching top-level
   doc (`08_PAYMENT_ARCHITECTURE.md`, `10_SECURITY.md`, `07_AUTH_SYSTEM.md`).
6. Do **not** open files from unrelated feature folders (`lib/features/<other>/**`) unless the
   module doc explicitly tells you there's a shared dependency.
7. When you finish, update:
   - `docs/03_FEATURES.md` (status column for what you touched)
   - `docs/15_TODO.md` (check off what you did, add what you discovered)
   - the relevant `docs/modules/<MODULE>.md` if you changed its shape (new entity, new
     collection, new screen)
8. If you had to make an architectural decision (new package, new pattern, new provider),
   write a short ADR in `docs/decisions/`. Don't skip this — it's how the next agent avoids
   re-litigating your decision.

**Rule of thumb: if a task can be described as "work on the chat module," an agent should be
able to do it having read 3–4 files total, not 146.**
