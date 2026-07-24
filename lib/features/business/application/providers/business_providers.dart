import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/loyalty.dart';
import '../../domain/entities/business_account.dart';
import '../../domain/entities/seller_analytics.dart';
import '../../domain/repositories/loyalty_repository.dart';
import '../../domain/repositories/business_account_repository.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../data/repositories/firestore_loyalty_repository.dart';
import '../../data/repositories/firestore_business_account_repository.dart';
import '../../data/repositories/firestore_analytics_repository.dart';

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
  return ref.watch(loyaltyRepositoryProvider).getTiers();
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