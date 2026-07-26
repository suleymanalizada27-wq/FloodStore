import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/business/domain/entities/loyalty.dart';
import 'package:floodstore/features/business/domain/entities/business_account.dart';
import 'package:floodstore/features/business/domain/entities/seller_analytics.dart';
import 'package:floodstore/features/marketplace/domain/entities/product.dart';
import 'package:floodstore/features/marketplace/domain/entities/order.dart';
import 'package:floodstore/features/business/domain/repositories/loyalty_repository.dart';
import 'package:floodstore/features/business/domain/repositories/business_account_repository.dart';
import 'package:floodstore/features/business/domain/repositories/analytics_repository.dart';
import 'package:floodstore/features/business/domain/repositories/seller_repository.dart';
import 'package:floodstore/features/business/data/repositories/firestore_loyalty_repository.dart';
import 'package:floodstore/features/business/data/repositories/firestore_business_account_repository.dart';
import 'package:floodstore/features/business/data/repositories/firestore_analytics_repository.dart';
import 'package:floodstore/features/business/data/repositories/firestore_seller_repository.dart';

// Repository Providers
final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  return FirestoreLoyaltyRepository();
});

final businessAccountRepositoryProvider = Provider<BusinessAccountRepository>((ref) {
  return FirestoreBusinessAccountRepository();
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return FirestoreAnalyticsRepository();
});

final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  return FirestoreSellerRepository();
});

// Loyalty Providers
final loyaltyAccountProvider =
    FutureProvider.family<LoyaltyAccount?, String>((ref, userId) {
  return ref.watch(loyaltyRepositoryProvider).getOrCreateAccount(userId);
});

final loyaltyTransactionsProvider =
    FutureProvider.family<List<PointTransaction>, String>((ref, userId) {
  return ref.watch(loyaltyRepositoryProvider).getTransactions(userId);
});

final loyaltyTiersProvider = FutureProvider<List<LoyaltyTier>>((ref) {
  return ref.read(loyaltyRepositoryProvider).getTiers();
});

final tierProgressProvider =
    FutureProvider.family<TierProgress?, String>((ref, userId) {
  return ref.watch(loyaltyRepositoryProvider).getTierProgress(userId);
});

final loyaltyLeaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) {
  return ref.watch(loyaltyRepositoryProvider).getLeaderboard();
});

// Business Account Providers
final businessAccountProvider =
    FutureProvider.family<BusinessAccount?, String>((ref, userId) {
  return ref.watch(businessAccountRepositoryProvider).getBusinessAccount(userId);
});

// Seller Analytics Providers
final sellerDashboardProvider =
    FutureProvider.family<SellerDashboardData?, String>((ref, sellerId) {
  return ref.watch(analyticsRepositoryProvider).getSellerDashboard(sellerId);
});

final sellerAdCampaignsProvider =
    FutureProvider.family<List<SellerAdCampaign>?, String>((ref, sellerId) {
  return ref.watch(analyticsRepositoryProvider).getAdCampaigns(sellerId);
});

// Seller Providers
final sellerProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, sellerId) {
  return ref.watch(sellerRepositoryProvider).getSellerProducts(sellerId);
});

final sellerOrdersProvider =
    FutureProvider.family<List<Order>, String>((ref, sellerId) {
  return ref.watch(sellerRepositoryProvider).getSellerOrders(sellerId);
});