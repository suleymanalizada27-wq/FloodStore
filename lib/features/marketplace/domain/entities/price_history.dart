import 'package:equatable/equatable.dart';

/// Price history entry for a product
class PriceHistoryEntry extends Equatable {
  final String id;
  final String productId;
  final String? variantId;
  final double price;
  final double? originalPrice;
  final PriceChangeReason reason;
  final DateTime recordedAt;
  final String? promotionId;

  const PriceHistoryEntry({
    required this.id,
    required this.productId,
    this.variantId,
    required this.price,
    this.originalPrice,
    required this.reason,
    required this.recordedAt,
    this.promotionId,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        variantId,
        price,
        originalPrice,
        reason,
        recordedAt,
        promotionId,
      ];

  double get discountPercent =>
      originalPrice != null && originalPrice! > 0
          ? ((originalPrice! - price) / originalPrice! * 100).roundToDouble()
          : 0.0;

  bool get isOnSale => originalPrice != null && price < originalPrice!;

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'variantId': variantId,
      'price': price,
      'originalPrice': originalPrice,
      'reason': reason.name,
      'recordedAt': recordedAt.toIso8601String(),
      'promotionId': promotionId,
    };
  }

  static PriceHistoryEntry fromFirestore(Map<String, dynamic> data, String id) {
    return PriceHistoryEntry(
      id: id,
      productId: data['productId'] ?? '',
      variantId: data['variantId'],
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      reason: PriceChangeReason.values.firstWhere(
        (r) => r.name == data['reason'],
        orElse: () => PriceChangeReason.regular,
      ),
      recordedAt: DateTime.parse(data['recordedAt'] ?? DateTime.now().toIso8601String()),
      promotionId: data['promotionId'],
    );
  }
}

enum PriceChangeReason {
  regular,
  sale,
  flashSale,
  coupon,
  clearance,
  seasonal,
  bundle,
  loyalty,
  priceMatch,
  dynamicPricing,
}

/// Aggregated price statistics for a product
class PriceStatistics extends Equatable {
  final String productId;
  final double currentPrice;
  final double lowestPrice;
  final double highestPrice;
  final double averagePrice;
  final DateTime lowestPriceDate;
  final DateTime highestPriceDate;
  final int priceChangesCount;
  final List<PriceHistoryEntry> history;
  final PriceTrend trend;

  const PriceStatistics({
    required this.productId,
    required this.currentPrice,
    required this.lowestPrice,
    required this.highestPrice,
    required this.averagePrice,
    required this.lowestPriceDate,
    required this.highestPriceDate,
    required this.priceChangesCount,
    required this.history,
    required this.trend,
  });

  @override
  List<Object?> get props => [
        productId,
        currentPrice,
        lowestPrice,
        highestPrice,
        averagePrice,
        lowestPriceDate,
        highestPriceDate,
        priceChangesCount,
        history,
        trend,
      ];

  double get savingsPotential => currentPrice - lowestPrice;
  double get savingsPercent => currentPrice > 0 ? (savingsPotential / currentPrice * 100) : 0;
}

enum PriceTrend { rising, falling, stable, volatile }