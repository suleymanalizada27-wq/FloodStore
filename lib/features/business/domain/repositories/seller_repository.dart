import 'package:floodstore/features/business/domain/entities/business_account.dart';
import 'package:floodstore/features/marketplace/domain/entities/order.dart';
import 'package:floodstore/features/marketplace/domain/entities/product.dart';

abstract class SellerRepository {
  /// Gets the business account for the current user
  Future<BusinessAccount?> getBusinessAccount(String userId);

  /// Gets products belonging to the seller
  Future<List<Product>> getSellerProducts(String sellerId, {
    int limit = 20,
    String? lastDocumentId,
  });

  /// Gets orders for the seller
  Future<List<Order>> getSellerOrders(String sellerId, {
    int limit = 20,
    String? lastDocumentId,
  });

  /// Updates the business account
  Future<void> updateBusinessAccount(BusinessAccount account);
}