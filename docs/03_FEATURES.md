| Warehouse entity/repo | ⚠️ | `warehouse.dart`, `firestore_warehouse_repository.dart` exist |
| RFQ submission/response UI | ✅ | `presentation/` with `rfq_list_screen.dart`, `create_rfq_screen.dart`, `rfq_detail_screen.dart` exist (using mock data, awaiting Supabase) |
| Purchase Orders | ❌ | not started |
| Company structure (employees, departments, budgets, approvals) | ❌ | not started — depends on Auth's `organization.dart` as base |

## Tender / Reverse auction — see `modules/TENDER_RFQ.md`

| Feature | Status | Notes |
|---|---|---|
| Tender entity/repo | ✅ | `tender.dart`, `tender_bid.dart`, `tender_participant.dart`, `mock_tender_repository.dart` (mock, awaiting Supabase) |
| Open-mode tender UI | ✅ | `tenders_screen.dart`, `create_tender_screen.dart`, `tender_detail_screen.dart` |
| Sealed bidding | ❌ | not started |
| Reverse auction | ❌ | not started |
| Multi-round | ❌ | not started |
| Award + evaluation | ❌ | not started |
| Audit tables (tender_events, bid_revisions, etc.) | ❌ | not started, Postgres-only per `database/03_TABLES.md` |

## Chat & Notifications (`lib/features/chat/`) — see `modules/CHAT.md`