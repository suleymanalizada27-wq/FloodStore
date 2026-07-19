import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../domain/entities/seller_analytics.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/analytics_repository.dart';

class FirestoreAnalyticsRepository implements AnalyticsRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreAnalyticsRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference _ordersRef() => _firestore.collection('orders');
  fs.CollectionReference _productsRef() => _firestore.collection('products');
  fs.CollectionReference _usersRef() => _firestore.collection('users');
  fs.CollectionReference _adCampaignsRef() => _firestore.collection('ad_campaigns');
  fs.CollectionReference _userRecommendationsRef(String userId) =>
      _usersRef().doc(userId).collection('recommendations');

  // Seller Analytics
  @override
  Future<SellerDashboardData> getSellerDashboard(String sellerId, {DateTimeRange? dateRange}) async {
    final range = dateRange ?? DateTimeRange.last30Days();
    final start = fs.Timestamp.fromDate(range.start);
    final end = fs.Timestamp.fromDate(range.end);

    try {
      final ordersQuery = await _ordersRef()
          .where('sellerId', isEqualTo: sellerId)
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end)
          .get();

      final orders = ordersQuery.docs.map((doc) => Order.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
      
      final productsQuery = await _productsRef()
          .where('sellerId', isEqualTo: sellerId)
          .get();
      final products = productsQuery.docs.map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();

      double totalRevenue = orders.fold(0, (sum, o) => sum + o.totalAmount);
      int totalOrders = orders.length;
      int totalItems = orders.fold(0, (sum, o) => sum + o.items.fold(0, (s, i) => s + i.quantity));
      double avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

      int pendingOrders = orders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.confirmed).length;
      int lowStockProducts = products.where((p) => p.inventory.totalQuantity > 0 && p.inventory.totalQuantity < 10).length;

      final recentRange = DateTimeRange.last7Days();
      final recentStart = fs.Timestamp.fromDate(recentRange.start);
      final dailySalesQuery = await _ordersRef()
          .where('sellerId', isEqualTo: sellerId)
          .where('createdAt', isGreaterThanOrEqualTo: recentStart)
          .get();

      final dailySalesMap = <String, DailySales>{};
      for (final doc in dailySalesQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['createdAt'] as fs.Timestamp?)?.toDate() ?? DateTime.now();
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final revenue = (data['totalAmount'] as num?)?.toDouble() ?? 0;
        final items = (data['items'] as List?)?.fold<int>(0, (s, i) => s + ((i['quantity'] as num?)?.toInt() ?? 0)) ?? 0;

        if (dailySalesMap.containsKey(dateKey)) {
          final existing = dailySalesMap[dateKey]!;
          dailySalesMap[dateKey] = DailySales(
            date: existing.date,
            revenue: existing.revenue + revenue,
            orders: existing.orders + 1,
            unitsSold: existing.unitsSold + items,
            visitors: existing.visitors,
            conversionRate: existing.conversionRate,
          );
        } else {
          dailySalesMap[dateKey] = DailySales(
            date: date,
            revenue: revenue,
            orders: 1,
            unitsSold: items,
            visitors: 0,
            conversionRate: 0,
          );
        }
      }

      final recentSales = dailySalesMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));

      final productSales = <String, Map<String, dynamic>>{};
      for (final order in orders) {
        for (final item in order.items) {
          productSales.putIfAbsent(item.productId, () => {'units': 0, 'revenue': 0.0, 'orders': 0, 'title': item.productTitle, 'image': ''});
          productSales[item.productId]!['units'] = (productSales[item.productId]!['units'] as int) + item.quantity;
          productSales[item.productId]!['revenue'] = (productSales[item.productId]!['revenue'] as double) + item.totalPrice;
          productSales[item.productId]!['orders'] = (productSales[item.productId]!['orders'] as int) + 1;
        }
      }
      final topProducts = productSales.entries
          .map((e) => TopSellingProduct(
                productId: e.key,
                title: e.value['title'] as String,
                imageUrl: e.value['image'] as String,
                unitsSold: e.value['units'] as int,
                revenue: e.value['revenue'] as double,
                ordersCount: e.value['orders'] as int,
                conversionRate: 0,
                averageRating: 0,
              ))
          .toList()
        ..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));
      topProducts.take(10);

      return SellerDashboardData(
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        totalProducts: products.length,
        activeProducts: products.where((p) => p.status == ProductStatus.active).length,
        pendingOrders: pendingOrders,
        lowStockProducts: lowStockProducts,
        conversionRate: 0,
        averageOrderValue: avgOrderValue,
        totalCustomers: 0,
        returningCustomers: 0,
        recentSales: recentSales,
        topProducts: topProducts.take(10).toList(),
        topCategories: [],
      );
    } catch (e) {
      throw Exception('Failed to get seller dashboard: $e');
    }
  }

  @override
  Future<List<TopSellingProduct>> getTopSellingProducts(String sellerId, {int limit = 10, DateTimeRange? dateRange}) async {
    return [];
  }

  @override
  Future<List<CategoryPerformance>> getCategoryPerformance(String sellerId, {DateTimeRange? dateRange}) async {
    return [];
  }

  @override
  Future<List<DailySales>> getDailySales(String sellerId, {required DateTimeRange dateRange}) async {
    return [];
  }

  @override
  Future<SellerAdCampaign> createAdCampaign(SellerAdCampaign campaign) async {
    try {
      final docRef = await _adCampaignsRef().add(campaign.toFirestore());
      return campaign.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create ad campaign: $e');
    }
  }

  @override
  Future<void> updateAdCampaign(SellerAdCampaign campaign) async {
    try {
      await _adCampaignsRef().doc(campaign.id).update(campaign.toFirestore());
    } catch (e) {
      throw Exception('Failed to update ad campaign: $e');
    }
  }

  @override
  Future<void> deleteAdCampaign(String campaignId) async {
    try {
      await _adCampaignsRef().doc(campaignId).delete();
    } catch (e) {
      throw Exception('Failed to delete ad campaign: $e');
    }
  }

  @override
  Future<List<SellerAdCampaign>> getAdCampaigns(String sellerId, {AdCampaignStatus? status}) async {
    try {
      var query = _adCampaignsRef().where('sellerId', isEqualTo: sellerId);
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => SellerAdCampaign.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get ad campaigns: $e');
    }
  }

  @override
  Future<AdMetrics> getAdMetrics(String campaignId, {DateTimeRange? dateRange}) async {
    try {
      final doc = await _adCampaignsRef().doc(campaignId).get();
      if (!doc.exists) throw Exception('Campaign not found');
      final data = doc.data()! as Map<String, dynamic>;
      return AdMetrics.fromFirestore(data['metrics'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get ad metrics: $e');
    }
  }

  @override
  Future<void> updateAdMetrics(String campaignId, AdMetrics metrics) async {
    try {
      await _adCampaignsRef().doc(campaignId).update({'metrics': metrics.toFirestore()});
    } catch (e) {
      throw Exception('Failed to update ad metrics: $e');
    }
  }

  // Recommendations
  @override
  Future<List<Recommendation>> getRecommendationsForUser(String userId, {
    RecommendationType? type,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      var query = _userRecommendationsRef(userId)
          .where('isDismissed', isEqualTo: false)
          .orderBy('score', descending: true)
          .limit(limit);
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      if (lastDocumentId != null) {
        final lastDoc = await _userRecommendationsRef(userId).doc(lastDocumentId).get();
        if (lastDoc.exists) query = query.startAfterDocument(lastDoc);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final expiresAt = data['expiresAt'] != null ? DateTime.parse(data['expiresAt']) : null;
            return expiresAt == null || expiresAt.isAfter(DateTime.now());
          })
          .map((doc) => Recommendation.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  @override
  Future<void> recordRecommendationClick(String userId, String recommendationId) async {
    try {
      await _userRecommendationsRef(userId).doc(recommendationId).update({
        'isClicked': true,
        'clickedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to record click: $e');
    }
  }

  @override
  Future<void> recordRecommendationImpression(String userId, List<String> recommendationIds) async {
    try {
      final batch = _firestore.batch();
      for (final id in recommendationIds) {
        batch.update(_userRecommendationsRef(userId).doc(id), {
          'impressions': fs.FieldValue.increment(1),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to record impressions: $e');
    }
  }

  @override
  Future<void> dismissRecommendation(String userId, String recommendationId) async {
    try {
      await _userRecommendationsRef(userId).doc(recommendationId).update({
        'isDismissed': true,
        'dismissedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to dismiss recommendation: $e');
    }
  }

  @override
  Future<void> generateRecommendationsForUser(String userId) async {
    // Trigger Cloud Function for ML recommendation generation
  }

  // Platform Analytics
  @override
  Future<PlatformAnalytics> getPlatformAnalytics({DateTimeRange? dateRange}) async {
    return PlatformAnalytics(
      totalRevenue: 0,
      totalOrders: 0,
      totalUsers: 0,
      activeSellers: 0,
      totalProducts: 0,
      averageOrderValue: 0,
      conversionRate: 0,
      customerAcquisitionCost: 0,
      lifetimeValue: 0,
      revenueByCategory: {},
      ordersByStatus: {},
      dailySales: [],
      topProducts: [],
      topCategories: [],
    );
  }

  @override
  Future<List<DailySales>> getPlatformDailySales({required DateTimeRange dateRange}) async {
    return [];
  }

  @override
  Future<Map<String, double>> getRevenueByCategory({DateTimeRange? dateRange}) async {
    return {};
  }

  @override
  Future<Map<String, int>> getOrdersByStatus({DateTimeRange? dateRange}) async {
    return {};
  }

  @override
  Future<double> getConversionRate({DateTimeRange? dateRange}) async {
    return 0;
  }

  @override
  Future<int> getActiveUsers({DateTimeRange? dateRange}) async {
    return 0;
  }

  @override
  Future<int> getNewUsers({DateTimeRange? dateRange}) async {
    return 0;
  }

  @override
  Future<Map<String, int>> getUsersBySource({DateTimeRange? dateRange}) async {
    return {};
  }
}