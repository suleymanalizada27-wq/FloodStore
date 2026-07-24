import '../entities/seller_analytics.dart';
import '../../marketplace/domain/entities/recommendation.dart';

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
}