import 'package:equatable/equatable.dart';

/// Represents a variant of a product (e.g., different size, color)
class ProductVariant extends Equatable {
  final String id;
  final String parentProductId;
  final String sku;
  final Map<String, String> attributes;
  final VariantPricing pricing;
  final VariantInventory inventory;
  final VariantMedia media;
  final DateTime updatedAt;

  const ProductVariant({
    required this.id,
    required this.parentProductId,
    required this.sku,
    required this.attributes,
    required this.pricing,
    required this.inventory,
    required this.media,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        parentProductId,
        sku,
        attributes,
        pricing,
        inventory,
        media,
        updatedAt,
      ];

  ProductVariant copyWith({
    String? id,
    String? parentProductId,
    String? sku,
    Map<String, String>? attributes,
    VariantPricing? pricing,
    VariantInventory? inventory,
    VariantMedia? media,
    DateTime? updatedAt,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      parentProductId: parentProductId ?? this.parentProductId,
      sku: sku ?? this.sku,
      attributes: attributes ?? this.attributes,
      pricing: pricing ?? this.pricing,
      inventory: inventory ?? this.inventory,
      media: media ?? this.media,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VariantPricing {
  final double price; // in cents
  final double? compareAtPrice; // in cents

  const VariantPricing({
    required this.price,
    this.compareAtPrice,
  });

  VariantPricing copyWith({
    double? price,
    double? compareAtPrice,
  }) {
    return VariantPricing(
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
    );
  }
}

class VariantInventory {
  final int total;
  final int reserved;
  final Map<String, int> warehouses; // warehouseId -> quantity

  const VariantInventory({
    required this.total,
    required this.reserved,
    required this.warehouses,
  });

  int get available => total - reserved;

  VariantInventory copyWith({
    int? total,
    int? reserved,
    Map<String, int>? warehouses,
  }) {
    return VariantInventory(
      total: total ?? this.total,
      reserved: reserved ?? this.reserved,
      warehouses: warehouses ?? this.warehouses,
    );
  }
}

class VariantMedia {
  final String primary; // URL or path to primary image
  final List<String> gallery; // URLs or paths to gallery images
  final List<String> videos; // URLs or paths to videos
  final String? model3d; // URL or path to 3D model

  const VariantMedia({
    required this.primary,
    required this.gallery,
    required this.videos,
    this.model3d,
  });

  VariantMedia copyWith({
    String? primary,
    List<String>? gallery,
    List<String>? videos,
    String? model3d,
  }) {
    return VariantMedia(
      primary: primary ?? this.primary,
      gallery: gallery ?? this.gallery,
      videos: videos ?? this.videos,
      model3d: model3d ?? this.model3d,
    );
  }
}