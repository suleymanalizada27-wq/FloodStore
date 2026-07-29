import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floodstore/features/review/domain/entities/review.dart';
import 'package:floodstore/features/review/domain/repositories/review_repository.dart';

class FirestoreReviewRepository implements ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Review>> getReviewsForProduct(String productId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reviews for product: $e');
    }
  }

  @override
  Future<void> addReview(Review review) async {
    try {
      final docRef = _firestore.collection('reviews').doc();
      review = review.copyWith(id: docRef.id);
      await docRef.set(review.toFirestore());
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  @override
  Future<void> updateReview(Review review) async {
    try {
      if (review.id == null || review.id!.isEmpty) {
        throw Exception('Review ID is required for update');
      }
      await _firestore.collection('reviews').doc(review.id).update(review.toFirestore());
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  @override
  Future<Review?> getReviewById(String reviewId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('reviews').doc(reviewId).get();
      if (doc.exists) {
        return Review.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get review by ID: $e');
    }
  }
}
