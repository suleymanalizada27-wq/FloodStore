import '../entities/warehouse.dart';
import '../../../core/enums/inventory.dart';
import '../../../core/enums/inventory_status.dart';

abstract class WarehouseRepository {
  /// Creates a new warehouse
  Future<String> createWarehouse(Warehouse warehouse);

  /// Gets a warehouse by ID
  Future<Warehouse?> getWarehouse(String id);

  /// Gets all warehouses with pagination
  Future<List<Warehouse>> getAllWarehouses({
    int limit = 20,
    String? lastDocumentId,
    bool? isActive,
  });

  /// Updates a warehouse
  Future<void> updateWarehouse(Warehouse warehouse);

  /// Deletes a warehouse (soft delete by setting isActive to false)
  Future<void> deleteWarehouse(String id);

  /// Gets the default warehouse
  Future<Warehouse?> getDefaultWarehouse();
}