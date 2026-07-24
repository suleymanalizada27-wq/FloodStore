# Entity Relationships (per bounded context)

Notation: `A ──< B` means one A has many B. `A ──|| B` means one-to-one. `A >──< B` means
many-to-many (junction table named).

## Identity / Organization (see `decisions/ADR-006-IDENTITY-MODEL.md`)
```
users ──< user_roles >── roles ──< permissions (via role_permissions)
users ──< organization_members >── organizations
organizations ──< organization_addresses
organizations ──|| business_verifications
organizations ──|| seller_profiles          (nullable — only orgs that sell have one)
```

## Catalog
```
products ──< product_variants
products ──< product_images
products >──< categories        (via product_categories)
products >──< attributes         (via product_attributes)
products ──|| seller_profiles    (owning seller)
brands ──< products
```

## Sellers
```
seller_profiles ──|| organizations   (required — even a one-person seller has an org row, see ADR-006)
seller_profiles ──< seller_stores
seller_profiles ──< seller_addresses
seller_profiles ──< seller_verifications
seller_profiles ──|| seller_payout_accounts
seller_profiles ──|| seller_reputation
```

## Inventory
```
warehouses ──< warehouse_inventory >── product_variants
warehouse_inventory ──< inventory_movements
warehouse_inventory ──< stock_reservations
```

## Shopping → Orders
```
users ──|| carts ──< cart_items >── product_variants
users ──|| wishlists ──< wishlist_items >── products
orders ──< order_items >── product_variants
orders ──|| payments
orders ──< order_status_history
orders ──< returns ──< return_items
returns ──< refunds
```

## B2B / Procurement / Tender
```
organizations ──< projects ──< project_members >── users
projects ──|| budgets ──< budget_items
projects ──< purchase_requests ──< purchase_request_items
purchase_requests ──< rfqs (0 or 1 — RFQ can also be standalone)
rfqs ──< rfq_items
rfqs ──< rfq_invitations >── seller_profiles
rfq_invitations ──< supplier_responses ──< quotes ──< quote_items
rfqs ──< tenders (0 or 1 — a tender is an escalated/alternate RFQ mode)
tenders ──< tender_participants >── seller_profiles
tender_participants ──< tender_bids
tenders ──< tender_evaluations
tenders ──|| tender_awards ──|| purchase_orders
quotes ──|| purchase_orders (alternate path — accepted quote becomes a PO directly)
purchase_orders ──< purchase_order_items
purchase_orders ──|| contracts ──< contract_parties
purchase_orders ──|| invoices ──< invoice_items
invoices ──< invoice_payments
```

## Logistics
```
orders ──|| shipments  (also: purchase_orders ──|| shipments for B2B)
shipments ──< shipment_items
shipments ──< delivery_events
shipments ──|| carriers
shipments ──|| delivery_addresses
```

## Communication (cross-cutting)
```
conversations ──< conversation_members >── users
conversations ──< messages ──< message_attachments
conversations ── context: (product | order | rfq | tender), nullable polymorphic reference
```

## Trust
```
products ──< reviews ──|| ratings
seller_profiles ──|| seller_reputation
orders/rfqs/tenders ──< disputes
users ──< reports
```

Note: full column-level foreign keys are defined in `03_TABLES.md`. This file is intentionally
diagram-only so an agent can grasp one context's shape in under a minute.
