import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/product_repository.dart';
import '../sources/firestore_product_data_source.dart';

/// Firestore implementation of the product repository
class FirestoreProductRepository implements ProductRepository {
  final FirestoreProductDataSource _dataSource;

  FirestoreProductRepository({FirestoreProductDataSource? dataSource})
      : _dataSource = dataSource ?? FirestoreProductDataSource();

  @override
  Future<Product?> getProductById(String productId) async {
    try {
      return await _dataSource.getProductById(productId);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  @override
  Future<ProductVariant?> getProductVariantById(String variantId) async {
    try {
      return await _dataSource.getProductVariantById(variantId);
    } catch (e) {
      throw Exception('Failed to get product variant: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId, {
    int limit = 20,
    String? lastDocumentId,
    bool activeOnly = true,
  }) async {
    try {
      return await _dataSource.getProductsByCategory(
        categoryId,
        limit: limit,
        lastDocumentId: lastDocumentId,
        activeOnly: activeOnly,
      );
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  @override
  Future<List<Product>> getProductsBySeller(String sellerId, {
    int limit = 20,
    String? lastDocumentId,
    bool activeOnly = true,
  }) async {
    try {
      return await _dataSource.getProductsBySeller(
        sellerId,
        limit: limit,
        lastDocumentId: lastDocumentId,
        activeOnly: activeOnly,
      );
    } catch (e) {
      throw Exception('Failed to get products by seller: $e');
    }
  }

  @override
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
      return await _dataSource.searchProducts(
        query,
        limit: limit,
        lastDocumentId: lastDocumentId,
        categoryIds: categoryIds,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortDesc: sortDesc,
      );
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      return await _dataSource.getFeaturedProducts(limit: limit);
    } catch (e) {
      throw Exception('Failed to get featured products: $e');
    }
  }

  @override
  Future<List<Product>> getNewArrivals({int limit = 10, DateTime? since}) async {
    try {
      return await _dataSource.getNewArrivals(limit: limit, since: since);
    } catch (e) {
      throw Exception('Failed to get new arrivals: $e');
    }
  }

  @override
  Future<List<Product>> getSaleProducts({int limit = 10}) async {
    try {
      return await _dataSource.getSaleProducts(limit: limit);
    } catch (e) {
      throw Exception('Failed to get sale products: $e');
    }
  }

  @override
  Future<List<Product>> getRelatedProducts(String productId, {
    int limit = 10,
  }) async {
    try {
      return await _dataSource.getRelatedProducts(productId, limit: limit);
    } catch (e) {
      throw Exception('Failed to get related products: $e');
    }
  }

  @override
  Future<String> createProduct(Product product) async {
    try {
      return await _dataSource.createProduct(product);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      await _dataSource.updateProduct(product);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _dataSource.deleteProduct(productId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<String> createProductVariant(ProductVariant variant) async {
    try {
      return await _dataSource.createProductVariant(variant);
    } catch (e) {
      throw Exception('Failed to create product variant: $e');
    }
  }

  @override
  Future<void> updateProductVariant(ProductVariant variant) async {
    try {
      await _dataSource.updateProductVariant(variant);
    } catch (e) {
      throw Exception('Failed to update product variant: $e');
    }
  }

  @override
  Future<void> deleteProductVariant(String variantId) async {
    try {
      await _dataSource.deleteProductVariant(variantId);
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
      await _dataSource.updateVariantInventory(variantId, warehouseQuantities);
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
      return await _dataSource.reserveInventory(variantId, quantity, reservationId);
    } catch (e) {
      throw Exception('Failed to reserve inventory: $e');
    }
  }

  @override
  Future<void> releaseInventory(
    String variantId,
    int quantity,
    String reservationId,
  ) async {
    try {
      await _dataSource.releaseInventory(variantId, quantity, reservationId);
    } catch (e) {
      throw Exception('Failed to release inventory: $e');
    }
  }

  @override
  Future<List<Review>> getProductReviews(String productId, {
    int limit = 20,
    String? lastDocumentId,
    bool approvedOnly = true,
  }) async {
    try {
      return await _dataSource.getProductReviews(
        productId,
        limit: limit,
        lastDocumentId: lastDocumentId,
        approvedOnly: approvedOnly,
      );
    } catch (e) {
      throw Exception('Failed to get product reviews: $e');
    }
  }

  @override
  Future<String> addProductReview(Review review) async {
    try {
      return await _dataSource.addProductReview(review);
    } catch (e) {
      throw Exception('Failed to add product review: $e');
    }
  }

  @override
  Future<void> updateProductReview(Review review) async {
    try {
      await _dataSource.updateProductReview(review);
    } catch (e) {
      throw Exception('Failed to update product review: $e');
    }
  }

  @override
  Future<void> deleteProductReview(String reviewId) async {
    try {
      await _dataSource.deleteProductReview(reviewId);
    } catch (e) {
      throw Exception('Failed to delete product review: $e');
    }
  }

  @override
  Future<void> voteReviewHelpful(String reviewId, String userId, bool isHelpful) async {
    try {
      await _dataSource.voteReviewHelpful(reviewId, userId, isHelpful);
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
      return await _dataSource.getCategories(
        onlyActive: onlyActive,
        parentId: parentId,
      );
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      return await _dataSource.getCategoryById(categoryId);
    } catch (e) {
      throw Exception('Failed to get category by ID: $e');
    }
  }

  @override
  Future<String> createCategory(Category category) async {
    try {
      return await _dataSource.createCategory(category);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      await _dataSource.updateCategory(category);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _dataSource.deleteCategory(categoryId);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}