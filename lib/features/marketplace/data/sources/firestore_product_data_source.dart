import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/category.dart';

/// Firestore data source for product-related operations
class FirestoreProductDataSource {
  final FirebaseFirestore _firestore;

  FirestoreProductDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Reference to the products collection
  CollectionReference get _productsCollection =>
      _firestore.collection('products');

  // Reference to the categories collection
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
      // This is a simplified implementation - in production, consider
      // a separate variants collection or denormalization for performance
      final querySnapshot = await _productsCollection
          .where('variants.$variantId', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final productDoc = querySnapshot.docs.first;
      final productData = productDoc.data() as Map<String, dynamic>;
      final variantsData = (productData['variants'] as Map<String, dynamic>?)?[variantId];

      if (variantsData == null) return null;

      return _variantFromSnapshot(variantsData, productDoc.id);
    } catch (e) {
      throw Exception('Failed to get product variant: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId, {
    int limit = 20,
    String? lastDocumentId,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _productsCollection
          .where('categoryId', isEqualTo: categoryId)
          .limit(limit);

      if (activeOnly) {
        query = query.where('status', isEqualTo: ProductStatus: ProductStatus.active.name);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _productsCollection.doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDoc);
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

  Future<List<Product>> getProductsBySeller(String sellerId, {
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

      if (lastDocumentId != null) {
        final lastDoc = await _productsCollection.doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDoc);
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

  Future<List<Product>> searchProducts(String query, {
    int limit = 20,
    String? lastDocumentId,
    List<String>? categoryIds,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool sortDesc = true,
  }) async {
    try {
      // Note: This is a basic implementation - for production search,
      // consider integrating with Algolia, Elasticsearch, or Firebase's
      // native search capabilities when available
      Query queryRef = _productsCollection
          .where('status', isEqualTo: ProductStatus.active.name);

      if (categoryIds != null && categoryIds.isNotEmpty) {
        queryRef = queryRef.where('categoryId', whereIn: categoryIds);
      }

      // TODO: Add price range filtering
      // TODO: Add text search (requires third-party search solution)
      // TODO: Add sorting based on sortBy parameter

      queryRef = queryRef.limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _productsCollection.doc(lastDocumentId).get();
        queryRef = queryRef.startAfterDocument(lastDoc);
      }

      final querySnapshot = await queryRef.get();
      return querySnapshot.docs
          .map((doc) => _productFromSnapshot(doc))
          .whereType<Product>()
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Helper methods to convert Firestore documents to domain entities
  Product _productFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      secondaryCategories: List<String>.from(data['secondaryCategories'] ?? []),
      base: ProductBase(
        title: data['base']['title'] ?? '',
        description: data['base']['description'] ?? '',
        brand: data['base']['brand'] ?? '',
        sku: data['base']['sku'] ?? '',
        weight: (data['base']['weight'] as num?)?.toDouble() ?? 0.0,
        dimensions: ProductDimensions(
          length: (data['base']['dimensions']['length'] as num?)?.toDouble() ?? 0.0,
          width: (data['base']['dimensions']['width'] as num?)?.toDouble() ?? 0.0,
          height: (data['base']['dimensions']['height'] as num?)?.toDouble() ?? 0.0,
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
                (e) => e.toString() == 'Gender.' + data['metadata']['gender'],
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
        compareAtPrice: (data['pricing']['compareAtPrice'] as num?)?.toDouble(),
        taxCode: data['pricing']['taxCode'] ?? '',
        shippingTier: data['pricing']['shippingTier'] ?? '',
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ProductStatus.values.firstWhere(
        (e) => e.toString() == 'ProductStatus.' + data['status'],
        orElse: () => ProductStatus.draft,
      ),
    );
  }

  ProductVariant _variantFromSnapshot(Map<String, dynamic> data, String productId) {
    return ProductVariant(
      id: data['id'] ?? '',
      parentProductId: productId,
      sku: data['sku'] ?? '',
      attributes: Map<String, String>.from(data['attributes'] ?? {}),
      pricing: VariantPricing(
        price: (data['pricing']['price'] as num?)?.toDouble() ?? 0.0,
        compareAtPrice: (data['pricing']['compareAtPrice'] as num?)?.toDouble(),
      ),
      inventory: VariantInventory(
        total: (data['inventory']['total'] as int?) ?? 0,
        reserved: (data['inventory']['reserved'] as int?) ?? 0,
        warehouses: Map<String, int>.from(data['inventory']['warehouses'] ?? {}),
      ),
      media: VariantMedia(
        primary: data['media']['primary'] ?? '',
        gallery: List<String>.from(data['media']['gallery'] ?? []),
        videos: List<String>.from(data['media']['videos'] ?? []),
        model3d: data['media']['model3d'],
      ),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}