# Enums

Prefer Postgres `text` + `check` constraint over native `enum` types for anything likely to
grow (statuses, modes) — native enums require a migration to add a value, `check` constraints
are a one-line change. Reserve native `enum` for genuinely closed sets.

| Enum | Values | Used by |
|---|---|---|
| `order_status` | pending, confirmed, paid, preparing, shipped, delivered, cancelled, refunded | orders.status, order_status_history.status |
| `payment_status` | pending, succeeded, failed, refunded, partially_refunded | payments.status |
| `rfq_status` | open, closed, awarded, cancelled | rfqs.status |
| `tender_mode` | open, sealed, reverse_auction, multi_round | tenders.mode |
| `tender_status` | open, evaluating, awarded, cancelled | tenders.status |
| `verification_status` | unverified, pending, verified, rejected | organizations.verification_status, seller_verifications.status |
| `account_type` | individual, company_member | users.account_type |
| `company_role` | owner, admin, procurement, finance, employee | company_members.role |
| `dispute_status` | open, investigating, resolved, escalated | disputes.status |
| `context_type` | product, order, rfq, tender | conversations.context_type |

Mirror any status enum used in Postgres as a matching Dart enum in
`lib/core/enums/` (the repo already has this pattern — see `inventory_status.dart`) so the
client and database never drift.
