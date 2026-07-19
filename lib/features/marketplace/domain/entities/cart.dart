import 'package:equatable/equatable.dart';

/// Represents a shopping cart
class Cart extends Equatable {
  final String id; // typically userId
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CartItem> items;
  final String? couponCode; // applied coupon code
  final bool isSavedForLater; // if true, this is a wishlist/saved items cart

  const Cart({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.couponCode,
    this.isSavedForLater = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        createdAt,
        updatedAt,
        items,
        couponCode,
        isSavedForLater,
      ];

  Cart copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CartItem>? items,
    String? couponCode,
    bool? isSavedForLater,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      isSavedForLater: isSavedForLater ?? this.isSavedForLater,
    );
  }

  /// Calculates the total number of items in the cart
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Checks if the cart is empty
  bool get isEmpty => items.isEmpty;

  /// Calculates the subtotal of all items (before discounts, tax, shipping)
  double get subtotalAmount =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Gets a cart item by productId and variantId
  CartItem? getItem(String productId, String? variantId) {
    return items.firstWhere(
      (item) => item.productId == productId && item.variantId == variantId,
      orElse: () => CartItem.empty(),
    );
  }

  /// Gets the quantity of a specific product/variant in the cart
  int getQuantity(String productId, String? variantId) {
    final item = getItem(productId, variantId);
    if (item == null) return 0;
    return item.isEmpty ? 0 : item.quantity;
  }
}

class CartItem extends Equatable {
  final String id;
  final String productId;
  final String? variantId;
  final int quantity;
  final double unitPrice; // price per unit in cents (snapshot at time of add to cart)
  final double totalPrice; // quantity * unitPrice in cents
  final String productTitle;
  final Map<String, String> variantAttributes; // snapshot of variant attributes

  const CartItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productTitle,
    required this.variantAttributes,
  });

  /// Creates an empty cart item (used as sentinel value)
  factory CartItem.empty() => const CartItem(
        id: '',
        productId: '',
        variantId: null,
        quantity: 0,
        unitPrice: 0,
        totalPrice: 0,
        productTitle: '',
        variantAttributes: {},
      );

  bool get isEmpty => id.isEmpty;

  @override
  List<Object?> get props => [
        id,
        productId,
        variantId,
        quantity,
        unitPrice,
        totalPrice,
        productTitle,
        variantAttributes,
      ];

  CartItem copyWith({
    String? id,
    String? productId,
    String? variantId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? productTitle,
    Map<String, String>? variantAttributes,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      productTitle: productTitle ?? this.productTitle,
      variantAttributes:
          variantAttributes ?? this.variantAttributes,
    );
  }
}