# TODO (live — agents update this as they work)

## CRITICAL
- [x] **Live exploit — fix first:** `checkout_screen.dart._placeOrder()` writes a fake
      `PaymentInfo(status: 'paid', providerPaymentId: 'mock_payment_...')` directly to
      Firestore and confirms the order — no real payment check at all. Remove/gate this path
      immediately (`docs/modules/ORDERS.md`, `docs/08_PAYMENT_ARCHITECTURE.md`)
- [x] Write and deploy `firestore.rules` — currently no security rules exist at all
      (`06_FIREBASE_RULES.md`) — this is what would have blocked the exploit above
- [x] Resolve `wishlist` vs `wishlists` collection duplication (`04_DATABASE_SCHEMA.md`, `database/15_MIGRATION_MATRIX.md`)
      - Verified that codebase consistently uses `wishlists` (plural) collection
      - Confirmed `wishlists` matches target Postgres name in migration matrix
      - No actual Firestore references to `wishlist` (singular) found in codebase
- [x] Audit \`messages\` vs \`chat_messages\` — confirm which is live before dropping either (`04_DATABASE_SCHEMA.md`, `database/15_MIGRATION_MATRIX.md`)
- [x] ~~Resolve `sellers` vs `business_accounts` relationship~~ — resolved via `decisions/ADR-006-IDENTITY-MODEL.md` (merge into `organizations` + `seller_profiles`); Firestore-side collections can stay split until Seller module migrates
- [x] ~~Write ADR-003 (Auth strategy)~~ — resolved: Firebase Auth stays, `decisions/ADR-003-AUTH.md`
- [x] ~~Write ADR-004 (Payments runtime)~~ — resolved: Supabase Edge Functions, `decisions/ADR-004-PAYMENTS.md`; payment **provider** (Stripe or alternative) is still open
- [ ] Confirm payment provider selection (`decisions/ADR-004-PAYMENTS.md` "Open" section)
- [x] Audit `transactions`, `bundles`, `ad_campaigns`, `settings`, `history`, `visual_search_*` collections — confirm real usage before designing target tables (`database/15_MIGRATION_MATRIX.md` "Audit first" rows)

## HIGH
- [ ] Build real Checkout entity/flow (`modules/ORDERS.md`)
- [ ] Stand up Supabase project + Edge Functions runtime (decided: `decisions/ADR-004-PAYMENTS.md`) —
      blocks Payments, KYC approval, tender award, and any trust-sensitive write
- [ ] Apply `database/03_TABLES.md` schema + `database/07_RLS_POLICIES.md` to the new Supabase project (`database/12_MIGRATIONS.md` Phase 1)
- [ ] Build `application/`+`presentation/` layers for `procurement` (`modules/PROCUREMENT.md`)
      — recommend building directly against Postgres target, not Firestore
- [x] Build `application/`+`presentation/` layers for `business`/Seller Dashboard (`modules/SELLER.md`)
- [x] Build `application/`+`presentation/` layers for `chat` (`modules/CHAT.md`) — good first
      Postgres migration candidate (least data)

## MEDIUM
- [ ] Advanced product filters (`modules/MARKETPLACE.md`)
- [ ] Reviews UI wiring
- [ ] Reconcile duplicate `history`/`ad_campaigns` collection purposes
- [ ] Set up Firebase Emulator Suite for local dev/testing (`05_FIREBASE.md`)
- [ ] Write real CI pipeline (`flutter analyze` + `flutter test` on PR) (`12_DEPLOYMENT.md`)

## LOW / GREENFIELD (build directly on Postgres/Supabase per migration plan)
- [ ] B2B company structure — projects, budgets, approvals (`modules/B2B.md`)
- [ ] Tender / reverse auction (`modules/TENDER_RFQ.md`)
- [ ] Logistics tracking (`modules/LOGISTICS.md`)
- [ ] Admin panel (`modules/ADMIN.md`)
- [ ] Analytics / market intelligence (`modules/ANALYTICS.md`)
- [ ] AI agents (`modules/AI.md`)
- [ ] Project Cart ("100m² house → material list") (`modules/MARKETPLACE.md`)

Agents: when you complete an item, check it off **and** update the relevant status table in
`03_FEATURES.md`. When you discover new work, add it here under the right priority, don't
leave it undocumented in a commit message only.