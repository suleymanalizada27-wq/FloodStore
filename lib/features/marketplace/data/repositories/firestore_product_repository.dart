import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/product_repository.dart';
import '../sources/firestore_product_data_source.dart';

class FirestoreProductRepository implements ProductRepository {
  final FirestoreProductDataSource _dataSource;

  FirestoreProductRepository({FirestoreProductDataSource? dataSource})
      : _dataSource = dataSource ?? FirestoreProductDataSource();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<Product?> getProductById(String productId) {
    return _dataSource.getProductById(productId);
  }

  @override
  Future<ProductVariant?> getProductVariantById(String variantId) {
    return _dataSource.getProductVariantById(variantId);
  }

  @override
  Future<List<Product>> getProductsByCategory(
    String categoryId, {
    int limit = 20,
    String? lastDocumentId,
    bool activeOnly = true,
  }) {
    return _dataSource.getProductsByCategory(
      categoryId,
      limit: limit,
      lastDocumentId: lastDocumentId,
      activeOnly: activeOnly,
    );
  }

  @override
  Future<List<Product>> getProductsBySeller(
    String sellerId, {
    int limit = 20,
    String? lastDocumentId,
    bool activeOnly = true,
  }) {
    return _dataSource.getProductsBySeller(
      sellerId,
      limit: limit,
      lastDocumentId: lastDocumentId,
      activeOnly: activeOnly,
    );
  }

