import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../../../features/marketplace/domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class FirestoreReviewRepository implements ReviewRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreReviewRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference _reviewsRef() =>
      _firestore.collection('reviews');

  @override
  Future<List<Review>> getReviewsForProduct(String productId) async {
    try {
      final snapshot = await _reviewsRef()
          .where('productId', isEqualTo: productId)
          .where('isVisible', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .where((review) => review.isVisible)
          .toList();
    } catch (e) {
      throw Exception('Failed to get reviews for product: $e');
    }
  }

  @override
  Future<void> addReview(Review review) async {
    try {
      await _reviewsRef().doc(review.id).set(review.toFirestore());
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }
}