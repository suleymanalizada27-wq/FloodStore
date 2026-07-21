import 'package:floodstore/features/business/domain/entities/seller_analytics.dart';
import '../entities/recommendation.dart';

abstract class AnalyticsRepository {
  // Seller Analytics
  Future<SellerDashboardData> getSellerDashboard(String sellerId, {DateTimeRange? dateRange});
  Future<List<TopSellingProduct>> getTopSellingProducts(String sellerId, {int limit = 10, DateTimeRange? dateRange});
  Future<List<CategoryPerformance>> getCategoryPerformance(String sellerId, {DateTimeRange? dateRange});
  Future<List<DailySales>> getDailySales(String sellerId, {required DateTimeRange dateRange});
  Future<SellerAdCampaign> createAdCampaign(SellerAdCampaign campaign);
  Future<void> updateAdCampaign(SellerAdCampaign campaign);
  Future<void> deleteAdCampaign(String campaignId);
  Future<List<SellerAdCampaign>> getAdCampaigns(String sellerId, {AdCampaignStatus? status});
  Future<AdMetrics> getAdMetrics(String campaignId, {DateTimeRange? dateRange});
  Future<void> updateAdMetrics(String campaignId, AdMetrics metrics);

  // Recommendations
  Future<List<Recommendation>> getRecommendationsForUser(String userId, {
    RecommendationType? type,
    int limit = 20,
    String? lastDocumentId,
  });
  Future<void> recordRecommendationClick(String userId, String recommendationId);
  Future<void> recordRecommendationImpression(String userId, List<String> recommendationIds);
  Future<void> dismissRecommendation(String userId, String recommendationId);
  Future<void> generateRecommendationsForUser(String userId); // Trigger ML job

  // Platform Analytics (Admin)
  Future<PlatformAnalytics> getPlatformAnalytics({DateTimeRange? dateRange});
  Future<List<DailySales>> getPlatformDailySales({required DateTimeRange dateRange});
  Future<Map<String, double>> getRevenueByCategory({DateTimeRange? dateRange});
  Future<Map<String, int>> getOrdersByStatus({DateTimeRange? dateRange});
  Future<double> getConversionRate({DateTimeRange? dateRange});
  Future<int> getActiveUsers({DateTimeRange? dateRange});
  Future<int> getNewUsers({DateTimeRange? dateRange});
  Future<Map<String, int>> getUsersBySource({DateTimeRange? dateRange});
}