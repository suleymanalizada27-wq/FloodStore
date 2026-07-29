import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForProduct(String productId);
  Future<void> addReview(Review review);
  Future<void> updateReview(Review review);
  Future<void> deleteReview(String reviewId);
  Future<Review?> getReviewById(String reviewId);
}
