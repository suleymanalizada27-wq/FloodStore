import '../entities/cart.dart';

/// Abstract repository for cart-related operations
abstract class CartRepository {
  /// Gets the cart for a user
  Future<Cart?> getCart(String userId);

  /// Saves/updates the cart for a user
  Future<void> saveCart(String userId, Cart cart);

  /// Creates an empty cart for a user
  Future<void> createEmptyCart(String userId);

  /// Adds an item to the cart
  Future<void> addItem(
    String userId,
    String productId,
    String? variantId,
    int quantity,
    double unitPrice,
    String productTitle,
    Map<String, String> variantAttributes,
  );

  /// Updates the quantity of an item in the cart
  Future<void> updateItemQuantity(
    String userId,
    String productId,
    String? variantId,
    int quantity,
  );

  /// Removes an item from the cart
  Future<void> removeItem(
    String userId,
    String productId,
    String? variantId,
  );

  /// Clears all items from the cart
  Future<void> clearCart(String userId);

  /// Moves cart items to saved for later (wishlist)
  Future<void> saveForLater(String userId, List<String> itemIds);

  /// Moves saved items back to cart
  Future<void> moveToCart(String userId, List<String> itemIds);

  /// Applies a coupon code to the cart
  Future<void> applyCoupon(String userId, String couponCode);

  /// Removes coupon code from the cart
  Future<void> removeCoupon(String userId);

  /// Calculates cart totals (subtotal, tax, shipping, etc.)
  Future<Map<String, double>> calculateCartTotals(String userId);
}