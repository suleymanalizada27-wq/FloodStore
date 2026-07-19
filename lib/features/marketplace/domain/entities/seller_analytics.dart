import 'package:equatable/equatable.dart';

/// Seller analytics and dashboard data
class SellerAnalytics extends Equatable {
  final String sellerId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final SalesMetrics sales;
  final TrafficMetrics traffic;
  final ConversionMetrics conversion;
  final ProductMetrics products;
  final CustomerMetrics customers;
  final FinancialMetrics financial;
  final List<TopSellingProduct> topProducts;
  final List<CategoryPerformance> categoryPerformance;
  final List<DailySales> dailySales;
  final DateTime generatedAt;

  const SellerAnalytics({
    required this.sellerId,
    required this.periodStart,
    required this.periodEnd,
    required this.sales,
    required this.traffic,
    required this.conversion,
    required this.products,
    required this.customers,
    required this.financial,
    this.topProducts = const [],
    this.categoryPerformance = const [],
    this.dailySales = const [],
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        sellerId,
        periodStart,
        periodEnd,
        sales,
        traffic,
        conversion,
        products,
        customers,
        financial,
        topProducts,
        categoryPerformance,
        dailySales,
        generatedAt,
      ];

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'sales': sales.toFirestore(),
      'traffic': traffic.toFirestore(),
      'conversion': conversion.toFirestore(),
      'products': products.toFirestore(),
      'customers': customers.toFirestore(),
      'financial': financial.toFirestore(),
      'topProducts': topProducts.map((p) => p.toFirestore()).toList(),
      'categoryPerformance': categoryPerformance.map((c) => c.toFirestore()).toList(),
      'dailySales': dailySales.map((d) => d.toFirestore()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  static SellerAnalytics fromFirestore(Map<String, dynamic> data) {
    return SellerAnalytics(
      sellerId: data['sellerId'] ?? '',
      periodStart: DateTime.parse(data['periodStart']),
      periodEnd: DateTime.parse(data['periodEnd']),
      sales: SalesMetrics.fromFirestore(data['sales']),
      traffic: TrafficMetrics.fromFirestore(data['traffic']),
      conversion: ConversionMetrics.fromFirestore(data['conversion']),
      products: ProductMetrics.fromFirestore(data['products']),
      customers: CustomerMetrics.fromFirestore(data['customers']),
      financial: FinancialMetrics.fromFirestore(data['financial']),
      topProducts: (data['topProducts'] as List?)
              ?.map((p) => TopSellingProduct.fromFirestore(p))
              .toList() ??
          [],
      categoryPerformance: (data['categoryPerformance'] as List?)
              ?.map((c) => CategoryPerformance.fromFirestore(c))
              .toList() ??
          [],
      dailySales: (data['dailySales'] as List?)
              ?.map((d) => DailySales.fromFirestore(d))
              .toList() ??
          [],
      generatedAt: DateTime.parse(data['generatedAt']),
    );
  }
}

class SalesMetrics extends Equatable {
  final double totalRevenue;
  final int totalOrders;
  final int totalItemsSold;
  final double averageOrderValue;
  final double revenueGrowth; // Percent vs previous period
  final int ordersGrowth;
  final double grossMargin;
  final double netProfit;

  const SalesMetrics({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalItemsSold,
    required this.averageOrderValue,
    required this.revenueGrowth,
    required this.ordersGrowth,
    required this.grossMargin,
    required this.netProfit,
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        totalOrders,
        totalItemsSold,
        averageOrderValue,
        revenueGrowth,
        ordersGrowth,
        grossMargin,
        netProfit,
      ];

  Map<String, dynamic> toFirestore() => {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'totalItemsSold': totalItemsSold,
        'averageOrderValue': averageOrderValue,
        'revenueGrowth': revenueGrowth,
        'ordersGrowth': ordersGrowth,
        'grossMargin': grossMargin,
        'netProfit': netProfit,
      };

  static SalesMetrics fromFirestore(Map<String, dynamic> data) {
    return SalesMetrics(
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: data['totalOrders'] ?? 0,
      totalItemsSold: data['totalItemsSold'] ?? 0,
      averageOrderValue: (data['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      revenueGrowth: (data['revenueGrowth'] as num?)?.toDouble() ?? 0.0,
      ordersGrowth: data['ordersGrowth'] ?? 0,
      grossMargin: (data['grossMargin'] as num?)?.toDouble() ?? 0.0,
      netProfit: (data['netProfit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TrafficMetrics extends Equatable {
  final int totalVisits;
  final int uniqueVisitors;
  final int pageViews;
  final double bounceRate;
  final double averageSessionDuration;
  final Map<String, int> trafficSources; // direct, search, social, referral, email
  final Map<String, int> deviceBreakdown; // mobile, desktop, tablet
  final Map<String, int> topPages;

  const TrafficMetrics({
    required this.totalVisits,
    required this.uniqueVisitors,
    required this.pageViews,
    required this.bounceRate,
    required this.averageSessionDuration,
    this.trafficSources = const {},
    this.deviceBreakdown = const {},
    this.topPages = const {},
  });

  @override
  List<Object?> get props => [
        totalVisits,
        uniqueVisitors,
        pageViews,
        bounceRate,
        averageSessionDuration,
        trafficSources,
        deviceBreakdown,
        topPages,
      ];

  Map<String, dynamic> toFirestore() => {
        'totalVisits': totalVisits,
        'uniqueVisitors': uniqueVisitors,
        'pageViews': pageViews,
        'bounceRate': bounceRate,
        'averageSessionDuration': averageSessionDuration,
        'trafficSources': trafficSources,
        'deviceBreakdown': deviceBreakdown,
        'topPages': topPages,
      };

  static TrafficMetrics fromFirestore(Map<String, dynamic> data) {
    return TrafficMetrics(
      totalVisits: data['totalVisits'] ?? 0,
      uniqueVisitors: data['uniqueVisitors'] ?? 0,
      pageViews: data['pageViews'] ?? 0,
      bounceRate: (data['bounceRate'] as num?)?.toDouble() ?? 0.0,
      averageSessionDuration: (data['averageSessionDuration'] as num?)?.toDouble() ?? 0.0,
      trafficSources: Map<String, int>.from(data['trafficSources'] ?? {}),
      deviceBreakdown: Map<String, int>.from(data['deviceBreakdown'] ?? {}),
      topPages: Map<String, int>.from(data['topPages'] ?? {}),
    );
  }
}

class ConversionMetrics extends Equatable {
  final double overallConversionRate;
  final double addToCartRate;
  final double checkoutRate;
  final double cartAbandonmentRate;
  final Map<String, double> funnelSteps; // view -> add -> checkout -> purchase
  final int abandonedCarts;
  final double recoveredCartRevenue;

  const ConversionMetrics({
    required this.overallConversionRate,
    required this.addToCartRate,
    required this.checkoutRate,
    required this.cartAbandonmentRate,
    this.funnelSteps = const {},
    this.abandonedCarts = 0,
    this.recoveredCartRevenue = 0.0,
  });

  @override
  List<Object?> get props => [
        overallConversionRate,
        addToCartRate,
        checkoutRate,
        cartAbandonmentRate,
        funnelSteps,
        abandonedCarts,
        recoveredCartRevenue,
      ];

  Map<String, dynamic> toFirestore() => {
        'overallConversionRate': overallConversionRate,
        'addToCartRate': addToCartRate,
        'checkoutRate': checkoutRate,
        'cartAbandonmentRate': cartAbandonmentRate,
        'funnelSteps': funnelSteps,
        'abandonedCarts': abandonedCarts,
        'recoveredCartRevenue': recoveredCartRevenue,
      };

  static ConversionMetrics fromFirestore(Map<String, dynamic> data) {
    return ConversionMetrics(
      overallConversionRate: (data['overallConversionRate'] as num?)?.toDouble() ?? 0.0,
      addToCartRate: (data['addToCartRate'] as num?)?.toDouble() ?? 0.0,
      checkoutRate: (data['checkoutRate'] as num?)?.toDouble() ?? 0.0,
      cartAbandonmentRate: (data['cartAbandonmentRate'] as num?)?.toDouble() ?? 0.0,
      funnelSteps: Map<String, double>.from(data['funnelSteps'] ?? {}),
      abandonedCarts: data['abandonedCarts'] ?? 0,
      recoveredCartRevenue: (data['recoveredCartRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProductMetrics extends Equatable {
  final int totalProducts;
  final int activeProducts;
  final int outOfStockProducts;
  final int lowStockProducts;
  final double averageRating;
  final int totalReviews;
  final int productsWithReviews;
  final Map<String, int> productsByCategory;

  const ProductMetrics({
    required this.totalProducts,
    required this.activeProducts,
    required this.outOfStockProducts,
    required this.lowStockProducts,
    required this.averageRating,
    required this.totalReviews,
    required this.productsWithReviews,
    this.productsByCategory = const {},
  });

  @override
  List<Object?> get props => [
        totalProducts,
        activeProducts,
        outOfStockProducts,
        lowStockProducts,
        averageRating,
        totalReviews,
        productsWithReviews,
        productsByCategory,
      ];

  Map<String, dynamic> toFirestore() => {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'outOfStockProducts': outOfStockProducts,
        'lowStockProducts': lowStockProducts,
        'averageRating': averageRating,
        'totalReviews': totalReviews,
        'productsWithReviews': productsWithReviews,
        'productsByCategory': productsByCategory,
      };

  static ProductMetrics fromFirestore(Map<String, dynamic> data) {
    return ProductMetrics(
      totalProducts: data['totalProducts'] ?? 0,
      activeProducts: data['activeProducts'] ?? 0,
      outOfStockProducts: data['outOfStockProducts'] ?? 0,
      lowStockProducts: data['lowStockProducts'] ?? 0,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: data['totalReviews'] ?? 0,
      productsWithReviews: data['productsWithReviews'] ?? 0,
      productsByCategory: Map<String, int>.from(data['productsByCategory'] ?? {}),
    );
  }
}

class CustomerMetrics extends Equatable {
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final double customerRetentionRate;
  final double customerLifetimeValue;
  final double averageOrdersPerCustomer;
  final Map<String, int> customersByTier; // Loyalty tiers
  final int churnedCustomers;

  const CustomerMetrics({
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.customerRetentionRate,
    required this.customerLifetimeValue,
    required this.averageOrdersPerCustomer,
    this.customersByTier = const {},
    this.churnedCustomers = 0,
  });

  @override
  List<Object?> get props => [
        totalCustomers,
        newCustomers,
        returningCustomers,
        customerRetentionRate,
        customerLifetimeValue,
        averageOrdersPerCustomer,
        customersByTier,
        churnedCustomers,
      ];

  Map<String, dynamic> toFirestore() => {
        'totalCustomers': totalCustomers,
        'newCustomers': newCustomers,
        'returningCustomers': returningCustomers,
        'customerRetentionRate': customerRetentionRate,
        'customerLifetimeValue': customerLifetimeValue,
        'averageOrdersPerCustomer': averageOrdersPerCustomer,
        'customersByTier': customersByTier,
        'churnedCustomers': churnedCustomers,
      };

  static CustomerMetrics fromFirestore(Map<String, dynamic> data) {
    return CustomerMetrics(
      totalCustomers: data['totalCustomers'] ?? 0,
      newCustomers: data['newCustomers'] ?? 0,
      returningCustomers: data['returningCustomers'] ?? 0,
      customerRetentionRate: (data['customerRetentionRate'] as num?)?.toDouble() ?? 0.0,
      customerLifetimeValue: (data['customerLifetimeValue'] as num?)?.toDouble() ?? 0.0,
      averageOrdersPerCustomer: (data['averageOrdersPerCustomer'] as num?)?.toDouble() ?? 0.0,
      customersByTier: Map<String, int>.from(data['customersByTier'] ?? {}),
      churnedCustomers: data['churnedCustomers'] ?? 0,
    );
  }
}

class FinancialMetrics extends Equatable {
  final double totalRevenue;
  final double platformFees;
  final double paymentProcessingFees;
  final double shippingCosts;
  final double refunds;
  final double chargebacks;
  final double netPayout;
  final double pendingPayout;
  final Map<String, double> revenueByCategory;

  const FinancialMetrics({
    required this.totalRevenue,
    required this.platformFees,
    required this.paymentProcessingFees,
    required this.shippingCosts,
    required this.refunds,
    required this.chargebacks,
    required this.netPayout,
    required this.pendingPayout,
    this.revenueByCategory = const {},
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        platformFees,
        paymentProcessingFees,
        shippingCosts,
        refunds,
        chargebacks,
        netPayout,
        pendingPayout,
        revenueByCategory,
      ];

  Map<String, dynamic> toFirestore() => {
        'totalRevenue': totalRevenue,
        'platformFees': platformFees,
        'paymentProcessingFees': paymentProcessingFees,
        'shippingCosts': shippingCosts,
        'refunds': refunds,
        'chargebacks': chargebacks,
        'netPayout': netPayout,
        'pendingPayout': pendingPayout,
        'revenueByCategory': revenueByCategory,
      };

  static FinancialMetrics fromFirestore(Map<String, dynamic> data) {
    return FinancialMetrics(
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      platformFees: (data['platformFees'] as num?)?.toDouble() ?? 0.0,
      paymentProcessingFees: (data['paymentProcessingFees'] as num?)?.toDouble() ?? 0.0,
      shippingCosts: (data['shippingCosts'] as num?)?.toDouble() ?? 0.0,
      refunds: (data['refunds'] as num?)?.toDouble() ?? 0.0,
      chargebacks: (data['chargebacks'] as num?)?.toDouble() ?? 0.0,
      netPayout: (data['netPayout'] as num?)?.toDouble() ?? 0.0,
      pendingPayout: (data['pendingPayout'] as num?)?.toDouble() ?? 0.0,
      revenueByCategory: Map<String, double>.from(data['revenueByCategory'] ?? {}),
    );
  }
}

class TopSellingProduct extends Equatable {
  final String productId;
  final String title;
  final String imageUrl;
  final int unitsSold;
  final double revenue;
  final int ordersCount;
  final double conversionRate;
  final double averageRating;

  const TopSellingProduct({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.unitsSold,
    required this.revenue,
    required this.ordersCount,
    required this.conversionRate,
    required this.averageRating,
  });

  @override
  List<Object?> get props => [productId, title, imageUrl, unitsSold, revenue, ordersCount, conversionRate, averageRating];

  Map<String, dynamic> toFirestore() => {
        'productId': productId,
        'title': title,
        'imageUrl': imageUrl,
        'unitsSold': unitsSold,
        'revenue': revenue,
        'ordersCount': ordersCount,
        'conversionRate': conversionRate,
        'averageRating': averageRating,
      };

  static TopSellingProduct fromFirestore(Map<String, dynamic> data) {
    return TopSellingProduct(
      productId: data['productId'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      unitsSold: data['unitsSold'] ?? 0,
      revenue: (data['revenue'] as num?)?.toDouble() ?? 0.0,
      ordersCount: data['ordersCount'] ?? 0,
      conversionRate: (data['conversionRate'] as num?)?.toDouble() ?? 0.0,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategoryPerformance extends Equatable {
  final String categoryId;
  final String categoryName;
  final double revenue;
  final int orders;
  final int unitsSold;
  final double conversionRate;
  final double averageOrderValue;
  final int activeProducts;

  const CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.revenue,
    required this.orders,
    required this.unitsSold,
    required this.conversionRate,
    required this.averageOrderValue,
    required this.activeProducts,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, revenue, orders, unitsSold, conversionRate, averageOrderValue, activeProducts];

  Map<String, dynamic> toFirestore() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'revenue': revenue,
        'orders': orders,
        'unitsSold': unitsSold,
        'conversionRate': conversionRate,
        'averageOrderValue': averageOrderValue,
        'activeProducts': activeProducts,
      };

  static CategoryPerformance fromFirestore(Map<String, dynamic> data) {
    return CategoryPerformance(
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      revenue: (data['revenue'] as num?)?.toDouble() ?? 0.0,
      orders: data['orders'] ?? 0,
      unitsSold: data['unitsSold'] ?? 0,
      conversionRate: (data['conversionRate'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (data['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      activeProducts: data['activeProducts'] ?? 0,
    );
  }
}

class DailySales extends Equatable {
  final DateTime date;
  final double revenue;
  final int orders;
  final int unitsSold;
  final int visitors;
  final double conversionRate;

  const DailySales({
    required this.date,
    required this.revenue,
    required this.orders,
    required this.unitsSold,
    required this.visitors,
    required this.conversionRate,
  });

  @override
  List<Object?> get props => [date, revenue, orders, unitsSold, visitors, conversionRate];

  Map<String, dynamic> toFirestore() => {
        'date': date.toIso8601String(),
        'revenue': revenue,
        'orders': orders,
        'unitsSold': unitsSold,
        'visitors': visitors,
        'conversionRate': conversionRate,
      };

  static DailySales fromFirestore(Map<String, dynamic> data) {
    return DailySales(
      date: DateTime.parse(data['date']),
      revenue: (data['revenue'] as num?)?.toDouble() ?? 0.0,
      orders: data['orders'] ?? 0,
      unitsSold: data['unitsSold'] ?? 0,
      visitors: data['visitors'] ?? 0,
      conversionRate: (data['conversionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Seller advertisement/campaign
class SellerAdCampaign extends Equatable {
  final String id;
  final String sellerId;
  final String name;
  final AdCampaignType type;
  final AdCampaignStatus status;
  final double dailyBudget;
  final double totalBudget;
  final double spentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> targetProducts;
  final List<String> targetCategories;
  final AdTargeting targeting;
  final AdMetrics metrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerAdCampaign({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.type,
    required this.status,
    required this.dailyBudget,
    required this.totalBudget,
    this.spentAmount = 0.0,
    required this.startDate,
    required this.endDate,
    this.targetProducts = const [],
    this.targetCategories = const [],
    required this.targeting,
    required this.metrics,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        sellerId,
        name,
        type,
        status,
        dailyBudget,
        totalBudget,
        spentAmount,
        startDate,
        endDate,
        targetProducts,
        targetCategories,
        targeting,
        metrics,
        createdAt,
        updatedAt,
      ];

  SellerAdCampaign copyWith({
    String? id,
    String? sellerId,
    String? name,
    AdCampaignType? type,
    AdCampaignStatus? status,
    double? dailyBudget,
    double? totalBudget,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? targetProducts,
    List<String>? targetCategories,
    AdTargeting? targeting,
    AdMetrics? metrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerAdCampaign(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      totalBudget: totalBudget ?? this.totalBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetProducts: targetProducts ?? this.targetProducts,
      targetCategories: targetCategories ?? this.targetCategories,
      targeting: targeting ?? this.targeting,
      metrics: metrics ?? this.metrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'sellerId': sellerId,
        'name': name,
        'type': type.name,
        'status': status.name,
        'dailyBudget': dailyBudget,
        'totalBudget': totalBudget,
        'spentAmount': spentAmount,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'targetProducts': targetProducts,
        'targetCategories': targetCategories,
        'targeting': targeting.toFirestore(),
        'metrics': metrics.toFirestore(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static SellerAdCampaign fromFirestore(Map<String, dynamic> data, String id) {
    return SellerAdCampaign(
      id: id,
      sellerId: data['sellerId'] ?? '',
      name: data['name'] ?? '',
      type: AdCampaignType.values.firstWhere((t) => t.name == data['type'], orElse: () => AdCampaignType.sponsoredProduct),
      status: AdCampaignStatus.values.firstWhere((s) => s.name == data['status'], orElse: () => AdCampaignStatus.draft),
      dailyBudget: (data['dailyBudget'] as num?)?.toDouble() ?? 0.0,
      totalBudget: (data['totalBudget'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (data['spentAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      targetProducts: List<String>.from(data['targetProducts'] ?? []),
      targetCategories: List<String>.from(data['targetCategories'] ?? []),
      targeting: AdTargeting.fromFirestore(data['targeting']),
      metrics: AdMetrics.fromFirestore(data['metrics']),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }
}

enum AdCampaignType {
  sponsoredProduct, // Product appears in search results
  sponsoredBrand, // Brand banner at top
  displayAd, // Banner ads on site
  videoAd, // Video ads
  couponPromotion, // Promote coupon
}

enum AdCampaignStatus {
  draft,
  pendingReview,
  active,
  paused,
  completed,
  rejected,
}

class AdTargeting extends Equatable {
  final List<String> keywords;
  final List<String> negativeKeywords;
  final List<String> locations; // Cities/regions
  final List<int> ageRanges;
  final List<String> genders;
  final List<String> interests;
  final List<String> loyaltyTiers;
  final double bidAmount;

  const AdTargeting({
    this.keywords = const [],
    this.negativeKeywords = const [],
    this.locations = const [],
    this.ageRanges = const [],
    this.genders = const [],
    this.interests = const [],
    this.loyaltyTiers = const [],
    this.bidAmount = 0.0,
  });

  @override
  List<Object?> get props => [keywords, negativeKeywords, locations, ageRanges, genders, interests, loyaltyTiers, bidAmount];

  Map<String, dynamic> toFirestore() => {
        'keywords': keywords,
        'negativeKeywords': negativeKeywords,
        'locations': locations,
        'ageRanges': ageRanges,
        'genders': genders,
        'interests': interests,
        'loyaltyTiers': loyaltyTiers,
        'bidAmount': bidAmount,
      };

  static AdTargeting fromFirestore(Map<String, dynamic> data) {
    return AdTargeting(
      keywords: List<String>.from(data['keywords'] ?? []),
      negativeKeywords: List<String>.from(data['negativeKeywords'] ?? []),
      locations: List<String>.from(data['locations'] ?? []),
      ageRanges: List<int>.from(data['ageRanges'] ?? []),
      genders: List<String>.from(data['genders'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      loyaltyTiers: List<String>.from(data['loyaltyTiers'] ?? []),
      bidAmount: (data['bidAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AdMetrics extends Equatable {
  final int impressions;
  final int clicks;
  final double ctr;
  final double cpc;
  final double cpm;
  final double spent;
  final int orders;
  final double revenue;
  final double roas; // Return on ad spend
  final double acos; // Advertising cost of sales

  const AdMetrics({
    this.impressions = 0,
    this.clicks = 0,
    this.ctr = 0.0,
    this.cpc = 0.0,
    this.cpm = 0.0,
    this.spent = 0.0,
    this.orders = 0,
    this.revenue = 0.0,
    this.roas = 0.0,
    this.acos = 0.0,
  });

  @override
  List<Object?> get props => [impressions, clicks, ctr, cpc, cpm, spent, orders, revenue, roas, acos];

  Map<String, dynamic> toFirestore() => {
        'impressions': impressions,
        'clicks': clicks,
        'ctr': ctr,
        'cpc': cpc,
        'cpm': cpm,
        'spent': spent,
        'orders': orders,
        'revenue': revenue,
        'roas': roas,
        'acos': acos,
      };

  static AdMetrics fromFirestore(Map<String, dynamic> data) {
    return AdMetrics(
      impressions: data['impressions'] ?? 0,
      clicks: data['clicks'] ?? 0,
      ctr: (data['ctr'] as num?)?.toDouble() ?? 0.0,
      cpc: (data['cpc'] as num?)?.toDouble() ?? 0.0,
      cpm: (data['cpm'] as num?)?.toDouble() ?? 0.0,
      spent: (data['spent'] as num?)?.toDouble() ?? 0.0,
      orders: data['orders'] ?? 0,
      revenue: (data['revenue'] as num?)?.toDouble() ?? 0.0,
      roas: (data['roas'] as num?)?.toDouble() ?? 0.0,
      acos: (data['acos'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Seller dashboard summary data
class SellerDashboardData extends Equatable {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int activeProducts;
  final int pendingOrders;
  final int lowStockProducts;
  final double conversionRate;
  final double averageOrderValue;
  final int totalCustomers;
  final int returningCustomers;
  final List<DailySales> recentSales;
  final List<TopSellingProduct> topProducts;
  final List<CategoryPerformance> topCategories;

  const SellerDashboardData({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.activeProducts,
    required this.pendingOrders,
    required this.lowStockProducts,
    required this.conversionRate,
    required this.averageOrderValue,
    required this.totalCustomers,
    required this.returningCustomers,
    required this.recentSales,
    required this.topProducts,
    required this.topCategories,
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        totalOrders,
        totalProducts,
        activeProducts,
        pendingOrders,
        lowStockProducts,
        conversionRate,
        averageOrderValue,
        totalCustomers,
        returningCustomers,
        recentSales,
        topProducts,
        topCategories,
      ];
}

/// Platform-wide analytics (Admin)
class PlatformAnalytics extends Equatable {
  final double totalRevenue;
  final int totalOrders;
  final int totalUsers;
  final int activeSellers;
  final int totalProducts;
  final double averageOrderValue;
  final double conversionRate;
  final double customerAcquisitionCost;
  final double lifetimeValue;
  final Map<String, double> revenueByCategory;
  final Map<String, int> ordersByStatus;
  final List<DailySales> dailySales;
  final List<TopSellingProduct> topProducts;
  final List<CategoryPerformance> topCategories;

  const PlatformAnalytics({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalUsers,
    required this.activeSellers,
    required this.totalProducts,
    required this.averageOrderValue,
    required this.conversionRate,
    required this.customerAcquisitionCost,
    required this.lifetimeValue,
    required this.revenueByCategory,
    required this.ordersByStatus,
    required this.dailySales,
    required this.topProducts,
    required this.topCategories,
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        totalOrders,
        totalUsers,
        activeSellers,
        totalProducts,
        averageOrderValue,
        conversionRate,
        customerAcquisitionCost,
        lifetimeValue,
        revenueByCategory,
        ordersByStatus,
        dailySales,
        topProducts,
        topCategories,
      ];
}

/// Date time range for analytics queries
class DateTimeRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];

  Map<String, dynamic> toFirestore() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  static DateTimeRange last7Days() => DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      );

  static DateTimeRange last30Days() => DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      );

  static DateTimeRange thisMonth() => DateTimeRange(
        start: DateTime(DateTime.now().year, DateTime.now().month, 1),
        end: DateTime.now(),
      );

  static DateTimeRange lastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);
    return DateTimeRange(start: lastMonth, end: endOfLastMonth);
  }
}