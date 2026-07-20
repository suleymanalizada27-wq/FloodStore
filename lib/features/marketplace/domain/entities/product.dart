import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a product in the marketplace
class Product extends Equatable {
  final String id;
  final String sellerId;
  final String categoryId;
  final List<String> secondaryCategories;
  final ProductBase base;
  final ProductMetadata metadata;
  final ProductPricing pricing;
  final List<String> images; // Product image URLs
  final ProductInventory inventory;
  final double rating; // Average rating 0-5
  final int reviewCount; // Number of reviews
  final int popularity; // Popularity score
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductStatus status;

  const Product({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.secondaryCategories,
    required this.base,
    required this.metadata,
    required this.pricing,
    this.images = const [],
    this.inventory = const ProductInventory(),
    this.rating = 0.0,
    this.reviewCount = 0,
    this.popularity = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        sellerId,
        categoryId,
        secondaryCategories,
        base,
        metadata,
        pricing,
        images,
        inventory,
        rating,
        reviewCount,
        popularity,
        createdAt,
        updatedAt,
        status,
      ];

  Product copyWith({
    String? id,
    String? sellerId,
    String? categoryId,
    List<String>? secondaryCategories,
    ProductBase? base,
    ProductMetadata? metadata,
    ProductPricing? pricing,
    List<String>? images,
    ProductInventory? inventory,
    double? rating,
    int? reviewCount,
    int? popularity,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductStatus? status,
  }) {
    return Product(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      categoryId: categoryId ?? this.categoryId,
      secondaryCategories: secondaryCategories ?? this.secondaryCategories,
      base: base ?? this.base,
      metadata: metadata ?? this.metadata,
      pricing: pricing ?? this.pricing,
      images: images ?? this.images,
      inventory: inventory ?? this.inventory,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      popularity: popularity ?? this.popularity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'categoryId': categoryId,
      'secondaryCategories': secondaryCategories,
      'base': base.toFirestore(),
      'metadata': metadata.toFirestore(),
      'pricing': pricing.toFirestore(),
      'images': images,
      'inventory': inventory.toFirestore(),
      'rating': rating,
      'reviewCount': reviewCount,
      'popularity': popularity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.name,
    };
  }

  static Product fromFirestore(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      sellerId: data['sellerId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      secondaryCategories: List<String>.from(data['secondaryCategories'] ?? []),
      base: ProductBase.fromFirestore(data['base'] ?? {}),
      metadata: ProductMetadata.fromFirestore(data['metadata'] ?? {}),
      pricing: ProductPricing.fromFirestore(data['pricing'] ?? {}),
      images: List<String>.from(data['images'] ?? []),
      inventory: ProductInventory.fromFirestore(data['inventory']),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      popularity: data['popularity'] ?? 0,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
      status: ProductStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ProductStatus.draft,
      ),
    );
  }
}

/// Core product data that rarely changes
class ProductBase {
  final String title;
  final String description;
  final String brand;
  final String sku;
  final double weight; // in grams
  final ProductDimensions dimensions;
  final List<String> materials;
  final String careInstructions;
  final bool isDigital;

  const ProductBase({
    required this.title,
    required this.description,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.dimensions,
    required this.materials,
    required this.careInstructions,
    required this.isDigital,
  });

  ProductBase copyWith({
    String? title,
    String? description,
    String? brand,
    String? sku,
    double? weight,
    ProductDimensions? dimensions,
    List<String>? materials,
    String? careInstructions,
    bool? isDigital,
  }) {
    return ProductBase(
      title: title ?? this.title,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      materials: materials ?? this.materials,
      careInstructions: careInstructions ?? this.careInstructions,
      isDigital: isDigital ?? this.isDigital,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions.toFirestore(),
      'materials': materials,
      'careInstructions': careInstructions,
      'isDigital': isDigital,
    };
  }

  static ProductBase fromFirestore(Map<String, dynamic> data) {
    return ProductBase(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      brand: data['brand'] ?? '',
      sku: data['sku'] ?? '',
      weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
      dimensions: ProductDimensions.fromFirestore(data['dimensions'] ?? {}),
      materials: List<String>.from(data['materials'] ?? []),
      careInstructions: data['careInstructions'] ?? '',
      isDigital: data['isDigital'] ?? false,
    );
  }
}

