import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:floodstore/features/procurement/domain/entities/rfq.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/rfq_repository.dart';
import '../../data/repositories/firestore_warehouse_repository.dart';
import '../../data/repositories/firestore_inventory_repository.dart';
import '../../data/repositories/mock_rfq_repository.dart';

// Repository Providers
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return FirestoreWarehouseRepository();
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return FirestoreInventoryRepository();
});

final rfqRepositoryProvider = Provider<RFQRepository>((ref) {
  // TODO: switch to FirestoreRFQRepository when Firestore/Supabase is ready
  return MockRFQRepository();
});

// Provider for fetching RFQs by buyer (demo)
final rfqListProvider = FutureProvider<List<RFQ>>((ref) {
  final repo = ref.read(rfqRepositoryProvider);
  return repo.getRFQsByBuyer('buyer_001');
});

// Provider for fetching a single RFQ by ID
final rfqProvider = FutureProvider.family<RFQ?, String>((ref, rfqId) {
  final repo = ref.read(rfqRepositoryProvider);
  return repo.getRFQ(rfqId);
});

// Provider for fetching RFQ items by RFQ ID
final rfqItemsProvider = FutureProvider.family<List<RFQItem>, String>((ref, rfqId) {
  final repo = ref.read(rfqRepositoryProvider);
  return repo.getRFQItems(rfqId);
});

// Provider for fetching RFQ responses by RFQ ID
final rfqResponsesProvider = FutureProvider.family<List<RFQResponse>, String>((ref, rfqId) {
  final repo = ref.read(rfqRepositoryProvider);
  return repo.getRFQResponses(rfqId);
});