import '../entities/business_account.dart';

abstract class BusinessAccountRepository {
  /// Creates a new business account application
  Future<String> createBusinessAccount(BusinessAccount account);

  /// Gets a business account by ID
  Future<BusinessAccount?> getBusinessAccount(String id);

  /// Gets a business account by user ID (owner)
  Future<BusinessAccount?> getBusinessAccountByUserId(String userId);

  /// Updates a business account
  Future<void> updateBusinessAccount(BusinessAccount account);

  /// Updates business account status (by admin)
  Future<void> updateBusinessAccountStatus(
    String id,
    BusinessAccountStatus status, {
    String? rejectionReason,
    String? approvedBy,
  });

  /// Gets all business accounts with pagination (admin)
  Future<List<BusinessAccount>> getAllBusinessAccounts({
    int limit = 20,
    String? lastDocumentId,
    BusinessAccountStatus? statusFilter,
  });

  /// Gets pending business accounts count (admin dashboard)
  Future<int> getPendingBusinessAccountsCount();

  /// Uploads business document (logo, tax certificate, trade registry)
  Future<String> uploadBusinessDocument({
    required String businessAccountId,
    required String documentType, // logo, tax_certificate, trade_registry
    required String filePath,
  });

  /// Deletes a business document
  Future<void> deleteBusinessDocument({
    required String businessAccountId,
    required String documentType,
  });
}