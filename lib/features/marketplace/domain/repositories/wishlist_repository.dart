import '../entities/wishlist.dart';

/// Abstract repository for wishlist-related operations
abstract class WishlistRepository {
  /// Gets the wishlist for a user
  Future<Wishlist?> getWishlist(String userId);

  /// Saves/updates the wishlist for a user
  Future<void> saveWishlist(String userId, Wishlist wishlist);

  /// Creates an empty wishlist for a user
  Future<void> createEmptyWishlist(String userId);

  /// Adds an item to the wishlist
  Future<void> addItem(
    String userId,
    String productId,
    String? variantId,
    String productTitle,
    Map<String, String> variantAttributes,
  );

  /// Removes an item from the wishlist
  Future<void> removeItem(
    String userId,
    String productId,
    String? variantId,
  );

  /// Clears all items from the wishlist
  Future<void> clearWishlist(String userId);

  /// Watches the wishlist for a user and returns a stream of updates
  Stream<Wishlist?> watchWishlist(String userId);
}