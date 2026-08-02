## Procurement (`lib/features/procurement/`) — see `modules/PROCUREMENT.md`

| Feature | Status | Notes |
|---|---|---|
| RFQ entity/repo | ⚠✽ | `rfq.dart`, `firestore_rfq_repository.dart` exist |
| Inventory entity/repo | ⚠️ | `inventory.dart`, `firestore_inventory_repository.dart` exist |
| Warehouse entity/repo | ⚠️ | `warehouse.dart`, `firestore_warehouse_repository.dart` exist |
| RFQ submission/response UI | ✅ | `presentation/` with `rfq_list_screen.dart`, `create_rfq_screen.dart`, `rfq_detail_screen.dart` exist (using mock data) |
| Purchase Orders | ❌ | not started |
| Company structure (employees, departments, budgets, approvals) | ❌ | not started — depends on Auth's `organization.dart` as base |