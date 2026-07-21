import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';

class FirestoreWarehouseRepository implements WarehouseRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreWarehouseRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference get _warehousesRef => _firestore.collection('warehouses');

  @override
  Future<String> createWarehouse(Warehouse warehouse) async {
    try {
      final docRef = await _warehousesRef.add(warehouse.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create warehouse: $e');
    }
  }

  @override
  Future<Warehouse?> getWarehouse(String id) async {
    try {
      final doc = await _warehousesRef.doc(id).get();
      if (!doc.exists) return null;
      return Warehouse.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get warehouse: $e');
    }
  }

  @override
  Future<List<Warehouse>> getAllWarehouses({
    int limit = 20,
    String? lastDocumentId,
    bool? isActive,
  }) async {
    try {
      fs.Query query = _warehousesRef.orderBy('createdAt', descending: true);

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _warehousesRef.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Warehouse.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get warehouses: $e');
    }
  }

  @override
  Future<void> updateWarehouse(Warehouse warehouse) async {
    try {
      await _warehousesRef.doc(warehouse.id).update(warehouse.toFirestore());
    } catch (e) {
      throw Exception('Failed to update warehouse: $e');
    }
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    try {
      await _warehousesRef.doc(id).update({
        'isActive': false,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete warehouse: $e');
    }
  }

  @override
  Future<Warehouse?> getDefaultWarehouse() async {
    try {
      final query = await _warehousesRef
          .where('isDefault', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return Warehouse.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get default warehouse: $e');
    }
  }
}