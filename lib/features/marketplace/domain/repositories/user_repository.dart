import '../entities/cart.dart';
import '../entities/order.dart';

/// Abstract repository for user-related operations in marketplace context
abstract class UserRepository {
  /// Gets user profile information
  Future<Map<String, dynamic>?> getUserProfile(String userId);

  /// Updates user profile information
  Future<void> updateUserProfile(String userId, Map<String, dynamic> profileData);

  /// Gets user preferences
  Future<Map<String, dynamic>?> getUserPreferences(String userId);

  /// Updates user preferences
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences);

  /// Gets user wallet/balance information
  Future<Map<String, dynamic>?> getUserWallet(String userId);

  /// Adds funds to user wallet
  Future<void> addFundsToWallet(String userId, double amount);

  /// Deducts funds from user wallet
  Future<void> deductFromWallet(String userId, double amount);

  /// Gets user's order history
  Future<List<Order>> getUserOrderHistory(String userId, {
    int limit = 20,
    String? lastDocumentId,
  });

  /// Gets user's wishlist/saved items
  Future<List<Map<String, dynamic>>> getUserWishlist(String userId, {
    int limit = 20,
  });

  /// Adds product to user's wishlist
  Future<void> addToWishlist(String userId, String productId);

  /// Removes product from user's wishlist
  Future<void> removeFromWishlist(String userId, String productId);

  /// Gets user's recently viewed products
  Future<List<String>> getRecentlyViewed(String userId, {
    int limit = 10,
  });

  /// Adds product to recently viewed
  Future<void> addToRecentlyViewed(String userId, String productId);

  /// Clears recently viewed history
  Future<void> clearRecentlyViewed(String userId);

  /// Gets user's shipping addresses
  Future<List<Map<String, dynamic>>> getUserAddresses(String userId);

  /// Adds a shipping address for user
  Future<String> addUserAddress(String userId, Map<String, dynamic> addressData);

  /// Updates a user's address
  Future<void> updateUserAddress(String userId, String addressId, Map<String, dynamic> addressData);

  /// Deletes a user's address
  Future<void> deleteUserAddress(String userId, String addressId);

  /// Sets default shipping address for user
  Future<void> setDefaultAddress(String userId, String addressId);
}