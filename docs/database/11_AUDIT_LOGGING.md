# Audit Logging

`audit_logs` captures every write to a trust-sensitive table (see `10_DATABASE_TRIGGERS.md`)
plus every action taken through the admin panel (`docs/modules/ADMIN.md`).

```sql
audit_logs
  id            uuid pk
  actor_id      uuid            -- null if system-triggered
  entity_type   text not null   -- 'order' | 'payment' | 'company' | 'tender' | ...
  entity_id     uuid not null
  action        text not null   -- 'status_changed' | 'verified' | 'awarded' | ...
  before        jsonb
  after         jsonb
  created_at    timestamptz not null default now()
```

Retention: audit logs are exempt from the deletion rules in `14_DATA_RETENTION.md` — keep
indefinitely (or per legal/financial record-keeping requirements once that's researched).
