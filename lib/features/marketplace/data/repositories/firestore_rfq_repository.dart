import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../domain/entities/rfq.dart';
import '../../domain/repositories/rfq_repository.dart';

class FirestoreRFQRepository implements RFQRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreRFQRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  // Collection references
  fs.CollectionReference get _rfqsRef => _firestore.collection('rfqs');
  fs.CollectionReference get _rfqItemsRef =>
      _firestore.collection('rfq_items');
  fs.CollectionReference get _rfqResponsesRef =>
      _firestore.collection('rfq_responses');
  fs.CollectionReference get _rfqResponseItemsRef =>
      _firestore.collection('rfq_response_items');

  @override
  Future<String> createRFQ(RFQ rfq) async {
    try {
      final docRef = await _rfqsRef.add(rfq.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create RFQ: $e');
    }
  }

  @override
  Future<RFQ?> getRFQ(String id) async {
    try {
      final doc = await _rfqsRef.doc(id).get();
      if (!doc.exists) return null;
      return RFQ.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get RFQ: $e');
    }
  }

  @override
  Future<List<RFQ>> getRFQsByBuyer(String buyerId, {
    int limit = 20,
    String? lastDocumentId,
    String? status,
  }) async {
    try {
      fs.Query query = _rfqsRef
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _rfqsRef.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RFQ.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get RFQs by buyer: $e');
    }
  }

  @override
  Future<List<RFQ>> getRFQsByStatus(String status, {
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      fs.Query query = _rfqsRef
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true);

      if (lastDocumentId != null) {
        final lastDoc = await _rfqsRef.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RFQ.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get RFQs by status: $e');
    }
  }

  @override
  Future<void> updateRFQ(RFQ rfq) async {
    try {
      await _rfqsRef.doc(rfq.id).update(rfq.toFirestore());
    } catch (e) {
      throw Exception('Failed to update RFQ: $e');
    }
  }

  @override
  Future<void> deleteRFQ(String id) async {
    try {
      await _rfqsRef.doc(id).update({
        'status': 'cancelled',
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete RFQ: $e');
    }
  }

  @override
  Future<String> createRFQItem(RFQItem item) async {
    try {
      final docRef = await _rfqItemsRef.add(item.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create RFQ item: $e');
    }
  }

  @override
  Future<RFQItem?> getRFQItem(String id) async {
    try {
      final doc = await _rfqItemsRef.doc(id).get();
      if (!doc.exists) return null;
      return RFQItem.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get RFQ item: $e');
    }
  }

  @override
  Future<List<RFQItem>> getRFQItems(String rfqId) async {
    try {
      final snapshot = await _rfqItemsRef
          .where('rfqId', isEqualTo: rfqId)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => RFQItem.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get RFQ items: $e');
    }
  }

  @override
  Future<void> updateRFQItem(RFQItem item) async {
    try {
      await _rfqItemsRef.doc(item.id).update(item.toFirestore());
    } catch (e) {
      throw Exception('Failed to update RFQ item: $e');
    }
  }

  @override
  Future<void> deleteRFQItem(String id) async {
    try {
      await _rfqItemsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete RFQ item: $e');
    }
  }

  @override
  Future<String> createRFQResponse(RFQResponse response) async {
    try {
      final docRef = await _rfqResponsesRef.add(response.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create RFQ response: $e');
    }
  }

  @override
  Future<RFQResponse?> getRFQResponse(String id) async {
    try {
      final doc = await _rfqResponsesRef.doc(id).get();
      if (!doc.exists) return null;
      return RFQResponse.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get RFQ response: $e');
    }
  }

  @override
  Future<List<RFQResponse>> getRFQResponses(String rfqId) async {
    try {
      final snapshot = await _rfqResponsesRef
          .where('rfqId', isEqualTo: rfqId)
          .orderBy('responseDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RFQResponse.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get RFQ responses: $e');
    }
  }

  @override
  Future<List<RFQResponse>> getRFQResponsesBySupplier(String supplierId, {
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      fs.Query query = _rfqResponsesRef
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('responseDate', descending: true);

      if (lastDocumentId != null) {
        final lastDoc = await _rfqResponsesRef.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RFQResponse.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get RFQ responses by supplier: $e');
    }
  }

  @override
  Future<void> updateRFQResponse(RFQResponse response) async {
    try {
      await _rfqResponsesRef.doc(response.id).update(response.toFirestore());
    } catch (e) {
      throw Exception('Failed to update RFQ response: $e');
    }
  }

  @override
  Future<void> deleteRFQResponse(String id) async {
    try {
      await _rfqResponsesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete RFQ response: $e');
    }
  }

  @override
  Future<String> createRFQResponseItem(RFQResponseItem item) async {
    try {
      final docRef = await _rfqResponseItemsRef.add(item.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create RFQ response item: $e');
    }
  }

  @override
  Future<RFQResponseItem?> getRFQResponseItem(String id) async {
    try {
      final doc = await _rfqResponseItemsRef.doc(id).get();
      if (!doc.exists) return null;
      return RFQResponseItem.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get RFQ response item: $e');
    }
  }

  @override
  Future<List<RFQResponseItem>> getRFQResponseItems(String rfqResponseId) async {
    try {
      final snapshot = await _rfqResponseItemsRef
          .where('rfqResponseId', isEqualTo: rfqResponseId)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => RFQResponseItem.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get RFQ response items: $e');
    }
  }

  @override
  Future<void> updateRFQResponseItem(RFQResponseItem item) async {
    try {
      await _rfqResponseItemsRef.doc(item.id).update(item.toFirestore());
    } catch (e) {
      throw Exception('Failed to update RFQ response item: $e');
    }
  }

  @override
  Future<void> deleteRFQResponseItem(String id) async {
    try {
      await _rfqResponseItemsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete RFQ response item: $e');
    }
  }

  @override
  Future<void> awardRFQ(String rfqId, String winningSupplierId, String? notes) async {
    try {
      // Update the RFQ status to awarded
      final rfqDoc = await _rfqsRef.doc(rfqId).get();
      if (!rfqDoc.exists) {
        throw Exception('RFQ not found');
      }

      final rfqData = rfqDoc.data();
      if (rfqData == null) {
        throw Exception('RFQ data is null');
      }

      await _rfqsRef.doc(rfqId).update({
        'status': 'awarded',
        'updatedAt': fs.FieldValue.serverTimestamp(),
        // We could add winning supplier info here if needed
      });

      // Update all responses to reflect their status
      final responsesSnapshot = await _rfqResponsesRef.where('rfqId', isEqualTo: rfqId).get();
      final batch = _firestore.batch();

      for (final doc in responsesSnapshot.docs) {
        final updateData = {
          'status': doc.id == winningSupplierId ? 'accepted' : 'rejected',
          'updatedAt': fs.FieldValue.serverTimestamp(),
        };

        if (notes != null && doc.id == winningSupplierId) {
          // Add notes to the winning notes
          updateData['notes'] = fs.FieldValue.arrayUnion([notes]);
        }

        batch.update(doc.reference, updateData);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to award RFQ: $e');
    }
  }
}