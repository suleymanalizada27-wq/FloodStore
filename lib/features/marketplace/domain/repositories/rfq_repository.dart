import '../entities/rfq.dart';

/// Abstract repository for RFQ-related operations
abstract class RFQRepository {
  /// Creates a new RFQ
  Future<String> createRFQ(RFQ rfq);

  /// Gets an RFQ by ID
  Future<RFQ?> getRFQ(String id);

  /// Gets RFQs by buyer (the party requesting quotes)
  Future<List<RFQ>> getRFQsByBuyer(String buyerId, {
    int limit = 20,
    String? lastDocumentId,
    String? status,
  });

  /// Gets RFQs by status
  Future<List<RFQ>> getRFQsByStatus(String status, {
    int limit = 20,
    String? lastDocumentId,
  });

  /// Updates an RFQ
  Future<void> updateRFQ(RFQ rfq);

  /// Deletes an RFQ (soft delete by setting status to cancelled)
  Future<void> deleteRFQ(String id);

  /// Creates a new RFQ item (line item)
  Future<String> createRFQItem(RFQItem item);

  /// Gets an RFQ item by ID
  Future<RFQItem?> getRFQItem(String id);

  /// Gets all items for an RFQ
  Future<List<RFQItem>> getRFQItems(String rfqId);

  /// Updates an RFQ item
  Future<void> updateRFQItem(RFQItem item);

  /// Deletes an RFQ item
  Future<void> deleteRFQItem(String id);

  /// Creates a new RFQ response (supplier's quote)
  Future<String> createRFQResponse(RFQResponse response);

  /// Gets an RFQ response by ID
  Future<RFQResponse?> getRFQResponse(String id);

  /// Gets all responses for an RFQ
  Future<List<RFQResponse>> getRFQResponses(String rfqId);

  /// Gets RFQ responses by supplier
  Future<List<RFQResponse>> getRFQResponsesBySupplier(String supplierId, {
    int limit = 20,
    String? lastDocumentId,
  });

  /// Updates an RFQ response
  Future<void> updateRFQResponse(RFQResponse response);

  /// Deletes an RFQ response
  Future<void> deleteRFQResponse(String id);

  /// Creates a new RFQ response item (line item in supplier's quote)
  Future<String> createRFQResponseItem(RFQResponseItem item);

  /// Gets an RFQ response item by ID
  Future<RFQResponseItem?> getRFQResponseItem(String id);

  /// Gets all response items for an RFQ response
  Future<List<RFQResponseItem>> getRFQResponseItems(String rfqResponseId);

  /// Updates an RFQ response item
  Future<void> updateRFQResponseItem(RFQResponseItem item);

  /// Deletes an RFQ response item
  Future<void> deleteRFQResponseItem(String id);

  /// Awards an RFQ to a supplier (selects winning bid)
  Future<void> awardRFQ(String rfqId, String winningSupplierId, String? notes);
}