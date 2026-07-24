# Tables

Convention for every table: `id uuid primary key default gen_random_uuid()`,
`created_at timestamptz not null default now()`, `updated_at timestamptz not null default now()`
(kept current via a trigger, see `10_DATABASE_TRIGGERS.md`). Soft-delete via
`deleted_at timestamptz` where the domain needs it (orders, products) rather than hard delete.

This file gives full column definitions for the **core tables agents are most likely to touch
first** (identity, catalog, orders, payments, RFQ, tender, communication). Every other table
listed in `01_DOMAIN_MODEL.md` follows the same conventions (uuid PK, timestamps, FK naming
`<table_singular>_id`) — when you need one that isn't spelled out here, define it inline in
your task's PR following this pattern and add it to this file.

## users
```sql
id            uuid primary key default gen_random_uuid()   -- = auth.users.id in Supabase
email         text unique not null
phone         text unique
display_name  text
avatar_url    text
account_type  text not null default 'individual'  -- 'individual' | 'company_member'
created_at    timestamptz not null default now()
updated_at    timestamptz not null default now()
```

## organizations
*(see `decisions/ADR-006-IDENTITY-MODEL.md` — this is the single company/business-entity
table; there is no separate `companies` table)*
```sql
id              uuid primary key default gen_random_uuid()
type            text not null default 'company'  -- 'company' | 'individual' (lightweight
                                                   -- org row backing a one-person seller)
name            text not null
legal_name      text
tax_id          text
verification_status text not null default 'unverified' -- 'unverified'|'pending'|'verified'|'rejected'
created_at      timestamptz not null default now()
updated_at      timestamptz not null default now()
```

## organization_members
```sql
id              uuid primary key default gen_random_uuid()
organization_id uuid not null references organizations(id) on delete cascade
user_id         uuid not null references users(id)
role            text not null default 'employee'  -- 'owner'|'admin'|'procurement'|'finance'|'employee'
unique (organization_id, user_id)
created_at      timestamptz not null default now()
```

## products
```sql
id            uuid primary key default gen_random_uuid()
seller_id     uuid not null references seller_profiles(id)
name          text not null
description   text
brand_id      uuid references brands(id)
base_price    numeric(12,2) not null
currency      text not null default 'AZN'
status        text not null default 'draft'  -- 'draft'|'active'|'archived'
created_at    timestamptz not null default now()
updated_at    timestamptz not null default now()
deleted_at    timestamptz
```

## product_variants
```sql
id            uuid primary key default gen_random_uuid()
product_id    uuid not null references products(id) on delete cascade
sku           text unique not null
attributes    jsonb not null default '{}'  -- {"size": "25kg", "grade": "M400"}
price         numeric(12,2) not null
```

## orders
```sql
id            uuid primary key default gen_random_uuid()
buyer_id      uuid not null references users(id)
seller_id     uuid not null references seller_profiles(id)
status        text not null default 'pending'  -- see order_status_history for full lifecycle
subtotal      numeric(12,2) not null
total         numeric(12,2) not null
currency      text not null default 'AZN'
shipping_address_id uuid references delivery_addresses(id)
created_at    timestamptz not null default now()
updated_at    timestamptz not null default now()
```
`orders.status` is never written directly by a client — see `07_RLS_POLICIES.md` and
`docs/08_PAYMENT_ARCHITECTURE.md`. Transitions go through `order_status_history` inserts made
by a database function/Edge Function (`09_DATABASE_FUNCTIONS.md`).

## payments
```sql
id             uuid primary key default gen_random_uuid()
order_id       uuid references orders(id)
purchase_order_id uuid references purchase_orders(id)  -- for B2B path
provider       text not null   -- e.g. 'stripe'
provider_ref   text not null   -- provider's payment intent id
amount         numeric(12,2) not null
status         text not null default 'pending'  -- 'pending'|'succeeded'|'failed'|'refunded'
created_at     timestamptz not null default now()
```
**Server-only writes.** Client never sets `status`. See `07_RLS_POLICIES.md`.

## rfqs
```sql
id                uuid primary key default gen_random_uuid()
organization_id   uuid not null references organizations(id)
purchase_request_id uuid references purchase_requests(id)
title             text not null
delivery_location text
deadline          timestamptz not null
budget            numeric(12,2)
status            text not null default 'open'  -- 'open'|'closed'|'awarded'|'cancelled'
created_at        timestamptz not null default now()
```

