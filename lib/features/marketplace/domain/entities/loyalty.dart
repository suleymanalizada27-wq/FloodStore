import 'package:equatable/equatable.dart';

/// Loyalty program tier
class LoyaltyTier extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final int requiredPoints;
  final String color; // Hex color
  final String icon; // Icon name
  final List<LoyaltyBenefit> benefits;
  final double pointMultiplier; // Earn points faster
  final int freeShippingThreshold; // Minimum order for free shipping (in cents)
  final double birthdayBonusPoints; // Bonus points on birthday
  final int prioritySupportLevel; // 0=none, 1=email, 2=chat, 3=phone

  const LoyaltyTier({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.requiredPoints,
    required this.color,
    required this.icon,
    required this.benefits,
    this.pointMultiplier = 1.0,
    this.freeShippingThreshold = 0,
    this.birthdayBonusPoints = 0,
    this.prioritySupportLevel = 0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        description,
        requiredPoints,
        color,
        icon,
        benefits,
        pointMultiplier,
        freeShippingThreshold,
        birthdayBonusPoints,
        prioritySupportLevel,
      ];

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'displayName': displayName,
      'description': description,
      'requiredPoints': requiredPoints,
      'color': color,
      'icon': icon,
      'benefits': benefits.map((b) => b.toFirestore()).toList(),
      'pointMultiplier': pointMultiplier,
      'freeShippingThreshold': freeShippingThreshold,
      'birthdayBonusPoints': birthdayBonusPoints,
      'prioritySupportLevel': prioritySupportLevel,
    };
  }

  static LoyaltyTier fromFirestore(Map<String, dynamic> data, String id) {
    return LoyaltyTier(
      id: id,
      name: data['name'] ?? '',
      displayName: data['displayName'] ?? '',
      description: data['description'] ?? '',
      requiredPoints: data['requiredPoints'] ?? 0,
      color: data['color'] ?? '#000000',
      icon: data['icon'] ?? 'star',
      benefits: (data['benefits'] as List?)
              ?.map((b) => LoyaltyBenefit.fromFirestore(b))
              .toList() ??
          [],
      pointMultiplier: (data['pointMultiplier'] as num?)?.toDouble() ?? 1.0,
      freeShippingThreshold: data['freeShippingThreshold'] ?? 0,
      birthdayBonusPoints: (data['birthdayBonusPoints'] as num?)?.toDouble() ?? 0,
      prioritySupportLevel: data['prioritySupportLevel'] ?? 0,
    );
  }

  /// Default tiers for FloodStore
  static List<LoyaltyTier> get defaultTiers => [
        const LoyaltyTier(
          id: 'bronze',
          name: 'bronze',
          displayName: 'Bronze',
          description: 'Başlangıç seviyesi',
          requiredPoints: 0,
          color: '#CD7F32',
          icon: 'workspace_premium',
          benefits: [
            LoyaltyBenefit(type: BenefitType.pointsEarn, value: '1x', description: 'Her \$1 harcamada 1 puan'),
            LoyaltyBenefit(type: BenefitType.earlyAccess, value: '24h', description: 'Kampanyalara 24 saat erken erişim'),
          ],
          pointMultiplier: 1.0,
          freeShippingThreshold: 50000, // \$500
        ),
        const LoyaltyTier(
          id: 'silver',
          name: 'silver',
          displayName: 'Silver',
          description: 'Sadık müşteri',
          requiredPoints: 1000,
          color: '#C0C0C0',
          icon: 'workspace_premium',
          benefits: [
            LoyaltyBenefit(type: BenefitType.pointsEarn, value: '1.25x', description: 'Her \$1 harcamada 1.25 puan'),
            LoyaltyBenefit(type: BenefitType.freeShipping, value: '100', description: '\$100 üzeri ücretsiz kargo'),
            LoyaltyBenefit(type: BenefitType.earlyAccess, value: '48h', description: 'Kampanyalara 48 saat erken erişim'),
            LoyaltyBenefit(type: BenefitType.birthdayBonus, value: '500', description: 'Doğum günü 500 bonus puan'),
          ],
          pointMultiplier: 1.25,
          freeShippingThreshold: 10000, // \$100
          birthdayBonusPoints: 500,
        ),
        const LoyaltyTier(
          id: 'gold',
          name: 'gold',
          displayName: 'Gold',
          description: 'Premium müşteri',
          requiredPoints: 5000,
          color: '#FFD700',
          icon: 'workspace_premium',
          benefits: [
            LoyaltyBenefit(type: BenefitType.pointsEarn, value: '1.5x', description: 'Her \$1 harcamada 1.5 puan'),
            LoyaltyBenefit(type: BenefitType.freeShipping, value: '0', description: 'Tüm siparişlerde ücretsiz kargo'),
            LoyaltyBenefit(type: BenefitType.earlyAccess, value: '72h', description: 'Kampanyalara 72 saat erken erişim'),
            LoyaltyBenefit(type: BenefitType.birthdayBonus, value: '1500', description: 'Doğum günü 1500 bonus puan'),
            LoyaltyBenefit(type: BenefitType.prioritySupport, value: 'chat', description: 'Öncelikli canlı destek'),
            LoyaltyBenefit(type: BenefitType.exclusiveDeals, value: '', description: 'Özel Gold üye indirimleri'),
            LoyaltyBenefit(type: BenefitType.freeReturns, value: '', description: 'Ücretsiz iade hakki'),
          ],
          pointMultiplier: 1.5,
          freeShippingThreshold: 0,
          birthdayBonusPoints: 1500,
          prioritySupportLevel: 2,
        ),
        const LoyaltyTier(
          id: 'platinum',
          name: 'platinum',
          displayName: 'Platinum',
          description: 'VIP müşteri',
          requiredPoints: 20000,
          color: '#E5E4E2',
          icon: 'diamond',
          benefits: [
            LoyaltyBenefit(type: BenefitType.pointsEarn, value: '2x', description: 'Her \$1 harcamada 2 puan'),
            LoyaltyBenefit(type: BenefitType.freeShipping, value: '0', description: 'Tüm siparişlerde ücretsiz ekspres kargo'),
            LoyaltyBenefit(type: BenefitType.earlyAccess, value: '1w', description: 'Kampanyalara 1 hafta erken erişim'),
            LoyaltyBenefit(type: BenefitType.birthdayBonus, value: '5000', description: 'Doğum günü 5000 bonus puan'),
            LoyaltyBenefit(type: BenefitType.prioritySupport, value: 'phone', description: 'Öncelikli telefon desteği'),
            LoyaltyBenefit(type: BenefitType.exclusiveDeals, value: '', description: 'Özel Platinum indirimleri'),
            LoyaltyBenefit(type: BenefitType.freeReturns, value: '', description: 'Sınırsız ücretsiz iade'),
            LoyaltyBenefit(type: BenefitType.personalShopper, value: '', description: 'Kişisel alışveriş asistanı'),
            LoyaltyBenefit(type: BenefitType.anniversaryGift, value: '', description: 'Yıldönümü hediyesi'),
          ],
          pointMultiplier: 2.0,
          freeShippingThreshold: 0,
          birthdayBonusPoints: 5000,
          prioritySupportLevel: 3,
        ),
        const LoyaltyTier(
          id: 'diamond',
          name: 'diamond',
          displayName: 'Diamond',
          description: 'Elite müşteri - Sadece davet ile',
          requiredPoints: 100000,
          color: '#B9F2FF',
          icon: 'diamond',
          benefits: [
            LoyaltyBenefit(type: BenefitType.pointsEarn, value: '3x', description: 'Her \$1 harcamada 3 puan'),
            LoyaltyBenefit(type: BenefitType.freeShipping, value: '0', description: 'Ücretsiz same-day delivery'),
            LoyaltyBenefit(type: BenefitType.earlyAccess, value: 'unlimited', description: 'Sınırsız erken erişim'),
            LoyaltyBenefit(type: BenefitType.birthdayBonus, value: '20000', description: 'Doğum günü 20000 bonus puan'),
            LoyaltyBenefit(type: BenefitType.prioritySupport, value: 'dedicated', description: 'Özel müşteri temsilcisi'),
            LoyaltyBenefit(type: BenefitType.exclusiveDeals, value: '', description: 'Özel Diamond fiyatları'),
            LoyaltyBenefit(type: BenefitType.freeReturns, value: '', description: 'Sınırsız ücretsiz iade + kurye gelip alır'),
            LoyaltyBenefit(type: BenefitType.personalShopper, value: '', description: '7/24 kişisel asistan'),
            LoyaltyBenefit(type: BenefitType.anniversaryGift, value: 'premium', description: 'Lüks yıldönümü hediyesi'),
            LoyaltyBenefit(type: BenefitType.vipEvents, value: '', description: 'Özel etkinlik davetleri'),
            LoyaltyBenefit(type: BenefitType.concierge, value: '', description: 'Kişisel konseyer hizmeti'),
          ],
          pointMultiplier: 3.0,
          freeShippingThreshold: 0,
          birthdayBonusPoints: 20000,
          prioritySupportLevel: 3,
        ),
      ];
}

