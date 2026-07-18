import 'package:equatable/equatable.dart';

/// Represents a product in the marketplace
class Product extends Equatable {
  final String id;
  final String sellerId;
  final String categoryId;
  final List<String> secondaryCategories;
  final ProductBase base;
  final ProductMetadata metadata;
  final ProductPricing pricing;
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
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
}

class AgeRange {
  final int min;
  final int max;

  const AgeRange({
    required this.min,
    required this.max,
  });

  AgeRange copyWith({
    int? min,
    int? max,
  }) {
    return AgeRange(
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }
}

enum Gender { male, female, unisex, kids }

class ProductPricing {
  final double basePrice; // in cents
  final String currency;
  final double? compareAtPrice; // in cents
  final String taxCode;
  final String shippingTier;

  const ProductPricing({
    required this.basePrice,
    required this.currency,
    this.compareAtPrice,
    required this.taxCode,
    required this.shippingTier,
  });

  ProductPricing copyWith({
    double? basePrice,
    String? currency,
    double? compareAtPrice,
    String? taxCode,
    String? shippingTier,
  }) {
    return ProductPricing(
      basePrice: basePrice ?? this.basePrice,
      currency: currency ?? this.currency,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      taxCode: taxCode ?? this.taxCode,
      shippingTier: shippingTier ?? this.shippingTier,
    );
  }
}

enum ProductStatus { draft, active, archived, discontinued }