  @override
  Future<List<Product>> searchProducts(
    String query, {
    int limit = 20,
    String? lastDocumentId,
    List<String>? categoryIds,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool sortDesc = true,
  }) {
    return _dataSource.searchProducts(
      query,
      limit: limit,
      lastDocumentId: lastDocumentId,
      categoryIds: categoryIds,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
      sortDesc: sortDesc,
    );
  }

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 10}) {
    return _dataSource.getProductsByCategory('', limit: limit);
  }

  @override
  Future<List<Product>> getNewArrivals({int limit = 10, DateTime? since}) {
    return _dataSource.getProductsByCategory('', limit: limit);
  }

  @override
  Future<List<Product>> getSaleProducts({int limit = 10}) {
    return _dataSource.getProductsByCategory('', limit: limit);
  }

  @override
  Future<List<Product>> getRelatedProducts(String productId, {int limit = 10}) async {
    final product = await getProductById(productId);
    if (product == null) return [];
    final products = await _dataSource.getProductsByCategory(
      product.categoryId,
      limit: limit + 1,
    );
    return products.where((p) => p.id != productId).take(limit).toList();
  }

  @override
  Future<String> createProduct(Product product) async {
    try {
      final docRef =
          await _firestore.collection('products').add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toFirestore());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'status': ProductStatus.archived.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<String> createProductVariant(ProductVariant variant) async {
    try {
      final docRef = await _firestore
          .collection('products')
          .doc(variant.parentProductId)
          .collection('variants')
          .add(variant.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product variant: $e');
    }
  }

  @override
  Future<void> updateProductVariant(ProductVariant variant) async {
    try {
      await _firestore
          .collection('products')
          .doc(variant.parentProductId)
          .collection('variants')
          .doc(variant.id)
          .update(variant.toFirestore());
    } catch (e) {
      throw Exception('Failed to update product variant: $e');
    }
  }

  @override
  Future<void> deleteProductVariant(String variantId) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup('variants')
          .where('id', isEqualTo: variantId)
          .limit(1)
          .get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete product variant: $e');
    }
  }

  @override
  Future<void> updateVariantInventory(
    String variantId,
    Map<String, int> warehouseQuantities,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup('variants')
          .where('id', isEqualTo: variantId)
          .limit(1)
          .get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.update({
          'inventory.warehouses': warehouseQuantities,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update variant inventory: $e');
    }
  }

  @override
  Future<bool> reserveInventory(
    String variantId,
    int quantity,
    String reservationId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup('variants')
          .where('id', isEqualTo: variantId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return false;
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final inventory = (data['inventory'] as Map?)?.cast<String, dynamic>();
      final total = (inventory?['total'] as num?)?.toInt() ?? 0;
      final reserved = (inventory?['reserved'] as num?)?.toInt() ?? 0;
      if (total - reserved < quantity) return false;
      await doc.reference.update({
        'inventory.reserved': reserved + quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> releaseInventory(
    String variantId,
    int quantity,
    String reservationId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup('variants')
          .where('id', isEqualTo: variantId)
          .limit(1)
          .get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.update({
          'inventory.reserved': FieldValue.increment(-quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to release inventory: $e');
    }
  }

  @override
  Future<List<Review>> getProductReviews(
    String productId, {
    int limit = 20,
    String? lastDocumentId,
    bool approvedOnly = true,
  }) async {
    try {
      Query query = _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .limit(limit);
      if (approvedOnly) {
        query = query.where('isApproved', isEqualTo: true);
      }
      if (lastDocumentId != null) {
        final lastDoc = await _firestore
            .collection('products')
            .doc(productId)
            .collection('reviews')
            .doc(lastDocumentId)
            .get();
        if (lastDoc.exists) query = query.startAfterDocument(lastDoc);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) =>
              ReviewMapper.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get product reviews: $e');
    }
  }

  @override
  Future<String> addProductReview(Review review) async {
    try {
      final docRef = await _firestore
          .collection('products')
          .doc(review.productId)
          .collection('reviews')
          .add(ReviewMapper.toFirestore(review));
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product review: $e');
    }
  }

  @override
  Future<void> updateProductReview(Review review) async {
    try {
      await _firestore
          .collection('products')
          .doc(review.productId)
          .collection('reviews')
          .doc(review.id)
          .update(ReviewMapper.toFirestore(review));
    } catch (e) {
      throw Exception('Failed to update product review: $e');
    }
  }

  @override
  Future<void> deleteProductReview(String reviewId) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup('reviews')
          .where(FieldPath.documentId, isEqualTo: reviewId)
          .limit(1)
          .get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete product review: $e');
    }
  }

  @override
  Future<void> voteReviewHelpful(
    String reviewId,
    String userId,
    bool isHelpful,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collectionGroup('reviews')
          .where(FieldPath.documentId, isEqualTo: reviewId)
          .limit(1)
          .get();
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final currentHelpful = (data['helpfulVotes'] as num?)?.toInt() ?? 0;
        final currentTotal = (data['totalVotes'] as num?)?.toInt() ?? 0;
        await doc.reference.update({
          'helpfulVotes': isHelpful ? currentHelpful + 1 : currentHelpful,
          'totalVotes': currentTotal + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to vote on review: $e');
    }
  }

  @override
  Future<List<Category>> getCategories({
    bool onlyActive = true,
    String? parentId,
  }) async {
    try {
      Query query = _firestore.collection('categories');
      if (onlyActive) query = query.where('isActive', isEqualTo: true);
      if (parentId != null) {
        query = query.where('parentId', isEqualTo: parentId);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => CategoryMapper.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc =
          await _firestore.collection('categories').doc(categoryId).get();
      if (!doc.exists) return null;
      return CategoryMapper.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get category by ID: $e');
    }
  }

  @override
  Future<String> createCategory(Category category) async {
    try {
      final docRef = await _firestore
          .collection('categories')
          .add(CategoryMapper.toFirestore(category));
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(CategoryMapper.toFirestore(category));
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}

class ProductMapper {
  static Map<String, dynamic> toFirestore(Product p) {
    return {
      'sellerId': p.sellerId,
      'categoryId': p.categoryId,
      'secondaryCategories': p.secondaryCategories,
      'searchTitle': p.base.title.toLowerCase(),
      'base': {
        'title': p.base.title,
        'description': p.base.description,
        'brand': p.base.brand,
        'sku': p.base.sku,
        'weight': p.base.weight,
        'dimensions': {
          'length': p.base.dimensions.length,
          'width': p.base.dimensions.width,
          'height': p.base.dimensions.height,
        },
        'materials': p.base.materials,
        'careInstructions': p.base.careInstructions,
        'isDigital': p.base.isDigital,
      },
      'metadata': {
        'tags': p.metadata.tags,
        'ageRange': p.metadata.ageRange != null
            ? {
                'min': p.metadata.ageRange!.min,
                'max': p.metadata.ageRange!.max,
              }
            : null,
        'gender': p.metadata.gender?.name,
        'season': p.metadata.season,
        'occasion': p.metadata.occasion,
        'style': p.metadata.style,
        'color': p.metadata.color,
        'pattern': p.metadata.pattern,
      },
      'pricing': {
        'basePrice': p.pricing.basePrice,
        'currency': p.pricing.currency,
        'compareAtPrice': p.pricing.compareAtPrice,
        'taxCode': p.pricing.taxCode,
        'shippingTier': p.pricing.shippingTier,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': p.status.name,
    };
  }
}

extension ProductFirestore on Product {
  Map<String, dynamic> toFirestore() => ProductMapper.toFirestore(this);
}

extension ProductVariantFirestore on ProductVariant {
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

class CategoryMapper {
  static Map<String, dynamic> toFirestore(Category c) {
    return {
      'name': c.name,
      'parentId': c.parentId,
      'level': c.level,
      'sortOrder': c.sortOrder,
      'isActive': c.isActive,
    };
  }

  static Category fromFirestore(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      parentId: data['parentId'],
      level: data['level'] ?? 0,
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }
}

class ReviewMapper {
  static Map<String, dynamic> toFirestore(Review r) {
    return {
      'productId': r.productId,
      'userId': r.userId,
      'rating': r.rating,
      'title': r.title,
      'comment': r.comment,
      'images': r.images,
      'isVerifiedPurchase': r.isVerifiedPurchase,
      'helpfulVotes': r.helpfulVotes,
      'totalVotes': r.totalVotes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isApproved': r.isApproved,
      'isFlagged': r.isFlagged,
    };
  }

  static Review fromFirestore(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      title: data['title'],
      comment: data['comment'],
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
}
