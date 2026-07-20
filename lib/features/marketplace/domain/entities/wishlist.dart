import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a user's wishlist (saved for later items)
class Wishlist extends Equatable {
  final String id; // typically userId
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WishlistItem> items;

  const Wishlist({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Wishlist.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Wishlist(
      id: documentId,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: List<WishlistItem>.from(
        (data['items'] as List<dynamic>?)
                ?.map((item) => WishlistItem.fromFirestore(item as Map<String, dynamic>))
                .toList() ??
            []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'items': items.map((item) => item.toFirestore()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        createdAt,
        updatedAt,
        items,
      ];

  Wishlist copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WishlistItem>? items,
  }) {
    return Wishlist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  /// Gets the number of items in the wishlist
  int get itemCount => items.length;

  /// Checks if the wishlist is empty
  bool get isEmpty => items.isEmpty;

  /// Checks if a product (with optional variant) is in the wishlist
  bool contains(String productId, String? variantId) {
    return items.any(
      (item) => item.productId == productId && item.variantId == variantId,
    );
  }

  /// Gets a wishlist item by productId and variantId
  WishlistItem? getItem(String productId, String? variantId) {
    try {
      return items.firstWhere(
        (item) => item.productId == productId && item.variantId == variantId,
      );
    } catch (_) {
      return null;
    }
  }
}

class WishlistItem extends Equatable {
  final String id;
  final String productId;
  final String? variantId;
  final DateTime addedAt;
  final String productTitle;
  final Map<String, String> variantAttributes; // snapshot of variant attributes

  const WishlistItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.addedAt,
    required this.productTitle,
    required this.variantAttributes,
  });

  factory WishlistItem.fromFirestore(Map<String, dynamic> data) {
    return WishlistItem(
      id: data['id'] ?? '',
      productId: data['productId'] ?? '',
      variantId: data['variantId'],
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      productTitle: data['productTitle'] ?? '',
      variantAttributes: Map<String, String>.from(data['variantAttributes'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'productId': productId,
      'variantId': variantId,
      'addedAt': Timestamp.fromDate(addedAt),
      'productTitle': productTitle,
      'variantAttributes': variantAttributes,
    };
  }

  /// Creates an empty wishlist item (used as sentinel value)
  factory WishlistItem.empty() => WishlistItem(
        id: '',
        productId: '',
        variantId: null,
        addedAt: DateTime(0),
        productTitle: '',
        variantAttributes: {},
      );

  bool get isEmpty => id.isEmpty;

  @override
  List<Object?> get props => [
        id,
        productId,
        variantId,
        addedAt,
        productTitle,
        variantAttributes,
      ];

  WishlistItem copyWith({
    String? id,
    String? productId,
    String? variantId,
    DateTime? addedAt,
    String? productTitle,
    Map<String, String>? variantAttributes,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      addedAt: addedAt ?? this.addedAt,
      productTitle: productTitle ?? this.productTitle,
      variantAttributes: variantAttributes ?? this.variantAttributes,
    );
  }
}