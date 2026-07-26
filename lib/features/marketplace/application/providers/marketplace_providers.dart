import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../../../features/business/domain/repositories/analytics_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/wishlist.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/category.dart';
import '../../data/repositories/firestore_product_repository.dart';
import '../../data/repositories/firestore_cart_repository.dart';
import '../../data/repositories/firestore_order_repository.dart';
import '../../data/repositories/firestore_user_repository.dart';
import '../../data/repositories/firestore_wishlist_repository.dart';
import '../../data/repositories/firestore_coupon_repository.dart';
import '../../../../features/business/data/repositories/firestore_analytics_repository.dart';
import '../state/product_list_notifier.dart';
import '../state/product_search_state.dart';
import '../../data/sources/firestore_product_data_source.dart';
import '../../data/sources/product_image_service.dart';

// Core Repository Providers
final firestoreProductDataSourceProvider =
    Provider<FirestoreProductDataSource>((ref) {
  return FirestoreProductDataSource();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dataSource = ref.read(firestoreProductDataSourceProvider);
  return FirestoreProductRepository(dataSource: dataSource);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return FirestoreCartRepository();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirestoreOrderRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirestoreUserRepository();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return FirestoreWishlistRepository();
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return FirestoreCouponRepository();
});

final wishlistProvider = StreamProvider.family<Wishlist?, String>((ref, userId) {
  return ref.watch(wishlistRepositoryProvider).watchWishlist(userId);
});

final wishlistForUserProvider = FutureProvider.family<Wishlist?, String>((ref, userId) {
  return ref.watch(wishlistRepositoryProvider).getWishlist(userId);
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return FirestoreAnalyticsRepository();
});

// Product State
final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return ProductListNotifier(repository);
});

// Product Detail Provider
final productDetailProvider =
    FutureProvider.family<Product?, String>((ref, productId) {
  return ref.watch(productRepositoryProvider).getProductById(productId);
});

// Cart & Order Providers
final cartProvider = StreamProvider.family<Cart?, String>((ref, userId) {
  return ref.watch(cartRepositoryProvider).watchCart(userId);
});

final currentUserIdProvider =
    StateProvider<String?>((ref) => 'demo-user-id');

final cartForUserProvider = FutureProvider.family<Cart?, String>((ref, userId) {
  return ref.watch(cartRepositoryProvider).getCart(userId);
});

final orderForIdProvider =
    FutureProvider.family<Order?, String>((ref, orderId) {
  return ref.watch(orderRepositoryProvider).getOrderById(orderId);
});

// ProductImage Service Provider
final productImageServiceProvider = Provider<ProductImageService>((ref) {
  return ProductImageService();
});

// Search Providers
final productSearchProvider =
    FutureProvider.family<List<Product>, ProductSearchParams>((ref, params) {
  return ref.watch(productRepositoryProvider).searchProducts(
        params.query,
        categoryIds: params.categoryIds,
        minPrice: params.minPrice,
        maxPrice: params.maxPrice,
        sortBy: params.sortField?.firestoreField,
        sortDesc: params.sortDescending,
        inStockOnly: params.inStockOnly,
        freeShippingOnly: params.freeShippingOnly,
        ratingFilter: params.ratingFilter,
      );
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(productRepositoryProvider).getCategories();
});

final brandsProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(productRepositoryProvider).getBrands();
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getFeaturedProducts(limit: 10);
});

final newArrivalsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getNewArrivals(limit: 10);
});

final saleProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getSaleProducts(limit: 10);
});

// Recommendation Providers
final recommendationsProvider =
    FutureProvider.family<List<Recommendation>, String>((ref, userId) {
  return ref
      .watch(analyticsRepositoryProvider)
      .getRecommendationsForUser(userId);
});
