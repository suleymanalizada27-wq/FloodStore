# Row-Level Security Policies (Postgres/Supabase)

This is the Postgres-target equivalent of `docs/06_FIREBASE_RULES.md`. `auth.uid()` is a
Supabase-provided function; the plain-Postgres equivalent is a session variable
(`current_setting('request.jwt.claims', true)::json->>'sub'`) set by whatever server layer
sits in front of Postgres if FloodStore ever leaves Supabase — see `00_DATABASE_OVERVIEW.md`.

## Pattern

```sql
alter table <table> enable row level security;

create policy "<table>_select_own" on <table>
  for select using (auth.uid() = owner_id);

create policy "<table>_insert_own" on <table>
  for insert with check (auth.uid() = owner_id);
```

## Table-by-table intent (write actual SQL when the table is implemented)

| Table | Select | Insert/Update | Notes |
|---|---|---|---|
| `products` | public | seller (owner) only | status='draft' hidden from public select |
| `orders` | buyer or seller of that order | **no direct client insert/update of `status`** | status changes go through a `security definer` function only (see `09_DATABASE_FUNCTIONS.md`) |
| `payments`, `payment_transactions`, `seller_payouts` | involved parties, select only | **no client insert/update at all** — service role / Edge Function only |
| `rfqs` | company members (owner) + invited sellers | company members create/update | |
| `rfq_invitations` / `supplier_responses` | the specific invited seller + the RFQ owner | seller writes own response only | |
| `tender_bids` | own bids always; other bidders' bids only after `tenders.status = 'evaluating'` (sealed bidding) | seller inserts own bid only | enforce sealed-bid via a `using` clause checking tender status |
| `conversations` / `messages` | conversation members only | members insert messages; no editing/deleting others' messages | |
| `organizations` / `organization_members` | org members | `owner`/`admin` role only for member management | see ADR-006 — replaces old `companies` concept |
| `seller_reputation` | public select | **no client writes** — computed by trigger/function | |
| `audit_logs` | admin only | system-inserted only | |

## Principles (mirrors 06_FIREBASE_RULES.md)

1. Never let a client set a trust-sensitive field (`verification_status`, `trust_score`,
   `payment.status`, `payout.status`) directly — those go through `security definer` functions
   or the service-role key from an Edge Function, never a plain RLS `update` policy.
2. Prefer explicit `select`/`insert`/`update`/`delete` policies over a blanket `for all`.
3. Every table gets RLS enabled the same task it's created in. A table with RLS off by mistake
   is a full data leak in Postgres (unlike Firestore's default-deny) — this is the single most
   important habit to carry over from the Firestore rules work already flagged as missing.