class LoyaltyBenefit extends Equatable {
  final BenefitType type;
  final String value;
  final String description;

  const LoyaltyBenefit({
    required this.type,
    required this.value,
    required this.description,
  });

  @override
  List<Object?> get props => [type, value, description];

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'value': value,
      'description': description,
    };
  }

  static LoyaltyBenefit fromFirestore(Map<String, dynamic> data) {
    return LoyaltyBenefit(
      type: BenefitType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => BenefitType.pointsEarn,
      ),
      value: data['value'] ?? '',
      description: data['description'] ?? '',
    );
  }
}

enum BenefitType {
  pointsEarn,
  freeShipping,
  earlyAccess,
  birthdayBonus,
  prioritySupport,
  exclusiveDeals,
  freeReturns,
  personalShopper,
  anniversaryGift,
  vipEvents,
  concierge,
}

/// User's loyalty account
class LoyaltyAccount extends Equatable {
  final String userId;
  final int currentPoints;
  final int lifetimePointsEarned;
  final int lifetimePointsRedeemed;
  final String currentTierId;
  final DateTime tierAchievedAt;
  final DateTime? nextTierProgressAt;
  final int pointsToNextTier;
  final List<PointTransaction> transactions;
  final DateTime? lastBirthdayBonusAt;
  final Map<String, dynamic> metadata;

