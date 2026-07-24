# Security

## Current posture

| Area | State |
|---|---|
| Auth | Firebase Auth, rate-limited (`auth_rate_limiter.dart`), secure token storage, biometric unlock (`local_auth`) |
| Firestore rules | **Missing entirely** — see `06_FIREBASE_RULES.md`, top TODO priority |
| Secrets | None found hardcoded in reviewed files; keep verifying as modules are added — no API keys belong in Dart source |
| Payment security | N/A yet — payments not implemented, see `08_PAYMENT_ARCHITECTURE.md` |
| App Check | Not configured |
| Rate limiting beyond auth | Not present for general API/write abuse (matters once RFQ/tender/chat are public-facing) |
| Audit logs | Not present in Firestore; planned for Postgres target (`database/11_AUDIT_LOGGING.md`) |

## Threat → risk → mitigation (fill in as each module ships)

| Threat | Risk | Mitigation |
|---|---|---|
| No Firestore rules | Any authenticated (or even anonymous, depending on project mode) client can read/write any collection | Ship `firestore.rules` immediately — `06_FIREBASE_RULES.md` |
| Client sets `orders.status`/`payments.status` | Fake "paid" orders, stolen goods | Server-only writes via Cloud/Edge Function, enforced in rules/RLS |
| Sealed tender bids readable early | Bid sniping, unfair tenders | RLS visibility rule gated on `tenders.status`, `database/07_RLS_POLICIES.md` |
| KYC/verification flag client-writable | Fake "verified" sellers | Server-only writes, admin-only mutation path |
| No rate limiting on RFQ/tender/chat writes | Spam, abuse, scraping | Add per-collection write throttling once these ship |

## Data privacy

No formal GDPR-style policy documented yet. Given the platform will hold company tax IDs,
addresses, and financial records, this needs a real pass before B2B/payments go to production
— flag to a human, don't invent a compliance stance here.
