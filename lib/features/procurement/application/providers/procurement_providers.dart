import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/rfq_repository.dart';
import '../../data/repositories/firestore_warehouse_repository.dart';
import '../../data/repositories/firestore_inventory_repository.dart';
import '../../data/repositories/firestore_rfq_repository.dart';

// Repository Providers
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return FirestoreWarehouseRepository();
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return FirestoreInventoryRepository();
});

final rfqRepositoryProvider = Provider<RFQRepository>((ref) {
  return FirestoreRFQRepository();
});