class ProductDimensions {
  final double length; // in cm
  final double width;  // in cm
  final double height; // in cm

  const ProductDimensions({
    required this.length,
    required this.width,
    required this.height,
  });

  ProductDimensions copyWith({
    double? length,
    double? width,
    double? height,
  }) {
    return ProductDimensions(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'length': length,
      'width': width,
      'height': height,
    };
  }

  static ProductDimensions fromFirestore(Map<String, dynamic> data) {
    return ProductDimensions(
      length: (data['length'] as num?)?.toDouble() ?? 0.0,
      width: (data['width'] as num?)?.toDouble() ?? 0.0,
      height: (data['height'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProductMetadata {
  final List<String> tags;
  final AgeRange? ageRange;
  final Gender? gender;
  final List<String> season;
  final List<String> occasion;
  final List<String> style;
  final List<String> color;
  final List<String> pattern;

  const ProductMetadata({
    required this.tags,
    this.ageRange,
    this.gender,
    required this.season,
    required this.occasion,
    required this.style,
    required this.color,
    required this.pattern,
  });

  ProductMetadata copyWith({
    List<String>? tags,
    AgeRange? ageRange,
    Gender? gender,
    List<String>? season,
    List<String>? occasion,
    List<String>? style,
    List<String>? color,
    List<String>? pattern,
  }) {
    return ProductMetadata(
      tags: tags ?? this.tags,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      season: season ?? this.season,
      occasion: occasion ?? this.occasion,
      style: style ?? this.style,
      color: color ?? this.color,
      pattern: pattern ?? this.pattern,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tags': tags,
      'ageRange': ageRange?.toFirestore(),
      'gender': gender?.name,
      'season': season,
      'occasion': occasion,
      'style': style,
      'color': color,
      'pattern': pattern,
    };
  }

  static ProductMetadata fromFirestore(Map<String, dynamic> data) {
    return ProductMetadata(
      tags: List<String>.from(data['tags'] ?? []),
      ageRange: data['ageRange'] != null ? AgeRange.fromFirestore(data['ageRange']) : null,
      gender: data['gender'] != null ? Gender.values.firstWhere((g) => g.name == data['gender'], orElse: () => Gender.unisex) : null,
      season: List<String>.from(data['season'] ?? []),
      occasion: List<String>.from(data['occasion'] ?? []),
      style: List<String>.from(data['style'] ?? []),
      color: List<String>.from(data['color'] ?? []),
      pattern: List<String>.from(data['pattern'] ?? []),
    );
  }
}

class AgeRange {
  final int min;
  final int max;

  const AgeRange({required this.min, required this.max});

  AgeRange copyWith({int? min, int? max}) {
    return AgeRange(min: min ?? this.min, max: max ?? this.max);
  }

  Map<String, dynamic> toFirestore() => {'min': min, 'max': max};

  static AgeRange fromFirestore(Map<String, dynamic> data) => AgeRange(min: data['min'] ?? 0, max: data['max'] ?? 100);
}

enum Gender { male, female, unisex, kids }

class ProductPricing {
  final double basePrice; // in cents
  final String currency;
  final double? compareAtPrice; // in cents
  final String taxCode;
  final String shippingTier;
  final bool freeShipping;
  final double shippingCost; // in cents

  const ProductPricing({
    required this.basePrice,
    required this.currency,
    this.compareAtPrice,
    required this.taxCode,
    required this.shippingTier,
    this.freeShipping = false,
    this.shippingCost = 0,
  });

  ProductPricing copyWith({
    double? basePrice,
    String? currency,
    double? compareAtPrice,
    String? taxCode,
    String? shippingTier,
    bool? freeShipping,
    double? shippingCost,
  }) {
    return ProductPricing(
      basePrice: basePrice ?? this.basePrice,
      currency: currency ?? this.currency,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      taxCode: taxCode ?? this.taxCode,
      shippingTier: shippingTier ?? this.shippingTier,
      freeShipping: freeShipping ?? this.freeShipping,
      shippingCost: shippingCost ?? this.shippingCost,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'basePrice': basePrice,
      'currency': currency,
      'compareAtPrice': compareAtPrice,
      'taxCode': taxCode,
      'shippingTier': shippingTier,
      'freeShipping': freeShipping,
      'shippingCost': shippingCost,
    };
  }

  static ProductPricing fromFirestore(Map<String, dynamic> data) {
    return ProductPricing(
      basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'USD',
      compareAtPrice: (data['compareAtPrice'] as num?)?.toDouble(),
      taxCode: data['taxCode'] ?? 'standard',
      shippingTier: data['shippingTier'] ?? 'standard',
      freeShipping: data['freeShipping'] ?? false,
      shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

enum ProductStatus { draft, active, archived, discontinued }

class ProductInventory extends Equatable {
  final int totalQuantity;
  final int reservedQuantity;
  final Map<String, int> warehouseQuantities; // warehouseId -> quantity
  final int lowStockThreshold;
  final bool trackQuantity;
  final bool allowBackorder;
  final int maxBackorderQuantity;

  const ProductInventory({
    this.totalQuantity = 0,
    this.reservedQuantity = 0,
    this.warehouseQuantities = const {},
    this.lowStockThreshold = 10,
    this.trackQuantity = true,
    this.allowBackorder = false,
    this.maxBackorderQuantity = 0,
  });

  @override
  List<Object?> get props => [
        totalQuantity,
        reservedQuantity,
        warehouseQuantities,
        lowStockThreshold,
        trackQuantity,
        allowBackorder,
        maxBackorderQuantity,
      ];

  int get availableQuantity => totalQuantity - reservedQuantity;
  bool get isLowStock => trackQuantity && availableQuantity <= lowStockThreshold && availableQuantity > 0;
  bool get isOutOfStock => trackQuantity && availableQuantity <= 0 && !allowBackorder;

  ProductInventory copyWith({
    int? totalQuantity,
    int? reservedQuantity,
    Map<String, int>? warehouseQuantities,
    int? lowStockThreshold,
    bool? trackQuantity,
    bool? allowBackorder,
    int? maxBackorderQuantity,
  }) {
    return ProductInventory(
      totalQuantity: totalQuantity ?? this.totalQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      warehouseQuantities: warehouseQuantities ?? this.warehouseQuantities,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      trackQuantity: trackQuantity ?? this.trackQuantity,
      allowBackorder: allowBackorder ?? this.allowBackorder,
      maxBackorderQuantity: maxBackorderQuantity ?? this.maxBackorderQuantity,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalQuantity': totalQuantity,
      'reservedQuantity': reservedQuantity,
      'warehouseQuantities': warehouseQuantities,
      'lowStockThreshold': lowStockThreshold,
      'trackQuantity': trackQuantity,
      'allowBackorder': allowBackorder,
      'maxBackorderQuantity': maxBackorderQuantity,
    };
  }

  static ProductInventory fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const ProductInventory();
    return ProductInventory(
      totalQuantity: data['totalQuantity'] ?? 0,
      reservedQuantity: data['reservedQuantity'] ?? 0,
      warehouseQuantities: Map<String, int>.from(data['warehouseQuantities'] ?? {}),
      lowStockThreshold: data['lowStockThreshold'] ?? 10,
      trackQuantity: data['trackQuantity'] ?? true,
      allowBackorder: data['allowBackorder'] ?? false,
      maxBackorderQuantity: data['maxBackorderQuantity'] ?? 0,
    );
  }
}

enum ProductSortField {
  relevance(label: 'İlgililik', icon: Icons.sort),
  priceLowHigh(label: 'Fiyat: Düşükten Yükseğe', icon: Icons.arrow_upward),
  priceHighLow(label: 'Fiyat: Yüksekten Düşüğe', icon: Icons.arrow_downward),
  newest(label: 'En Yeni', icon: Icons.new_releases),
  rating(label: 'En Yüksek Puanlı', icon: Icons.star),
  popularity(label: 'En Popüler', icon: Icons.trending_up);

  const ProductSortField({required this.label, required this.icon});
  final String label;
  final IconData icon;

  String get firestoreField {
    switch (this) {
      case ProductSortField.relevance:
        return 'createdAt';
      case ProductSortField.priceLowHigh:
        return 'pricing.basePrice';
      case ProductSortField.priceHighLow:
        return 'pricing.basePrice';
      case ProductSortField.newest:
        return 'createdAt';
      case ProductSortField.rating:
        return 'rating';
      case ProductSortField.popularity:
        return 'popularity';
    }
  }
}