## tenders
```sql
id            uuid primary key default gen_random_uuid()
rfq_id        uuid references rfqs(id)
mode          text not null   -- 'open'|'sealed'|'reverse_auction'|'multi_round'
current_round int not null default 1
status        text not null default 'open'  -- 'open'|'evaluating'|'awarded'|'cancelled'
created_at    timestamptz not null default now()
```

## tender_bids
```sql
id             uuid primary key default gen_random_uuid()
tender_id      uuid not null references tenders(id)
seller_id      uuid not null references seller_profiles(id)
round          int not null default 1
price          numeric(12,2) not null
delivery_days  int
submitted_at   timestamptz not null default now()
-- sealed-bid mode: rows are not readable by other bidders until tender.status = 'evaluating'
-- (enforced in RLS, see 07_RLS_POLICIES.md)
```

## conversations
```sql
id            uuid primary key default gen_random_uuid()
context_type  text  -- nullable: 'product'|'order'|'rfq'|'tender'
context_id    uuid  -- nullable, polymorphic — points at the relevant row for context_type
created_at    timestamptz not null default now()
```

## messages
```sql
id               uuid primary key default gen_random_uuid()
conversation_id  uuid not null references conversations(id) on delete cascade
sender_id        uuid not null references users(id)
body             text
created_at       timestamptz not null default now()
```

## seller_profiles
*(replaces Firestore's `business_accounts` + `sellers` — see ADR-006)*
```sql
id              uuid primary key default gen_random_uuid()
organization_id uuid not null unique references organizations(id)
store_name      text not null
description     text
status          text not null default 'active'  -- 'active'|'suspended'
created_at      timestamptz not null default now()
```

## seller_reputation
```sql
seller_id           uuid primary key references seller_profiles(id)
trust_score          numeric(5,2) not null default 0   -- 0-100, see 09_DATABASE_FUNCTIONS.md
on_time_delivery_pct numeric(5,2)
cancellation_rate    numeric(5,2)
dispute_rate         numeric(5,2)
updated_at           timestamptz not null default now()
```

## All other tables (defined by convention, not fully spelled out here)

`user_profiles`, `roles`, `permissions`, `user_roles`, `organization_roles`,
`organization_addresses`, `business_verifications`, `product_images`, `categories`, `brands`,
`attributes`, `product_attributes`, `product_categories`,
`seller_verifications`, `seller_stores`, `seller_addresses`, `seller_payout_accounts`,
`warehouses`, `warehouse_inventory`, `inventory_movements`, `stock_reservations`, `carts`,
`cart_items`, `wishlists`, `wishlist_items`, `order_items`, `order_status_history`, `returns`,
`return_items`, `refunds`, `payment_transactions`, `payment_methods`, `payment_webhooks`,
`seller_payouts`, `platform_commissions`, `projects`, `project_members`, `budgets`,
`budget_items`, `purchase_requests`, `purchase_request_items`, `rfq_items`, `rfq_invitations`,
`supplier_responses`, `quotes`, `quote_items`, `tender_participants`, `tender_evaluations`,
`tender_awards`, `purchase_orders`, `purchase_order_items`, `contracts`, `contract_parties`,
`invoices`, `invoice_items`, `invoice_payments`, `shipments`, `shipment_items`,
`delivery_addresses`, `delivery_events`, `carriers`, `conversation_members`,
`message_attachments`, `notifications`, `notification_preferences`, `push_tokens`, `reviews`,
`ratings`, `disputes`, `reports`, `audit_logs`, `admin_actions`, `security_events`,
`fraud_alerts`.

**Tender audit tables** (added per review — see `docs/modules/TENDER_RFQ.md`): `tender_events`
(every state change, timestamped, who), `tender_rounds` (per-round metadata for multi-round
tenders), `bid_revisions` (history of a bid being changed, not just its current value),
`bid_attachments` (files attached to a bid — certificates, spec sheets),
`bid_evaluation_criteria` (the weighted criteria — price/reliability/delivery — used by
`tender_evaluations`, so "why did the AI pick Supplier A" is reconstructable after the fact).
These exist specifically so tender outcomes are auditable and defensible, which matters more
here than almost anywhere else in the schema since real money and legal disputes can follow a
tender award.

When an agent's task requires one of these, define its full DDL in the task and append it to
this file — don't leave it undocumented once it exists in the actual schema.