  const LoyaltyAccount({
    required this.userId,
    this.currentPoints = 0,
    this.lifetimePointsEarned = 0,
    this.lifetimePointsRedeemed = 0,
    this.currentTierId = 'bronze',
    required this.tierAchievedAt,
    this.nextTierProgressAt,
    this.pointsToNextTier = 0,
    this.transactions = const [],
    this.lastBirthdayBonusAt,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        userId,
        currentPoints,
        lifetimePointsEarned,
        lifetimePointsRedeemed,
        currentTierId,
        tierAchievedAt,
        nextTierProgressAt,
        pointsToNextTier,
        transactions,
        lastBirthdayBonusAt,
        metadata,
      ];

  LoyaltyAccount copyWith({
    String? userId,
    int? currentPoints,
    int? lifetimePointsEarned,
    int? lifetimePointsRedeemed,
    String? currentTierId,
    DateTime? tierAchievedAt,
    DateTime? nextTierProgressAt,
    int? pointsToNextTier,
    List<PointTransaction>? transactions,
    DateTime? lastBirthdayBonusAt,
    Map<String, dynamic>? metadata,
  }) {
    return LoyaltyAccount(
      userId: userId ?? this.userId,
      currentPoints: currentPoints ?? this.currentPoints,
      lifetimePointsEarned: lifetimePointsEarned ?? this.lifetimePointsEarned,
      lifetimePointsRedeemed: lifetimePointsRedeemed ?? this.lifetimePointsRedeemed,
      currentTierId: currentTierId ?? this.currentTierId,
      tierAchievedAt: tierAchievedAt ?? this.tierAchievedAt,
      nextTierProgressAt: nextTierProgressAt ?? this.nextTierProgressAt,
      pointsToNextTier: pointsToNextTier ?? this.pointsToNextTier,
      transactions: transactions ?? this.transactions,
      lastBirthdayBonusAt: lastBirthdayBonusAt ?? this.lastBirthdayBonusAt,
      metadata: metadata ?? this.metadata,
    );
  }

  double get tierProgress {
    final tiers = LoyaltyTier.defaultTiers;
    final currentIndex = tiers.indexWhere((t) => t.id == currentTierId);
    if (currentIndex == -1 || currentIndex == tiers.length - 1) return 1.0;
    final nextTier = tiers[currentIndex + 1];
    final currentTier = tiers[currentIndex];
    final progress = (currentPoints - currentTier.requiredPoints) / (nextTier.requiredPoints - currentTier.requiredPoints);
    return progress.clamp(0.0, 1.0);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'currentPoints': currentPoints,
      'lifetimePointsEarned': lifetimePointsEarned,
      'lifetimePointsRedeemed': lifetimePointsRedeemed,
      'currentTierId': currentTierId,
      'tierAchievedAt': tierAchievedAt.toIso8601String(),
      'nextTierProgressAt': nextTierProgressAt?.toIso8601String(),
      'pointsToNextTier': pointsToNextTier,
      'transactions': transactions.map((t) => t.toFirestore()).toList(),
      'lastBirthdayBonusAt': lastBirthdayBonusAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  static LoyaltyAccount fromFirestore(Map<String, dynamic> data, String id) {
    return LoyaltyAccount(
      userId: data['userId'] ?? '',
      currentPoints: data['currentPoints'] ?? 0,
      lifetimePointsEarned: data['lifetimePointsEarned'] ?? 0,
      lifetimePointsRedeemed: data['lifetimePointsRedeemed'] ?? 0,
      currentTierId: data['currentTierId'] ?? 'bronze',
      tierAchievedAt: DateTime.parse(data['tierAchievedAt'] ?? DateTime.now().toIso8601String()),
      nextTierProgressAt: data['nextTierProgressAt'] != null ? DateTime.parse(data['nextTierProgressAt']) : null,
      pointsToNextTier: data['pointsToNextTier'] ?? 0,
      transactions: (data['transactions'] as List?)
              ?.map((t) => PointTransaction.fromFirestore(t))
              .toList() ??
          [],
      lastBirthdayBonusAt: data['lastBirthdayBonusAt'] != null ? DateTime.parse(data['lastBirthdayBonusAt']) : null,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }
}

/// Point transaction record
class PointTransaction extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final int points; // Positive for earn, negative for redeem
  final int balanceAfter;
  final String description;
  final String? referenceId; // Order ID, Review ID, etc.
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.balanceAfter,
    required this.description,
    this.referenceId,
    this.metadata = const {},
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        points,
        balanceAfter,
        description,
        referenceId,
        metadata,
        createdAt,
      ];

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'points': points,
      'balanceAfter': balanceAfter,
      'description': description,
      'referenceId': referenceId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static PointTransaction fromFirestore(Map<String, dynamic> data) {
    return PointTransaction(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      type: TransactionType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => TransactionType.purchase,
      ),
      points: data['points'] ?? 0,
      balanceAfter: data['balanceAfter'] ?? 0,
      description: data['description'] ?? '',
      referenceId: data['referenceId'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum TransactionType {
  purchase, // Points earned from purchase
  review, // Points for writing review
  photoReview, // Bonus for photo review
  videoReview, // Bonus for video review
  referral, // Referral bonus
  birthday, // Birthday bonus
  signup, // Welcome bonus
  socialShare, // Sharing product
  wishlistAdd, // Adding to wishlist
  redemption, // Points redeemed for discount
  expiration, // Points expired
  adjustment, // Manual adjustment
  tierUpgrade, // Tier upgrade bonus
  loyaltyBonus, // Loyalty program bonus
}

/// Tier progress information
class TierProgress extends Equatable {
  final LoyaltyTier currentTier;
  final LoyaltyTier? nextTier;
  final double progress; // 0-1
  final int pointsNeeded;

  const TierProgress({
    required this.currentTier,
    this.nextTier,
    required this.progress,
    required this.pointsNeeded,
  });

  @override
  List<Object?> get props => [currentTier, nextTier, progress, pointsNeeded];
}

/// Leaderboard entry
class LeaderboardEntry extends Equatable {
  final String userId;
  final String userName;
  final String userAvatar;
  final int points;
  final String tierId;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.points,
    required this.tierId,
    required this.rank,
  });

  @override
  List<Object?> get props => [userId, userName, userAvatar, points, tierId, rank];
}