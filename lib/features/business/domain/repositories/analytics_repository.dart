import '../entities/seller_analytics.dart';
import 'package:floodstore/features/recommendation/domain/entities/recommendation.dart';

abstract class AnalyticsRepository {
  Future<SellerDashboardData> getSellerDashboard(String sellerId,
      {DateTimeRange? dateRange});
  Future<List<SellerAdCampaign>> getAdCampaigns(String sellerId,
      {AdCampaignStatus? status});
  Future<SellerAdCampaign> createAdCampaign(SellerAdCampaign campaign);
  Future<void> updateAdCampaign(SellerAdCampaign campaign);
  Future<void> deleteAdCampaign(String campaignId);
  Future<List<TopSellingProduct>> getTopSellingProducts(
    String sellerId, {
    int limit = 10,
    DateTimeRange? dateRange,
  });
  Future<List<CategoryPerformance>> getCategoryPerformance(
    String sellerId, {
    DateTimeRange? dateRange,
  });
  Future<List<DailySales>> getDailySales(
    String sellerId, {
    required DateTimeRange dateRange,
  });
  Future<List<Recommendation>> getRecommendationsForUser(
    String userId, {
    RecommendationType? type,
    int limit = 20,
    String? lastDocumentId,
  });
  Future<AdMetrics> getAdMetrics(String campaignId,
      {DateTimeRange? dateRange});
  Future<void> updateAdMetrics(String campaignId, AdMetrics metrics);
  Future<void> recordRecommendationClick(
      String userId, String recommendationId);
  Future<void> recordRecommendationImpression(
      String userId, List<String> recommendationIds);
  Future<void> dismissRecommendation(
      String userId, String recommendationId);
  Future<void> generateRecommendationsForUser(String userId);
  Future<PlatformAnalytics> getPlatformAnalytics(
      {DateTimeRange? dateRange});
  Future<List<DailySales>> getPlatformDailySales(
      {required DateTimeRange dateRange});
  Future<Map<String, double>> getRevenueByCategory(
      {DateTimeRange? dateRange});
  Future<Map<String, int>> getOrdersByStatus(
      {DateTimeRange? dateRange});
  Future<double> getConversionRate({DateTimeRange? dateRange});
  Future<int> getActiveUsers({DateTimeRange? dateRange});
  Future<int> getNewUsers({DateTimeRange? dateRange});
  Future<Map<String, int>> getUsersBySource(
      {DateTimeRange? dateRange});
}