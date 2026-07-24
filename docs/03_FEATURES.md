# Features — granular status

Legend: ✅ Done · ⚠️ Partial · ❌ Missing

Agents: update the relevant row(s) when you finish a task. Don't rewrite the whole table.

## Auth (`lib/features/auth/`) — see `modules/AUTH.md`

| Feature | Domain | Data | Application | Presentation | Status |
|---|---|---|---|---|---|
| Email/password login | ✅ | ✅ | ✅ | ✅ `login_screen.dart` | ✅ |
| Register (multi-step wizard) | ✅ | ✅ | ✅ `register_wizard_controller` | ✅ `register_steps/*` | ✅ |
| Google/Apple/Microsoft sign-in | ✅ `social_auth_*` | ✅ | ✅ | ✅ `premium_login_options.dart` | ✅ |
| Phone/OTP | ✅ | ✅ | ✅ | ✅ `phone_otp_screen.dart` | ✅ |
| Forgot password | ✅ | ✅ | ✅ `password_reset_controller` | ✅ `forgot_password_screen.dart` | ✅ |
| Email verification | — | — | — | ✅ `email_verification_screen.dart` | ⚠️ verify backend trigger exists |
| Organization (business) accounts | ✅ `organization.dart` | ✅ `firestore_organization_repository` | ✅ `organization_providers` | ✅ `organization_onboarding_screen.dart`, `organization_switcher.dart` | ✅ |
| Security Center (sessions, devices) | ✅ `device_session.dart`, `mfa_method.dart` | ✅ `firestore_security_repository` | ✅ `security_providers` | ✅ `security_center_screen.dart` | ✅ |
| Rate limiting | — | — | `core/services/auth_rate_limiter.dart` | — | ✅ |
| Session persistence | — | — | `core/services/session_service.dart`, `secure_token_service.dart` | — | ✅ |

## Marketplace (`lib/features/marketplace/`) — see `modules/MARKETPLACE.md`

| Feature | Status | Notes |
|---|---|---|
| Product catalog / listing | ⚠️ | `products_screen.dart`, `product_detail_screen.dart` exist |
| Categories | ⚠️ | `category.dart`, `category_card.dart` exist |
| Search | ⚠️ | `product_search_screen.dart`, client-side filtering only (`firestore_product_data_source.dart`) |
| Advanced filters | ❌ | not implemented |
| Cart | ⚠️ | `cart_screen.dart`, `firestore_cart_repository.dart` exist; confirm all CRUD paths work |
| Wishlist | ⚠️ | `wishlist_screen.dart`, `firestore_wishlist_repository.dart` exist |
| Checkout | ❌ | `checkout_screen.dart` is a **stub/placeholder** — no real checkout entity, no payment step |
| Orders (history/detail) | ⚠️ | `order_confirmation_screen.dart`, `order_detail_screen.dart` exist; `firestore_order_repository.dart` exists — verify against real checkout flow once that's built |
| Reviews & ratings | ⚠️ | `review.dart` entity exists, no dedicated reviews screen/repository wiring confirmed |
| Coupons / promotions | ⚠️ | `coupon.dart`, `firestore_coupon_repository.dart` exist, no UI application flow confirmed |
| Bundles | ❌ | `bundles` collection referenced in code but no dedicated entity/screen found |
| Recommendations / recently viewed | ⚠️ | `recommendation.dart` entity + `recently_viewed`/`recommendations` collections referenced; UI wiring unclear |
| Analytics (seller-facing) | ⚠️ | `firestore_analytics_repository.dart` exists, no dashboard UI |
| Project Cart (vision feature: "100m² house → material list") | ❌ | not started — this is a differentiator feature from the product vision, needs its own design pass |

## Business / Seller (`lib/features/business/`) — see `modules/SELLER.md (and modules/B2B.md for company structure)`

| Feature | Status | Notes |
|---|---|---|
| Business account entity/repo | ⚠️ | `business_account.dart`, `firestore_business_account_repository.dart` exist |
| Seller analytics entity/repo | ⚠️ | entity exists, no dashboard screen |
| Loyalty program entity/repo | ⚠️ | `loyalty.dart`, `firestore_loyalty_repository.dart` exist, no UI |
| Seller Dashboard (orders, inventory, payouts, RFQ invitations) | ❌ | no `presentation/` folder at all yet |
| KYC/KYB verification | ❌ | not started |
| Trust score / Verified Supplier badge | ❌ | not started |

## Procurement (`lib/features/procurement/`) — see `modules/PROCUREMENT.md`

| Feature | Status | Notes |
|---|---|---|
| RFQ entity/repo | ⚠️ | `rfq.dart`, `firestore_rfq_repository.dart` exist |
| Inventory entity/repo | ⚠️ | `inventory.dart`, `firestore_inventory_repository.dart` exist |
| Warehouse entity/repo | ⚠️ | `warehouse.dart`, `firestore_warehouse_repository.dart` exist |
| RFQ submission/response UI | ❌ | no `presentation/` folder yet |
| Purchase Orders | ❌ | not started |
| Company structure (employees, departments, budgets, approvals) | ❌ | not started — depends on Auth's `organization.dart` as base |

## Tender / Reverse auction — see `modules/TENDER_RFQ.md`

Nothing built. Fully greenfield — spec lives in the module doc.

## Chat & Notifications (`lib/features/chat/`) — see `modules/CHAT.md`

| Feature | Status | Notes |
|---|---|---|
| Chat session/message entities+repo | ⚠️ | exist, no `application/`/`presentation/` |
| Notification entity+repo | ⚠️ | exist, no UI |
| Visual search entity+repo | ⚠️ | exist, purpose/usage unclear — confirm with product owner before building on it |
| Buyer↔seller messaging UI | ❌ | not started |
| Push notifications (FCM) | ❌ | not wired |

## Logistics, Admin, Analytics, AI, Payments

Not started. See `modules/LOGISTICS.md`, `modules/ADMIN.md`, `modules/ANALYTICS.md`,
`modules/AI.md`, `08_PAYMENT_ARCHITECTURE.md`.

## Cross-cutting

| Item | Status |
|---|---|
| Firestore security rules | ❌ **no `firestore.rules` file in repo at all** — see `06_FIREBASE_RULES.md` |
| Automated tests | ❌ only default `test/widget_test.dart` placeholder |
| Cloud Functions | ❌ none — blocks server-side payments, KYC, notifications triggers |
| CI/CD | ⚠️ `.github/workflows/opencode.yml` present (agent runner config, not a build/test/deploy pipeline) |
