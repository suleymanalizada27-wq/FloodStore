import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';

enum ProductSortField {
  createdAt,
  updatedAt,
  basePrice,
  rating,
  popularity,
}

extension on ProductSortField {
  String get firestoreField {
    switch (this) {
      case ProductSortField.createdAt:
        return 'createdAt';
      case ProductSortField.updatedAt:
        return 'updatedAt';
      case ProductSortField.basePrice:
        return 'pricing.basePrice';
      case ProductSortField.rating:
        return 'rating';
      case ProductSortField.popularity:
        return 'popularity';
    }
  }
}

class FirestoreProductDataSource {
  final FirebaseFirestore _firestore;

  FirestoreProductDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _productsCollection =>
      _firestore.collection('products');

  // ignore: unused_element
  CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');

  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (!doc.exists) return null;
      return _productFromSnapshot(doc);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  Future<ProductVariant?> getProductVariantById(String variantId) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup('variants')
          .where('id', isEqualTo: variantId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      final doc = querySnapshot.docs.first;
      return _variantFromSnapshot(doc.data(), doc.id);
    } catch (e) {
      throw Exception('Failed to get product variant: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(
    String categoryId, {
    int limit = 20,
    String? lastDocumentId,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _productsCollection.limit(limit);

      if (categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      if (activeOnly) {
        query = query.where('status', isEqualTo: ProductStatus.active.name);
      }

      query = query.orderBy('createdAt', descending: true);

      if (lastDocumentId != null) {
        final lastDoc = await _productsCollection.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => _productFromSnapshot(doc))
          .whereType<Product>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  Future<List<Product>> getProductsBySeller(
    String sellerId, {
    int limit = 20,
    String? lastDocumentId,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _productsCollection
          .where('sellerId', isEqualTo: sellerId)
          .limit(limit);

      if (activeOnly) {
        query = query.where('status', isEqualTo: ProductStatus.active.name);
      }

      query = query.orderBy('createdAt', descending: true);

      if (lastDocumentId != null) {
        final lastDoc = await _productsCollection.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => _productFromSnapshot(doc))
          .whereType<Product>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get products by seller: $e');
    }
  }

  /// Searches products by query string and optional filters.
  ///
  /// Firestore does not support native full-text search. As a fallback
  /// suitable for small catalogs, this performs a prefix search on the
  /// lowercase title field, in addition to category and price filtering.
  Future<List<Product>> searchProducts(
    String query, {
    int limit = 20,
    String? lastDocumentId,
    List<String>? categoryIds,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool sortDesc = true,
  }) async {
    try {
      Query queryRef =
          _productsCollection.where('status', isEqualTo: ProductStatus.active.name);

      if (categoryIds != null && categoryIds.isNotEmpty) {
        queryRef = queryRef.where('categoryId', whereIn: categoryIds);
      }

      if (minPrice != null) {
        queryRef =
            queryRef.where('pricing.basePrice', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        queryRef =
            queryRef.where('pricing.basePrice', isLessThanOrEqualTo: maxPrice);
      }

      final normalizedQuery = query.trim().toLowerCase();
      if (normalizedQuery.isNotEmpty) {
        queryRef = queryRef
            .where('searchTitle', isGreaterThanOrEqualTo: normalizedQuery)
            .where('searchTitle', isLessThanOrEqualTo: '$normalizedQuery\uf8ff');
      }

      final sortField = sortBy != null
          ? ProductSortField.values
              .firstWhere((e) => e.name == sortBy,
                  orElse: () => ProductSortField.createdAt)
          : ProductSortField.createdAt;
      queryRef = queryRef.orderBy(
        sortField.firestoreField,
        descending: sortDesc,
      );

      queryRef = queryRef.limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _productsCollection.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          queryRef = queryRef.startAfterDocument(lastDoc);
        }
      }

      final querySnapshot = await queryRef.get();
      final products = querySnapshot.docs
          .map((doc) => _productFromSnapshot(doc))
          .whereType<Product>()
          .toList();

      if (normalizedQuery.isNotEmpty) {
        final words = normalizedQuery.split(RegExp(r'\s+'));
        final filtered = products.where((p) {
          final haystacks = [
            p.base.title.toLowerCase(),
            p.base.description.toLowerCase(),
            p.base.brand.toLowerCase(),
            ...p.metadata.tags.map((t) => t.toLowerCase()),
          ];
          return words.every((word) =>
              haystacks.any((h) => h.contains(word)));
        }).toList();
        // Return a possibly smaller list after filtering
        return filtered.length <= limit ? filtered : filtered.sublist(0, limit);
      }
      return products;
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  Product _productFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      secondaryCategories:
          List<String>.from(data['secondaryCategories'] ?? []),
      base: ProductBase(
        title: data['base']['title'] ?? '',
        description: data['base']['description'] ?? '',
        brand: data['base']['brand'] ?? '',
        sku: data['base']['sku'] ?? '',
        weight: (data['base']['weight'] as num?)?.toDouble() ?? 0.0,
        dimensions: ProductDimensions(
          length:
              (data['base']['dimensions']['length'] as num?)?.toDouble() ??
                  0.0,
          width:
              (data['base']['dimensions']['width'] as num?)?.toDouble() ?? 0.0,
          height:
              (data['base']['dimensions']['height'] as num?)?.toDouble() ??
                  0.0,
        ),
        materials: List<String>.from(data['base']['materials'] ?? []),
        careInstructions: data['base']['careInstructions'] ?? '',
        isDigital: data['base']['isDigital'] ?? false,
      ),
      metadata: ProductMetadata(
        tags: List<String>.from(data['metadata']['tags'] ?? []),
        ageRange: data['metadata']['ageRange'] != null
            ? AgeRange(
                min: data['metadata']['ageRange']['min'] ?? 0,
                max: data['metadata']['ageRange']['max'] ?? 0,
              )
            : null,
        gender: data['metadata']['gender'] != null
            ? Gender.values.firstWhere(
                (e) => e.name == data['metadata']['gender'],
                orElse: () => Gender.unisex,
              )
            : null,
        season: List<String>.from(data['metadata']['season'] ?? []),
        occasion: List<String>.from(data['metadata']['occasion'] ?? []),
        style: List<String>.from(data['metadata']['style'] ?? []),
        color: List<String>.from(data['metadata']['color'] ?? []),
        pattern: List<String>.from(data['metadata']['pattern'] ?? []),
      ),
      pricing: ProductPricing(
        basePrice: (data['pricing']['basePrice'] as num?)?.toDouble() ?? 0.0,
        currency: data['pricing']['currency'] ?? 'USD',
        compareAtPrice:
            (data['pricing']['compareAtPrice'] as num?)?.toDouble(),
        taxCode: data['pricing']['taxCode'] ?? '',
        shippingTier: data['pricing']['shippingTier'] ?? '',
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ProductStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProductStatus.draft,
      ),
    );
  }

  ProductVariant _variantFromSnapshot(Map<String, dynamic> data, String id) {
    return ProductVariant(
      id: id,
      parentProductId: data['parentProductId'] ?? '',
      sku: data['sku'] ?? '',
      attributes: Map<String, String>.from(data['attributes'] ?? {}),
      pricing: VariantPricing(
        price: (data['pricing']['price'] as num?)?.toDouble() ?? 0.0,
        compareAtPrice:
            (data['pricing']['compareAtPrice'] as num?)?.toDouble(),
      ),
      inventory: VariantInventory(
        total: (data['inventory']['total'] as int?) ?? 0,
        reserved: (data['inventory']['reserved'] as int?) ?? 0,
        warehouses:
            Map<String, int>.from(data['inventory']['warehouses'] ?? {}),
      ),
      media: VariantMedia(
        primary: data['media']['primary'] ?? '',
        gallery: List<String>.from(data['media']['gallery'] ?? []),
        videos: List<String>.from(data['media']['videos'] ?? []),
        model3d: data['media']['model3d'],
      ),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
