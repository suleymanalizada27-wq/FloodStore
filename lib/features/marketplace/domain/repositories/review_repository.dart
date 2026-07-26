import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForProduct(String productId);
  Future<void> addReview(Review review);
}