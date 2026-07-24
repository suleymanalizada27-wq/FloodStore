# Database Triggers

| Trigger | On | Action |
|---|---|---|
| `set_updated_at` | before update on any table with `updated_at` | sets `updated_at = now()` |
| `order_status_history_insert` | after update of `status` on `orders` | inserts a row into `order_status_history` automatically, so no code path can change status without leaving an audit trail |
| `recompute_reputation_on_review` | after insert on `reviews` | calls `recompute_seller_reputation(seller_id)` |
| `recompute_reputation_on_dispute` | after insert/update on `disputes` | same, keeps trust score current |
| `audit_log_sensitive_tables` | after insert/update/delete on `payments`, `seller_payouts`, `organizations.verification_status`, `tender_awards` | inserts a row into `audit_logs` |

Keep triggers small and single-purpose — one trigger per concern, not one giant trigger doing
five things, so a future agent can reason about (and disable/replace) one behavior at a time.
