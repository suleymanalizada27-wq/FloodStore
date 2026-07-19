import 'package:equatable/equatable.dart';

/// Personalized product recommendation
class Recommendation extends Equatable {
  final String id;
  final String userId;
  final String productId;
  final RecommendationType type;
  final double score; // 0-1 confidence score
  final String reason;
  final Map<String, dynamic> context; // browsing history, purchase history, etc.
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isDismissed;
  final bool isClicked;

  const Recommendation({
    required this.id,
    required this.userId,
    required this.productId,
    required this.type,
    required this.score,
    required this.reason,
    required this.context,
    required this.createdAt,
    this.expiresAt,
    this.isDismissed = false,
    this.isClicked = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        productId,
        type,
        score,
        reason,
        context,
        createdAt,
        expiresAt,
        isDismissed,
        isClicked,
      ];

  Recommendation copyWith({
    String? id,
    String? userId,
    String? productId,
    RecommendationType? type,
    double? score,
    String? reason,
    Map<String, dynamic>? context,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isDismissed,
    bool? isClicked,
  }) {
    return Recommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isDismissed: isDismissed ?? this.isDismissed,
      isClicked: isClicked ?? this.isClicked,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'type': type.name,
      'score': score,
      'reason': reason,
      'context': context,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isDismissed': isDismissed,
      'isClicked': isClicked,
    };
  }

  static Recommendation fromFirestore(Map<String, dynamic> data, String id) {
    return Recommendation(
      id: id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      type: RecommendationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => RecommendationType.personalized,
      ),
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
      reason: data['reason'] ?? '',
      context: Map<String, dynamic>.from(data['context'] ?? {}),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: data['expiresAt'] != null ? DateTime.parse(data['expiresAt']) : null,
      isDismissed: data['isDismissed'] ?? false,
      isClicked: data['isClicked'] ?? false,
    );
  }
}

enum RecommendationType {
  personalized, // Based on user behavior
  similar, // Similar to viewed product
  complementary, // Goes well with purchased product
  trending, // Popular in user's region/category
  newArrival, // New products in favorite categories
  priceDrop, // Price dropped on watched product
  backInStock, // Restocked product user viewed
  bundle, // Frequently bought together
  seasonal, // Seasonal recommendations
  sellerBased, // From followed sellers
}