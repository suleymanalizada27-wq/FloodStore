import '../entities/visual_search.dart';
import '../entities/product.dart';

abstract class VisualSearchRepository {
  /// Search products by image
  Future<VisualSearchResult> searchByImage({
    required String imageUrl,
    String? userId,
    int maxResults = 20,
    double minSimilarity = 0.7,
  });

  /// Search by image file (uploads to storage first)
  Future<VisualSearchResult> searchByImageFile({
    required String filePath,
    String? userId,
    int maxResults = 20,
    double minSimilarity = 0.7,
  });

  /// Get visual search history for user
  Future<List<VisualSearchResult>> getHistory(String userId, {int limit = 20});

  /// Delete search history entry
  Future<void> deleteHistoryEntry(String userId, String searchId);

  /// Clear all history
  Future<void> clearHistory(String userId);

  /// Index product images for visual search (run periodically)
  Future<void> indexProductImages({int batchSize = 100});

  /// Get similar products for a product
  Future<List<VisualMatch>> findSimilarProducts(String productId, {int limit = 10});

  /// Extract attributes from image (color, pattern, style, category)
  Future<ImageAttributes> extractAttributes(String imageUrl);

  /// Save user's visual search preference
  Future<void> savePreference(String userId, VisualSearchPreference preference);
}