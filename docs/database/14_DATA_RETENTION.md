# Data Retention

| Data | Retention | Notes |
|---|---|---|
| `audit_logs` | Indefinite | See `11_AUDIT_LOGGING.md` |
| `orders`, `invoices`, `payments` | Indefinite (financial record) | Confirm against Azerbaijani/local financial record-keeping requirements before finalizing — not yet researched |
| `carts` (abandoned, no order created) | 90 days, then hard delete | Reduce PII footprint of never-completed carts |
| `chat_messages`/`messages` | Indefinite unless a user requests deletion | Consider soft-delete (`deleted_at`) so conversation context isn't lost for the other participant |
| `notifications` | 180 days, then archive/delete | Operational, not a legal record |
| `security_events`, `fraud_alerts` | 1 year minimum | Needed for pattern detection over time |
| `push_tokens` | Delete on logout / token invalidation signal from FCM/APNs | Stale tokens waste notification sends |

This is a first-pass policy, not a legal opinion — flag to a human before treating any of the
"indefinite" rows as final, especially around financial records and any future GDPR-style
obligations mentioned in `docs/10_SECURITY.md`.
