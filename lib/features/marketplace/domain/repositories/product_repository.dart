import '../entities/product.dart';
import '../entities/product_variant.dart';
import '../entities/category.dart';
import '../entities/review.dart';

/// Abstract repository for product-related operations
abstract class ProductRepository {
  /// Gets a product by ID
  Future<Product?> getProductById(String productId);

  /// Gets a product variant by ID
  Future<ProductVariant?> getProductVariantById(String variantId);

  /// Gets products by category
  Future<List<Product>> getProductsByCategory(String categoryId, {
    int limit = 20,
    String? lastDocumentId,
    bool activeOnly = true,
  });

  /// Gets products by seller
  Future<List<Product>> getProductsBySeller(String sellerId, {
    int limit = 20,
    String? lastDocumentId,
    bool activeOnly = true,
  });

  /// Searches products by query
  Future<List<Product>> searchProducts(String query, {
    int limit = 20,
    String? lastDocumentId,
    List<String>? categoryIds,
    double? minPrice,
    double? maxPrice,
    String? sortBy, // relevance, price_low_high, price_high_low, newest, rating
    bool sortDesc = true,
  });

  /// Gets featured/recommended products
  Future<List<Product>> getFeaturedProducts({int limit = 10});

  /// Gets new arrivals
  Future<List<Product>> getNewArrivals({int limit = 10, DateTime? since});

  /// Gets products on sale
  Future<List<Product>> getSaleProducts({int limit = 10});

  /// Gets related products based on a product
  Future<List<Product>> getRelatedProducts(String productId, {
    int limit = 10,
  });

  /// Creates a new product
  Future<String> createProduct(Product product);

  /// Updates an existing product
  Future<void> updateProduct(Product product);

  /// Deletes a product (soft delete by setting status to archived)
  Future<void> deleteProduct(String productId);

  /// Creates a new product variant
  Future<String> createProductVariant(ProductVariant variant);

  /// Updates an existing product variant
  Future<void> updateProductVariant(ProductVariant variant);

  /// Deletes a product variant
  Future<void> deleteProductVariant(String variantId);

  /// Updates inventory for a product variant
  Future<void> updateVariantInventory(
    String variantId,
    Map<String, int> warehouseQuantities, // warehouseId -> quantity
  );

  /// Reserves inventory for a product variant (for cart/checkout)
  Future<bool> reserveInventory(
    String variantId,
    int quantity,
    String reservationId, // cart ID or order ID
  );

  /// Releases reserved inventory
  Future<void> releaseInventory(
    String variantId,
    int quantity,
    String reservationId,
  );

  /// Gets product reviews
  Future<List<Review>> getProductReviews(String productId, {
    int limit = 20,
    String? lastDocumentId,
    bool approvedOnly = true,
  });

  /// Adds a review for a product
  Future<String> addProductReview(Review review);

  /// Updates a product review
  Future<void> updateProductReview(Review review);

  /// Deletes a product review
  Future<void> deleteProductReview(String reviewId);

  /// Helpful vote for a review
  Future<void> voteReviewHelpful(String reviewId, String userId, bool isHelpful);

  /// Gets categories
  Future<List<Category>> getCategories({
    bool onlyActive = true,
    String? parentId, // null for root categories
  });

  /// Gets a category by ID
  Future<Category?> getCategoryById(String categoryId);

  /// Creates a new category
  Future<String> createCategory(Category category);

  /// Updates an existing category
  Future<void> updateCategory(Category category);

  /// Deletes a category
  Future<void> deleteCategory(String categoryId);
}