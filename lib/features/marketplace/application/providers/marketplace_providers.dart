import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/repositories/loyalty_repository.dart';
import '../../domain/repositories/visual_search_repository.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../domain/repositories/business_account_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../../procurement/domain/repositories/rfq_repository.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/loyalty.dart';
import '../../domain/entities/visual_search.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/seller_analytics.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/wishlist.dart';
import '../../data/repositories/firestore_product_repository.dart';
import '../../data/repositories/firestore_cart_repository.dart';
import '../../data/repositories/firestore_order_repository.dart';
import '../../data/repositories/firestore_user_repository.dart';
import '../../data/repositories/firestore_chat_repository.dart';
import '../../data/repositories/firestore_notification_repository.dart';
import '../../data/repositories/firestore_analytics_repository.dart';
import '../../data/repositories/firestore_loyalty_repository.dart';
import '../../data/repositories/firestore_visual_search_repository.dart';
import '../../data/repositories/firestore_coupon_repository.dart';
import '../../data/repositories/firestore_business_account_repository.dart';
import '../../data/repositories/firestore_wishlist_repository.dart';
import '../../data/repositories/firestore_warehouse_repository.dart';
import '../../data/repositories/firestore_inventory_repository.dart';
import '../../../procurement/data/repositories/firestore_rfq_repository.dart';
import '../../data/sources/firestore_product_data_source.dart';
import '../../data/sources/product_image_service.dart';
import '../state/product_list_notifier.dart';
import '../state/product_search_state.dart';

// Core Repository Providers
final firestoreProductDataSourceProvider = Provider<FirestoreProductDataSource>((ref) {
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

// New Feature Repository Providers
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirestoreChatRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FirestoreNotificationRepository();
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return FirestoreAnalyticsRepository();
});

final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  return FirestoreLoyaltyRepository();
});

final visualSearchRepositoryProvider = Provider<VisualSearchRepository>((ref) {
  return FirestoreVisualSearchRepository();
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return FirestoreCouponRepository();
});

final businessAccountRepositoryProvider = Provider<BusinessAccountRepository>((ref) {
  return FirestoreBusinessAccountRepository();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return FirestoreWishlistRepository();
});

// Warehouse and Inventory Repository Providers
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return FirestoreWarehouseRepository();
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return FirestoreInventoryRepository();
});

final rfqRepositoryProvider = Provider<RFQRepository>((ref) {
  return FirestoreRFQRepository();
});

final productImageServiceProvider = Provider<ProductImageService>((ref) {
  return ProductImageService();
});

// Product State
final productListProvider = StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return ProductListNotifier(repository);
});

// Product Detail Provider
final productDetailProvider = FutureProvider.family<Product?, String>((ref, productId) {
  return ref.watch(productRepositoryProvider).getProductById(productId);
});

// Cart & Order Providers

// Cart & Order Providers
final cartProvider = StreamProvider.family<Cart?, String>((ref, userId) {
  return ref.watch(cartRepositoryProvider).watchCart(userId);
});

final currentUserIdProvider = StateProvider<String?>((ref) => 'demo-user-id');

final cartForUserProvider = FutureProvider.family<Cart?, String>((ref, userId) {
  return ref.watch(cartRepositoryProvider).getCart(userId);
});

final orderForIdProvider = FutureProvider.family<Order?, String>((ref, orderId) {
  return ref.watch(orderRepositoryProvider).getOrderById(orderId);
});

// Chat Providers
final chatSessionsProvider = FutureProvider.family<List<ChatSession>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).getUserSessions(userId);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, sessionId) {
  return ref.watch(chatRepositoryProvider).watchMessages(sessionId);
});

// Notification Providers
final notificationsProvider = FutureProvider.family<List<Notification>, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).getNotifications(userId);
});

final unreadNotificationCountProvider = StreamProvider.family<int, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).watchUnreadCount(userId);
});

final notificationPreferencesProvider = FutureProvider.family<NotificationPreferences, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).getPreferences(userId);
});

// Loyalty Providers
final loyaltyAccountProvider = FutureProvider.family<LoyaltyAccount, String>((ref, userId) {
  return ref.watch(loyaltyRepositoryProvider).getOrCreateAccount(userId);
});

final loyaltyTransactionsProvider = FutureProvider.family<List<PointTransaction>, String>((ref, userId) {
  return ref.watch(loyaltyRepositoryProvider).getTransactions(userId);
});

final loyaltyTiersProvider = FutureProvider<List<LoyaltyTier>>((ref) {
  return ref.watch(loyaltyRepositoryProvider).getTiers();
});

final tierProgressProvider = FutureProvider.family<TierProgress, String>((ref, userId) {
  return ref.watch(loyaltyRepositoryProvider).getTierProgress(userId);
});

final loyaltyLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) {
  return ref.watch(loyaltyRepositoryProvider).getLeaderboard();
});

// Wishlist Providers
final wishlistProvider = StreamProvider.family<Wishlist?, String>((ref, userId) {
  return ref.watch(wishlistRepositoryProvider).watchWishlist(userId);
});

final wishlistForUserProvider = FutureProvider.family<Wishlist?, String>((ref, userId) {
  return ref.watch(wishlistRepositoryProvider).getWishlist(userId);
});

// Visual Search Providers
final visualSearchHistoryProvider = FutureProvider.family<List<VisualSearchResult>, String>((ref, userId) {
  return ref.watch(visualSearchRepositoryProvider).getHistory(userId);
});

// Coupon Providers
final userCouponsProvider = FutureProvider.family<List<Coupon>, String>((ref, userId) {
  return ref.watch(couponRepositoryProvider).getUserCoupons(userId);
});

final activeBundlesProvider = FutureProvider<List<Bundle>>((ref) {
  return ref.watch(couponRepositoryProvider).getActiveBundles();
});

// Seller Analytics Providers
final sellerDashboardProvider = FutureProvider.family<SellerDashboardData, String>((ref, sellerId) {
  return ref.watch(analyticsRepositoryProvider).getSellerDashboard(sellerId);
});

final sellerAdCampaignsProvider = FutureProvider.family<List<SellerAdCampaign>, String>((ref, sellerId) {
  return ref.watch(analyticsRepositoryProvider).getAdCampaigns(sellerId);
});

// Recommendation Providers
final recommendationsProvider = FutureProvider.family<List<Recommendation>, String>((ref, userId) {
  return ref.watch(analyticsRepositoryProvider).getRecommendationsForUser(userId);
});

// Search Providers
final productSearchProvider = FutureProvider.family<List<Product>, ProductSearchParams>((ref, params) {
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

final featuredProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getFeaturedProducts(limit: 10);
});

final newArrivalsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getNewArrivals(limit: 10);
});

final saleProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getSaleProducts(limit: 10);
});