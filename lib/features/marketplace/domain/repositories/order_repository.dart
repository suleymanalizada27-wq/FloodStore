import '../entities/order.dart';
import '../entities/cart.dart';

/// Abstract repository for order-related operations
abstract class OrderRepository {
  /// Gets an order by its ID
  Future<Order?> getOrderById(String orderId);

  /// Gets orders for a user with optional filtering and pagination
  Future<List<Order>> getUserOrders(
    String userId, {
    int limit = 20,
    String? lastDocumentId,
    OrderStatus? statusFilter,
  });

  /// Gets orders for a seller (marketplace orders containing their products)
  Future<List<Order>> getSellerOrders(
    String sellerId, {
    int limit = 20,
    String? lastDocumentId,
    OrderStatus? statusFilter,
  });

  /// Creates a new order from a cart
  Future<String> createOrderFromCart(
    String userId,
    Cart cart, {
    String? couponCode,
    String? notes,
  });

  /// Updates an order's status
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? changedBy,
    String? reason,
    String? notes,
  });

  /// Updates an order's fulfillment status
  Future<void> updateOrderFulfillmentStatus(
    String orderId,
    FulfillmentStatus status, {
    String? changedBy,
    String? notes,
  });

  /// Updates an order's payment status
  Future<void> updateOrderPaymentStatus(
    String orderId,
    PaymentStatus status, {
    String? changedBy,
    String? notes,
  });

  /// Adds payment information to an order
  Future<void> addPaymentInfo(
    String orderId,
    PaymentInfo paymentInfo,
  );

  /// Adds tracking/shipping information to an order
  Future<void> addTrackingInfo(
    String orderId,
    ShippingInfo trackingInfo,
  );

  /// Adds a history entry to an order
  Future<void> addOrderHistoryEntry(
    String orderId,
    OrderHistoryEntry entry,
  );

  /// Cancels an order
  Future<void> cancelOrder(
    String orderId, {
    required String cancelledBy,
    required String reason,
  });

  /// Gets the cart for a user
  Future<Cart?> getUserCart(String userId);

  /// Saves/updates the cart for a user
  Future<void> saveUserCart(String userId, Cart cart);

  /// Clears the cart for a user
  Future<void> clearUserCart(String userId);

  /// Adds an item to the user's cart
  Future<void> addItemToCart(
    String userId,
    String productId,
    String? variantId,
    int quantity,
  );

  /// Updates the quantity of an item in the user's cart
  Future<void> updateCartItemQuantity(
    String userId,
    String productId,
    String? variantId,
    int quantity,
  );

  /// Removes an item from the user's cart
  Future<void> removeItemFromCart(
    String userId,
    String productId,
    String? variantId,
  );

  /// Saves cart for later (wishlist/saved items)
  Future<void> saveCartForLater(String userId, Cart cart);

  /// Gets saved items/wishlist for a user
  Future<List<CartItem>> getSavedItems(String userId);
}