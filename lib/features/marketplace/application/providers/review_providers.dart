import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:floodstore/features/review/domain/entities/review.dart';
import 'package:floodstore/features/review/domain/repositories/review_repository.dart';
import 'package:floodstore/features/review/data/repositories/firestore_review_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order.dart';
import '../../application/providers/marketplace_providers.dart';

// Repository Provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return FirestoreReviewRepository();
});

// Review Providers
final reviewsForProductProvider =
    FutureProvider.family<List<Review>, String>((ref, productId) {
  return ref.watch(reviewRepositoryProvider).getReviewsForProduct(productId);
});

// Provider to add a review (returns a Future that completes when the review is added)
final addReviewProvider =
    Provider.family<Future<void> Function(Review), String>((ref, productId) {
  return (review) async {
    await ref.watch(reviewRepositoryProvider).addReview(review);
  };
});

// Purchase status provider: checks if the current user has purchased the product
final purchaseStatusProvider =
    FutureProvider.family<bool, String>((ref, productId) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return false;
  final orderRepo = ref.read(orderRepositoryProvider);
  final orders = await orderRepo.getUserOrders(userId);
  // Check if any delivered order contains this product
  for (final order in orders) {
    if (order.status == OrderStatus.delivered) {
      for (final item in order.items) {
        if (item.productId == productId) {
          return true;
        }
      }
    }
  }
  return false;
});