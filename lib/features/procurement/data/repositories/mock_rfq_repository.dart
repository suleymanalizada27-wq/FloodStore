import 'package:floodstore/features/procurement/domain/entities/rfq.dart';
import 'package:floodstore/features/procurement/domain/repositories/rfq_repository.dart';

/// Mock implementation of RFQRepository using in-memory lists
/// TODO: replace with FirestoreRFQRepository once Firestore is set up
class MockRFQRepository implements RFQRepository {
  // In-memory storage
  final Map<String, RFQ> _rfqs = {};
  final Map<String, RFQItem> _rfqItems = {};
  final Map<String, RFQResponse> _rfqResponses = {};
  final Map<String, RFQResponseItem> _rfqResponseItems = {};

  // ID generators
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Future<String> createRFQ(RFQ rfq) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final id = _generateId();
    final newRFQ = rfq.copyWith(id: id);
    _rfqs[id] = newRFQ;
    return id;
  }

  @override
  Future<RFQ?> getRFQ(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _rfqs[id];
  }

  @override
  Future<List<RFQ>> getRFQsByBuyer(
    String buyerId, {
    int limit = 20,
    String? lastDocumentId,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _rfqs.values
        .where((rfq) => rfq.buyerId == buyerId)
        .toList();

    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((rfq) => rfq.status == status).toList();
    }

    // Sort by creation date descending (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply limit
    if (limit > 0 && filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }

    return Future.value(filtered);
  }

  @override
  Future<List<RFQ>> getRFQsByStatus(
    String status, {
    int limit = 20,
    String? lastDocumentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _rfqs.values
        .where((rfq) => rfq.status == status)
        .toList();

    // Sort by creation date descending
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply limit
    if (limit > 0 && filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }

    return Future.value(filtered);
  }

  @override
  Future<void> updateRFQ(RFQ rfq) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_rfqs.containsKey(rfq.id)) {
      throw Exception('RFQ not found');
    }
    _rfqs[rfq.id] = rfq;
  }

  @override
  Future<void> deleteRFQ(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_rfqs.containsKey(id)) {
      throw Exception('RFQ not found');
    }
    _rfqs.remove(id);
    // Optionally, we could also delete related items, responses, etc.
    // For simplicity, we'll leave them (they will be orphaned).
  }

  @override
  Future<String> createRFQItem(RFQItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = _generateId();
    final newItem = item.copyWith(id: id);
    _rfqItems[id] = newItem;
    return id;
  }

  @override
  Future<RFQItem?> getRFQItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _rfqItems[id];
  }

  @override
  Future<List<RFQItem>> getRFQItems(String rfqId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _rfqItems.values
        .where((item) => item.rfqId == rfqId)
        .toList();
  }

  @override
  Future<void> updateRFQItem(RFQItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_rfqItems.containsKey(item.id)) {
      throw Exception('RFQItem not found');
    }
    _rfqItems[item.id] = item;
  }

  @override
  Future<void> deleteRFQItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _rfqItems.remove(id);
  }

  @override
  Future<String> createRFQResponse(RFQResponse response) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = _generateId();
    final newResponse = response.copyWith(id: id);
    _rfqResponses[id] = newResponse;
    return id;
  }

  @override
  Future<RFQResponse?> getRFQResponse(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _rfqResponses[id];
  }

  @override
  Future<List<RFQResponse>> getRFQResponsesBySupplier(
    String supplierId, {
    int limit = 20,
    String? lastDocumentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _rfqResponses.values
        .where((resp) => resp.supplierId == supplierId)
        .toList();

    // Sort by creation date descending
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply limit
    if (limit > 0 && filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }

    return Future.value(filtered);
  }

  @override
  Future<List<RFQResponse>> getRFQResponses(String rfqId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _rfqResponses.values
        .where((resp) => resp.rfqId == rfqId)
        .toList();

    // Sort by creation date descending (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Future.value(filtered);
  }

  @override
  Future<void> updateRFQResponse(RFQResponse response) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_rfqResponses.containsKey(response.id)) {
      throw Exception('RFQResponse not found');
    }
    _rfqResponses[response.id] = response;
  }

  @override
  Future<void> deleteRFQResponse(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _rfqResponses.remove(id);
  }

  @override
  Future<String> createRFQResponseItem(RFQResponseItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = _generateId();
    final newItem = item.copyWith(id: id);
    _rfqResponseItems[id] = newItem;
    return id;
  }

  @override
  Future<RFQResponseItem?> getRFQResponseItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _rfqResponseItems[id];
  }

  @override
  Future<List<RFQResponseItem>> getRFQResponseItems(
      String rfqResponseId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _rfqResponseItems.values
        .where((item) => item.rfqResponseId == rfqResponseId)
        .toList();
  }

  @override
  Future<void> updateRFQResponseItem(RFQResponseItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_rfqResponseItems.containsKey(item.id)) {
      throw Exception('RFQResponseItem not found');
    }
    _rfqResponseItems[item.id] = item;
  }

  @override
  Future<void> deleteRFQResponseItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _rfqResponseItems.remove(id);
  }

  @override
  Future<void> awardRFQ(
      String rfqId, String winningSupplierId, String? notes) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Update the RFQ status to awarded
    final rfq = _rfqs[rfqId];
    if (rfq == null) {
      throw Exception('RFQ not found');
    }
    final updatedRFQ = rfq.copyWith(status: 'awarded');
    _rfqs[rfqId] = updatedRFQ;

    // Update all responses for this RFQ
    for (final response in _rfqResponses.values.where((r) => r.rfqId == rfqId)) {
      final isWinning = response.supplierId == winningSupplierId;
      final updatedResponse = response.copyWith(
        status: isWinning ? 'accepted' : 'rejected',
        // If we want to add notes to the winning response, we would need to modify the RFQResponse entity to have a notes field.
        // For now, we'll just update the status.
      );
      _rfqResponses[response.id] = updatedResponse;
    }
  }
}