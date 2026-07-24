# Domain Model (target Postgres schema, conceptual)

Bounded contexts, each becomes a schema or a clearly-prefixed table group in Postgres.
This is the model, not SQL — see `03_TABLES.md` for actual DDL-level detail.

## Identity
`users` · `user_profiles` · `roles` · `permissions` · `user_roles`
A user has one profile, many roles (via `user_roles`), each role has permissions.

## Organization (unified company/business entity — see `decisions/ADR-006-IDENTITY-MODEL.md`)
`organizations` · `organization_members` · `organization_roles` · `organization_addresses` ·
`business_verifications`

**This table replaces the earlier separate "companies" concept, plus Firestore's
`business_accounts`/`sellers` split — see ADR-006 for the full reasoning.** An organization
represents any business-like entity: a real company (B2B buyer, or a seller with a storefront)
or a lightweight "individual seller" identity (`organizations.type = 'individual'`). A user
gets access to an organization via `organization_members` with an `organization_role`. KYB
verification (`business_verifications`) is 1:1 (or 1:many for history) per organization.

Departments, Projects, and Budgets (B2B module) all hang off `organizations` directly — there
is no separate "companies" table for them to reference.

## Marketplace — Catalog
`products` · `product_variants` · `product_images` · `categories` · `brands` · `attributes` ·
`product_attributes` · `product_categories`
Product → many variants, many images, many-to-many categories (via `product_categories`) and
attributes (via `product_attributes`, EAV-style for construction-specific specs like
dimensions/grade/certification).

## Sellers
`seller_profiles` · `seller_verifications` · `seller_stores` · `seller_addresses` ·
`seller_payout_accounts`
A `seller_profile` belongs to exactly one `organization` (never directly to a `user` — see
ADR-006; even a one-person seller has a lightweight `organization` row). `seller_verifications`
is the KYC/KYB trust layer feeding the trust score described in the product vision.

## Inventory
`warehouses` · `warehouse_inventory` · `inventory_movements` · `stock_reservations`
warehouse_inventory is per-(warehouse, variant) stock level. inventory_movements is the audit
trail. stock_reservations holds stock during checkout/RFQ commitment before an order confirms.

## Shopping
`carts` · `cart_items` · `wishlists` · `wishlist_items`

## Orders
`orders` · `order_items` · `order_status_history` · `returns` · `return_items` · `refunds`

## Payments
`payments` · `payment_transactions` · `payment_methods` · `payment_webhooks` ·
`seller_payouts` · `platform_commissions`
All writes to `payments`/`payment_transactions`/`seller_payouts` are server-only (Edge
Function / service role), never client-writable — see `07_RLS_POLICIES.md`.

## B2B (project & procurement front door)
`projects` · `project_members` · `budgets` · `budget_items` · `purchase_requests` ·
`purchase_request_items`
This is the "Project-based Commerce" layer from the product vision: a company creates a
Project, sets a budget, employees raise purchase_requests against it, which feed procurement.

## Procurement
`rfqs` · `rfq_items` · `rfq_invitations` · `supplier_responses` · `quotes` · `quote_items`
An rfq is created from a purchase_request (or standalone). rfq_invitations targets specific
sellers. supplier_responses/quotes are what sellers submit back.

## Tender
`tenders` · `tender_participants` · `tender_bids` · `tender_evaluations` · `tender_awards` ·
`tender_events` · `tender_rounds` · `bid_revisions` · `bid_attachments` ·
`bid_evaluation_criteria`
Distinct from RFQ: tenders support multi-round, sealed-bid, and reverse-auction modes (see
`docs/modules/TENDER_RFQ.md`). tender_evaluations stores the scoring (price + reliability +
delivery, per the AI Tender Assistant concept in the vision doc), weighted against
bid_evaluation_criteria. tender_events/bid_revisions give a full audit trail (who bid what,
when, and what changed) since tender_awards is the final decision and is immutable once set —
this needs to be defensible after the fact, not just correct at the time.

## Purchasing (post-award / post-RFQ execution)
`purchase_orders` · `purchase_order_items` · `contracts` · `contract_parties`

## Invoicing
`invoices` · `invoice_items` · `invoice_payments`

## Logistics
`shipments` · `shipment_items` · `delivery_addresses` · `delivery_events` · `carriers`

## Communication
`conversations` · `conversation_members` · `messages` · `message_attachments`
This is the buyer↔seller relationship layer. A conversation can be linked to a product, an
order, an RFQ, or a tender via a nullable `context_type` + `context_id` pair — see
`03_TABLES.md`.

## Notifications
`notifications` · `notification_preferences` · `push_tokens`

## Trust
`reviews` · `ratings` · `seller_reputation` · `disputes` · `reports`
seller_reputation is a materialized/derived table (trust score) computed from ratings +
on-time delivery + dispute rate — see `09_DATABASE_FUNCTIONS.md`.

## Admin / Security
`audit_logs` · `admin_actions` · `security_events` · `fraud_alerts`

## Top-level relationship sketch

```
Company ── Members
   │
   ├── Projects ── Purchase Requests ── RFQ ── Quotes ── Purchase Order ── Invoice
   │
   └── Contracts

Product ── Seller
   │
   ├── Category
   ├── Variants ── Warehouse Inventory
   └── Reviews

Order ── Buyer, Seller
   │
   ├── Items
   ├── Payment
   ├── Invoice
   ├── Shipment
   └── Refund

Tender ── Participants ── Bids ── Evaluation ── Award ── Purchase Order
```
