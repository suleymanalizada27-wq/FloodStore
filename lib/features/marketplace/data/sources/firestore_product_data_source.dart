import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/review.dart';

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
    bool inStockOnly = false,
    bool freeShippingOnly = false,
    double? ratingFilter,
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

      // TODO: Implement text search (client-side filtering for MVP)
      // For production, consider implementing a proper search solution
      // or storing a lowercase title field for efficient querying

      // Price range filtering
      if (minPrice != null) {
        queryRef = queryRef.where('pricing.basePrice', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        queryRef = queryRef.where('pricing.basePrice', isLessThanOrEqualTo: maxPrice);
      }

      // Sorting
      if (sortBy != null && sortBy.isNotEmpty) {
        queryRef = queryRef.orderBy(
          sortBy,
          descending: sortDesc,
        );
      }

      queryRef = queryRef.limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _productsCollection.doc(lastDocumentId).get();
        queryRef = queryRef.startAfterDocument(lastDoc);
      }

      final querySnapshot = await queryRef.get();
      final products = querySnapshot.docs
          .map((doc) => _productFromSnapshot(doc))
          .whereType<Product>()
          .toList();

      // Apply client-side filtering for search query (case-insensitive)
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        return products.where((product) =>
            product.base.title.toLowerCase().contains(lowerQuery) ||
            product.base.description.toLowerCase().contains(lowerQuery) ||
            product.base.brand.toLowerCase().contains(lowerQuery))
            .toList();
      }

      return products;
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

  // Category helper methods
  Category _categoryFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      parentId: data['parentId'],
      level: data['level'] ?? 0,
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> _categoryToFirestore(Category category) {
    return {
      'name': category.name,
      'parentId': category.parentId,
      'level': category.level,
      'sortOrder': category.sortOrder,
      'isActive': category.isActive,
    };
  }

  // Review helper methods
  Review _reviewFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      rating: data['rating'] ?? 0.0,
      title: data['title'] ?? '',
      comment: data['comment'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      isVerifiedPurchase: data['isVerifiedPurchase'] ?? false,
      helpfulVotes: data['helpfulVotes'] ?? 0,
      totalVotes: data['totalVotes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isApproved: data['isApproved'] ?? false,
      isFlagged: data['isFlagged'] ?? false,
    );
  }

  Map<String, dynamic> _reviewToFirestore(Review review) {
    return {
      'productId': review.productId,
      'userId': review.userId,
      'rating': review.rating,
      'title': review.title,
      'comment': review.comment,
      'images': review.images,
      'isVerifiedPurchase': review.isVerifiedPurchase,
      'helpfulVotes': review.helpfulVotes,
      'totalVotes': review.totalVotes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isApproved': review.isApproved,
      'isFlagged': review.isFlagged,
    };
  }

  // Product CRUD operations
  Future<String> createProduct(Product product) async {
    try {
      final docRef = await _productsCollection.add(_productToFirestore(product));
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Map<String, dynamic> _productToFirestore(Product product) {
    return {
      'sellerId': product.sellerId,
      'categoryId': product.categoryId,
      'secondaryCategories': product.secondaryCategories,
      'base': {
        'title': product.base.title,
        'description': product.base.description,
        'brand': product.base.brand,
        'sku': product.base.sku,
        'weight': product.base.weight,
        'dimensions': {
          'length': product.base.dimensions.length,
          'width': product.base.dimensions.width,
          'height': product.base.dimensions.height,
        },
        'materials': product.base.materials,
        'careInstructions': product.base.careInstructions,
        'isDigital': product.base.isDigital,
      },
      'metadata': {
        'tags': product.metadata.tags,
        'ageRange': product.metadata.ageRange != null
            ? {
                'min': product.metadata.ageRange?.min,
                'max': product.metadata.ageRange?.max,
              }
            : null,
        'gender': product.metadata.gender?.toString(),
        'season': product.metadata.season,
        'occasion': product.metadata.occasion,
        'style': product.metadata.style,
        'color': product.metadata.color,
        'pattern': product.metadata.pattern,
      },
      'pricing': {
        'basePrice': product.pricing.basePrice,
        'currency': product.pricing.currency,
        'compareAtPrice': product.pricing.compareAtPrice,
        'taxCode': product.pricing.taxCode,
        'shippingTier': product.pricing.shippingTier,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': product.status.name,
    };
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _productsCollection.doc(product.id).update(_productToFirestore(product));
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // Soft delete by setting status to archived
      await _productsCollection.doc(productId).update({
        'status': ProductStatus.archived.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    // For now, we'll just get the first few active products
    // In a real implementation, you might have a "featured" flag or use recommendations
    return await getProductsByCategory('', limit: limit, activeOnly: true);
  }

  Future<List<Product>> getNewArrivals({int limit = 10, DateTime? since}) async {
    // This would require a more complex query with ordering by creation date
    // For simplicity, we'll just get recent products
    // A proper implementation would use orderBy and where on createdAt
    return await getProductsByCategory('', limit: limit, activeOnly: true);
  }

  Future<List<Product>> getSaleProducts({int limit = 10}) async {
    // This would require filtering by compareAtPrice > basePrice
    // For simplicity, we'll just return some products
    // A proper implementation would need to query with where clauses
    return await getProductsByCategory('', limit: limit, activeOnly: true);
  }

  Future<List<Product>> getRelatedProducts(String productId, {int limit = 10}) async {
    // This would require getting the product first, then finding similar ones
    // For simplicity, we'll just return some other products from the same category
    final product = await getProductById(productId);
    if (product == null) return [];

    return await getProductsByCategory(
      product.categoryId,
      limit: limit + 1, // Get one extra to account for possibly excluding the original
      activeOnly: true,
    ).then((products) {
      // Filter out the original product
      return products.where((p) => p.id != productId).take(limit).toList();
    });
  }

  // Variant CRUD operations
  Future<String> createProductVariant(ProductVariant variant) async {
    try {
      // First, we need to get the product to add the variant to it
      final product = await getProductById(variant.parentProductId);
      if (product == null) {
        throw Exception('Parent product not found');
      }

      // Actually, let's store variants in a subcollection for better scalability
      final variantRef = await _productsCollection
          .doc(variant.parentProductId)
          .collection('variants')
          .add(variant.toFirestore());

      return variantRef.id;
    } catch (e) {
      throw Exception('Failed to create product variant: $e');
    }
  }

  Future<void> updateProductVariant(ProductVariant variant) async {
    try {
      await _productsCollection
          .doc(variant.parentProductId)
          .collection('variants')
          .doc(variant.id)
          .update(variant.toFirestore());
    } catch (e) {
      throw Exception('Failed to update product variant: $e');
    }
  }

  Future<void> deleteProductVariant(String variantId) async {
    try {
      // We would need to know the parent product ID to delete from the right subcollection
      // For simplicity, we'll search for it (not efficient for production)
      // A better approach would be to store the parent ID with the variant or use a separate collection

      // Since we don't have an easy way to find the parent, let's assume we need to search
      // This is not ideal but works for demonstration
      final querySnapshot = await _productsCollection
          .where('variants.$variantId', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final productDoc = querySnapshot.docs.first;
        await _productsCollection
            .doc(productDoc.id)
            .collection('variants')
            .doc(variantId)
            .delete();
      }
    } catch (e) {
      throw Exception('Failed to delete product variant: $e');
    }
  }

  Future<void> updateVariantInventory(
    String variantId,
    Map<String, int> warehouseQuantities,
  ) async {
    try {
      // We would need to find the product that contains this variant
      // For simplicity, we'll search for it
      final querySnapshot = await _productsCollection
          .where('variants.$variantId', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final productDoc = querySnapshot.docs.first;
        await _productsCollection
            .doc(productDoc.id)
            .collection('variants')
            .doc(variantId)
            .update({
              'inventory': warehouseQuantities.map((key, value) => MapEntry(key, value)),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      throw Exception('Failed to update variant inventory: $e');
    }
  }

  Future<bool> reserveInventory(
    String variantId,
    int quantity,
    String reservationId,
  ) async {
    try {
      // We would need to find the product that contains this variant
      final querySnapshot = await _productsCollection
          .where('variants.$variantId', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      final productDoc = querySnapshot.docs.first;
      final variantDoc = await _productsCollection
          .doc(productDoc.id)
          .collection('variants')
          .doc(variantId)
          .get();

      if (!variantDoc.exists) return false;

      final currentStock = (variantDoc.data()?['inventory']['total'] as int?) ?? 0;
      final reserved = (variantDoc.data()?['inventory']['reserved'] as int?) ?? 0;

      if (currentStock - reserved < quantity) return false;

      // Reserve the inventory
      await _productsCollection
          .doc(productDoc.id)
          .collection('variants')
          .doc(variantId)
          .update({
        'inventory.reserved': reserved + quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> releaseInventory(
    String variantId,
    int quantity,
    String reservationId,
  ) async {
    try {
      // We would need to find the product that contains this variant
      final querySnapshot = await _productsCollection
          .where('variants.$variantId', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final productDoc = querySnapshot.docs.first;
        await _productsCollection
            .doc(productDoc.id)
            .collection('variants')
            .doc(variantId)
            .update({
          'inventory.reserved': FieldValue.increment(-quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to release inventory: $e');
    }
  }

  // Review operations
  Future<List<Review>> getProductReviews(String productId, {
    int limit = 20,
    String? lastDocumentId,
    bool approvedOnly = true,
  }) async {
    try {
      Query query = _productsCollection
          .doc(productId)
          .collection('reviews')
          .limit(limit);

      if (approvedOnly) {
        query = query.where('isApproved', isEqualTo: true);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _productsCollection
            .doc(productId)
            .collection('reviews')
            .doc(lastDocumentId)
            .get();
        query = query.startAfterDocument(lastDoc);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => _reviewFromSnapshot(doc))
          .whereType<Review>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get product reviews: $e');
    }
  }

  Future<String> addProductReview(Review review) async {
    try {
      final docRef = await _productsCollection
          .doc(review.productId)
          .collection('reviews')
          .add(_reviewToFirestore(review));
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product review: $e');
    }
  }

  Future<void> updateProductReview(Review review) async {
    try {
      await _productsCollection
          .doc(review.productId)
          .collection('reviews')
          .doc(review.id)
          .update(_reviewToFirestore(review));
    } catch (e) {
      throw Exception('Failed to update product review: $e');
    }
  }

  Future<void> deleteProductReview(String reviewId) async {
    try {
      // We would need to know the product ID to delete from the right subcollection
      // For simplicity, we'll need to search for it (not efficient for production)
      // In a real app, you'd store the product ID with the review or use a separate collection

      // Since we don't have an easy way to find the review, let's assume we need to search
      // This is not ideal but works for demonstration
      // A better approach would be to use a collection group query

      // For now, we'll skip the implementation as it requires collection group queries
      // which need Firebase console configuration
      throw UnimplementedError('deleteProductReview not implemented');
    } catch (e) {
      throw Exception('Failed to delete product review: $e');
    }
  }

  Future<void> voteReviewHelpful(String reviewId, String userId, bool isHelpful) async {
    try {
      // We would need to know the product ID to update the right review
      // For simplicity, we'll need to search for it
      // In a real app, you'd store the product ID with the review or use a separate collection

      // Since we don't have an easy way to find the review, let's assume we need to search
      // This is not ideal but works for demonstration
      // A better approach would be to use a collection group query

      // For now, we'll skip the implementation as it requires collection group queries
      // which need Firebase console configuration
      throw UnimplementedError('voteReviewHelpful not implemented');
    } catch (e) {
      throw Exception('Failed to vote on review: $e');
    }
  }

  // Category operations
  Future<List<Category>> getCategories({
    bool onlyActive = true,
    String? parentId,
  }) async {
    try {
      Query query = _categoriesCollection;

      if (onlyActive) {
        query = query.where('isActive', isEqualTo: true);
      }

      if (parentId != null) {
        query = query.where('parentId', isEqualTo: parentId);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => _categoryFromSnapshot(doc))
          .whereType<Category>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (!doc.exists) return null;
      return _categoryFromSnapshot(doc);
    } catch (e) {
      throw Exception('Failed to get category by ID: $e');
    }
  }

  Future<String> createCategory(Category category) async {
    try {
      final docRef = await _categoriesCollection.add(_categoryToFirestore(category));
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _categoriesCollection.doc(category.id).update(_categoryToFirestore(category));
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}

// Extension to convert ProductVariant to Firestore map
extension ProductVariantExtensions on ProductVariant {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'parentProductId': parentProductId,
      'sku': sku,
      'attributes': attributes,
      'pricing': {
        'price': pricing.price,
        'compareAtPrice': pricing.compareAtPrice,
      },
      'inventory': {
        'total': inventory.total,
        'reserved': inventory.reserved,
        'warehouses': inventory.warehouses,
      },
      'media': {
        'primary': media.primary,
        'gallery': media.gallery,
        'videos': media.videos,
        'model3d': media.model3d,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}