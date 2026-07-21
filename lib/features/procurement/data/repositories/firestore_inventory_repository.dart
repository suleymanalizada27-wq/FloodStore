import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:floodstore/features/procurement/domain/entities/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../../../core/enums/inventory_status.dart';

class FirestoreInventoryRepository implements InventoryRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreInventoryRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference get _inventoryRef =>
      _firestore.collection('inventory_items');

  @override
  Future<String> createInventoryItem(InventoryItem item) async {
    try {
      final docRef = await _inventoryRef.add(item.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create inventory item: $e');
    }
  }

  @override
  Future<InventoryItem?> getInventoryItem(String id) async {
    try {
      final doc = await _inventoryRef.doc(id).get();
      if (!doc.exists) return null;
      return InventoryItem.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get inventory item: $e');
    }
  }

  @override
  Future<List<InventoryItem>> getInventoryItemsByProduct(String productId, {
    int limit = 20,
    String? lastDocumentId,
    String? warehouseId,
    InventoryStatus? status,
  }) async {
    try {
      fs.Query query = _inventoryRef
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true);

      if (warehouseId != null) {
        query = query.where('warehouseId', isEqualTo: warehouseId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _inventoryRef.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get inventory items by product: $e');
    }
  }

  @override
  Future<List<InventoryItem>> getInventoryItemsByWarehouse(String warehouseId, {
    int limit = 20,
    String? lastDocumentId,
    String? productId,
    InventoryStatus? status,
  }) async {
    try {
      fs.Query query = _inventoryRef
          .where('warehouseId', isEqualTo: warehouseId)
          .orderBy('createdAt', descending: true);

      if (productId != null) {
        query = query.where('productId', isEqualTo: productId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _inventoryRef.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get inventory items by warehouse: $e');
    }
  }

  @override
  Future<void> updateInventoryItem(InventoryItem item) async {
    try {
      await _inventoryRef.doc(item.id).update(item.toFirestore());
    } catch (e) {
      throw Exception('Failed to update inventory item: $e');
    }
  }

  @override
  Future<void> deleteInventoryItem(String id) async {
    try {
      await _inventoryRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete inventory item: $e');
    }
  }

  @override
  Future<void> updateInventoryQuantity(
    String itemId,
    double quantity,
    double reservedQuantity,
  ) async {
    try {
      await _inventoryRef.doc(itemId).update({
        'quantity': quantity,
        'reservedQuantity': reservedQuantity,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update inventory quantity: $e');
    }
  }

  @override
  Future<bool> reserveInventory(
    String itemId,
    double quantity,
    String reservationId,
  ) async {
    try {
      final docRef = _inventoryRef.doc(itemId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Inventory item not found');
      }

      final data = doc.data() as Map<String, dynamic>;

      final currentQuantity = (data['quantity'] as num?)?.toDouble() ?? 0;
      final currentReserved = (data['reservedQuantity'] as num?)?.toDouble() ?? 0;
      final availableQuantity = currentQuantity - currentReserved;

      if (availableQuantity < quantity) {
        return false; // Not enough inventory
      }

      await docRef.update({
        'reservedQuantity': currentReserved + quantity,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to reserve inventory: $e');
    }
  }

  @override
  Future<void> releaseInventory(
    String itemId,
    double quantity,
    String reservationId,
  ) async {
    try {
      final docRef = _inventoryRef.doc(itemId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Inventory item not found');
      }

      final data = doc.data() as Map<String, dynamic>;

      final currentReserved = (data['reservedQuantity'] as num?)?.toDouble() ?? 0;
      final newReserved = (currentReserved - quantity).clamp(0.0, double.infinity);

      await docRef.update({
        'reservedQuantity': newReserved,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to release inventory: $e');
    }
  }

  @override
  Future<void> transferInventory(
    String itemId,
    String fromWarehouseId,
    String toWarehouseId,
    double quantity,
  ) async {
    try {
      // Start a batch operation for atomicity
      final batch = _firestore.batch();

      // Get the source item
      final sourceDocRef = _inventoryRef.doc(itemId);
      final sourceDoc = await sourceDocRef.get();

      if (!sourceDoc.exists) {
        throw Exception('Inventory item not found');
      }

      final sourceData = sourceDoc.data();
      if (sourceData == null) {
        throw Exception('Inventory item data is null');
      }

      final currentQuantity = (sourceData['quantity'] as num?)?.toDouble() ?? 0;
      final currentReserved = (sourceData['reservedQuantity'] as num?)?.toDouble() ?? 0;
      final availableQuantity = currentQuantity - currentReserved;

      if (availableQuantity < quantity) {
        throw Exception('Insufficient inventory for transfer');
      }

      // Update source item quantity
      batch.update(sourceDocRef, {
        'quantity': currentQuantity - quantity,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });

      // Create or update destination item
      final destinationQuery = await _inventoryRef
          .where('productId', isEqualTo: sourceData['productId'])
          .where('warehouseId', isEqualTo: toWarehouseId)
          .limit(1)
          .get();

      if (destinationQuery.docs.isNotEmpty) {
        // Update existing destination item
        final destDoc = destinationQuery.docs.first;
        final destData = destDoc.data();
        if (destData == null) {
          throw Exception('Destination inventory item data is null');
        }

        final destQuantity = (destData['quantity'] as num?)?.toDouble() ?? 0;
        final destReserved = (destData['reservedQuantity'] as num?)?.toDouble() ?? 0;

        batch.update(destDoc.reference, {
          'quantity': destQuantity + quantity,
          'updatedAt': fs.FieldValue.serverTimestamp(),
        });
      } else {
        // Create new destination item
        final newItem = InventoryItem(
          id: '', // Will be set by Firestore
          productId: sourceData['productId'] ?? '',
          warehouseId: toWarehouseId,
          batchNumber: sourceData['batchNumber'],
          serialNumber: sourceData['serialNumber'],
          quantity: quantity,
          reservedQuantity: 0,
          unitOfMeasure: sourceData['unitOfMeasure'] ?? '',
          status: sourceData['status'] ?? 'available',
          receivedDate: sourceData['receivedDate'] != null
              ? DateTime.parse(sourceData['receivedDate'])
              : null,
          expiryDate: sourceData['expiryDate'] != null'
          ? Date'] != null
              ? DateTime.parse(sourceData['expiryDate'])
              : null,
          manufacturingDate: sourceData['manufacturingDate'] != null
              ? DateTime.parse(sourceData['manufacturingDate'])
              : null,
          certifications: sourceData['certifications'] != null
              ? List<String>.from(sourceData['certifications'])
              : null,
          testResults: sourceData['testResults'] as Map<String, dynamic>?,
          locationDetails: sourceData['locationDetails'],
          unitCost: (sourceData['unitCost'] as num?)?.toDouble(),
          supplierId: sourceData['supplierId'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final newDocRef = _inventoryRef.doc();
        batch.set(newDocRef, newItem.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to transfer inventory: $e');
    }
  }
}