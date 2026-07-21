import '../../entities/inventory.dart';
import '../../entities/warehouse.dart';

/// Abstract repository for inventory-related operations
abstract class InventoryRepository {
  /// Creates a new inventory item
  Future<String> createInventoryItem(InventoryItem item);

  /// Gets an inventory item by ID
  Future<InventoryItem?> getInventoryItem(String id);

  /// Gets inventory items by product ID
  Future<List<InventoryItem>> getInventoryItemsByProduct(String productId, {
    int limit = 20,
    String? lastDocumentId,
    String? warehouseId,
    InventoryStatus? status,
  });

  /// Gets inventory items by warehouse ID
  Future<List<InventoryItem>> getInventoryItemsByWarehouse(String warehouseId, {
    int limit = 20,
    String? lastDocumentId,
    String? productId,
    InventoryStatus? status,
  });

  /// Updates an inventory item
  Future<void> updateInventoryItem(InventoryItem item);

  /// Deletes an inventory item
  Future<void> deleteInventoryItem(String id);

  /// Updates inventory quantity
  Future<void> updateInventoryQuantity(
    String itemId,
    double quantity,
    double reservedQuantity,
  );

  /// Reserves inventory for a cart/order
  Future<bool> reserveInventory(
    String itemId,
    double quantity,
    String reservationId, // cart ID or order ID
  );

  /// Releases reserved inventory
  Future<void> releaseInventory(
    String itemId,
    double quantity,
    String reservationId,
  );

  /// Transfers inventory between warehouses
  Future<void> transferInventory(
    String itemId,
    String fromWarehouseId,
    String toWarehouseId,
    double quantity,
  );
}