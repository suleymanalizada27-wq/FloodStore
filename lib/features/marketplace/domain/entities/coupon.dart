import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Coupon/Promo code
class Coupon extends Equatable {
  final String id;
  final String code;
  final String name;
  final String description;
  final CouponType type;
  final double value; // Percentage or fixed amount
  final double minOrderAmount;
  final double maxDiscountAmount;
  final List<String> applicableCategories;
  final List<String> applicableProducts;
  final List<String> excludedProducts;
  final List<String> eligibleUserIds; // Empty = all users
  final List<String> eligibleTiers; // Loyalty tiers
  final int usageLimit; // Total usage limit
  final int usageLimitPerUser;
  final int usedCount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final bool isStackable; // Can combine with other coupons
  final CouponSource source; // Where it came from
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderAmount = 0,
    this.maxDiscountAmount = double.infinity,
    this.applicableCategories = const [],
    this.applicableProducts = const [],
    this.excludedProducts = const [],
    this.eligibleUserIds = const [],
    this.eligibleTiers = const [],
    this.usageLimit = 0, // 0 = unlimited
    this.usageLimitPerUser = 1,
    this.usedCount = 0,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.isStackable = false,
    this.source = CouponSource.manual,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        type,
        value,
        minOrderAmount,
        maxDiscountAmount,
        applicableCategories,
        applicableProducts,
        excludedProducts,
        eligibleUserIds,
        eligibleTiers,
        usageLimit,
        usageLimitPerUser,
        usedCount,
        validFrom,
        validUntil,
        isActive,
        isStackable,
        source,
        metadata,
        createdAt,
        updatedAt,
      ];

  bool get isValid => isActive && DateTime.now().isAfter(validFrom) && DateTime.now().isBefore(validUntil);

  bool get hasUsageLimit => usageLimit > 0 && usedCount >= usageLimit;

  bool canApplyToUser(String userId, String userTier) {
    if (eligibleUserIds.isNotEmpty && !eligibleUserIds.contains(userId)) return false;
    if (eligibleTiers.isNotEmpty && !eligibleTiers.contains(userTier)) return false;
    return true;
  }

  bool canApplyToCart(List<String> productIds, List<String> categoryIds, double subtotal) {
    if (subtotal < minOrderAmount) return false;
    if (applicableProducts.isNotEmpty && !productIds.any((id) => applicableProducts.contains(id))) return false;
    if (applicableCategories.isNotEmpty && !categoryIds.any((id) => applicableCategories.contains(id))) return false;
    if (excludedProducts.any((id) => productIds.contains(id))) return false;
    return true;
  }

  double calculateDiscount(double subtotal) {
    double discount = 0;
    switch (type) {
      case CouponType.percentage:
        discount = subtotal * (value / 100);
        break;
      case CouponType.fixedAmount:
        discount = value;
        break;
      case CouponType.freeShipping:
        discount = 0; // Handled separately
        break;
      case CouponType.buyXGetY:
        // Complex logic handled elsewhere
        break;
      case CouponType.gift:
        discount = value;
        break;
    }
    return discount.clamp(0, maxDiscountAmount);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'type': type.name,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'applicableCategories': applicableCategories,
      'applicableProducts': applicableProducts,
      'excludedProducts': excludedProducts,
      'eligibleUserIds': eligibleUserIds,
      'eligibleTiers': eligibleTiers,
      'usageLimit': usageLimit,
      'usageLimitPerUser': usageLimitPerUser,
      'usedCount': usedCount,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'isActive': isActive,
      'isStackable': isStackable,
      'source': source.name,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Coupon fromFirestore(Map<String, dynamic> data, String id) {
    return Coupon(
      id: id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: CouponType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => CouponType.percentage,
      ),
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (data['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (data['maxDiscountAmount'] as num?)?.toDouble() ?? double.infinity,
      applicableCategories: List<String>.from(data['applicableCategories'] ?? []),
      applicableProducts: List<String>.from(data['applicableProducts'] ?? []),
      excludedProducts: List<String>.from(data['excludedProducts'] ?? []),
      eligibleUserIds: List<String>.from(data['eligibleUserIds'] ?? []),
      eligibleTiers: List<String>.from(data['eligibleTiers'] ?? []),
      usageLimit: data['usageLimit'] ?? 0,
      usageLimitPerUser: data['usageLimitPerUser'] ?? 1,
      usedCount: data['usedCount'] ?? 0,
      validFrom: DateTime.parse(data['validFrom'] ?? DateTime.now().toIso8601String()),
      validUntil: DateTime.parse(data['validUntil'] ?? DateTime.now().add(const Duration(days: 365)).toIso8601String()),
      isActive: data['isActive'] ?? true,
      isStackable: data['isStackable'] ?? false,
      source: CouponSource.values.firstWhere(
        (s) => s.name == data['source'],
        orElse: () => CouponSource.manual,
      ),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum CouponType {
  percentage, // % off
  fixedAmount, // Fixed amount off
  freeShipping, // Free shipping
  buyXGetY, // Buy X get Y free
  gift, // Gift with purchase
}

enum CouponSource {
  manual, // Created by admin
  loyalty, // Earned via loyalty program
  referral, // Referral reward
  birthday, // Birthday gift
  welcome, // Welcome bonus
  campaign, // Marketing campaign
  abandonedCart, // Cart recovery
  review, // Review reward
}

/// Product bundle deal
class Bundle extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<BundleItem> items;
  final double bundlePrice;
  final double originalPrice;
  final String? imageUrl;
  final bool isActive;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int maxQuantityPerUser;
  final int soldCount;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Bundle({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
    required this.bundlePrice,
    required this.originalPrice,
    this.imageUrl,
    this.isActive = true,
    this.validFrom,
    this.validUntil,
    this.maxQuantityPerUser = 1,
    this.soldCount = 0,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        items,
        bundlePrice,
        originalPrice,
        imageUrl,
        isActive,
        validFrom,
        validUntil,
        maxQuantityPerUser,
        soldCount,
        tags,
        createdAt,
        updatedAt,
      ];

  double get discountPercent => originalPrice > 0 ? ((originalPrice - bundlePrice) / originalPrice * 100) : 0;
  double get savings => originalPrice - bundlePrice;
  bool get isValid => isActive &&
      (validFrom == null || DateTime.now().isAfter(validFrom!)) &&
      (validUntil == null || DateTime.now().isBefore(validUntil!));

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'items': items.map((i) => i.toFirestore()).toList(),
      'bundlePrice': bundlePrice,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'maxQuantityPerUser': maxQuantityPerUser,
      'soldCount': soldCount,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Bundle fromFirestore(Map<String, dynamic> data, String id) {
    return Bundle(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      items: (data['items'] as List?)
              ?.map((i) => BundleItem.fromFirestore(i))
              .toList() ??
          [],
      bundlePrice: (data['bundlePrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      validFrom: data['validFrom'] != null ? DateTime.parse(data['validFrom']) : null,
      validUntil: data['validUntil'] != null ? DateTime.parse(data['validUntil']) : null,
      maxQuantityPerUser: data['maxQuantityPerUser'] ?? 1,
      soldCount: data['soldCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class BundleItem extends Equatable {
  final String productId;
  final String? variantId;
  final int quantity;
  final bool isRequired; // If false, user can choose from options

  const BundleItem({
    required this.productId,
    this.variantId,
    this.quantity = 1,
    this.isRequired = true,
  });

  @override
  List<Object?> get props => [productId, variantId, quantity, isRequired];

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'variantId': variantId,
      'quantity': quantity,
      'isRequired': isRequired,
    };
  }

  static BundleItem fromFirestore(Map<String, dynamic> data) {
    return BundleItem(
      productId: data['productId'] ?? '',
      variantId: data['variantId'],
      quantity: data['quantity'] ?? 1,
      isRequired: data['isRequired'] ?? true,
    );
  }
}