import '../entities/loyalty.dart';

abstract class LoyaltyRepository {
  /// Get user's loyalty account
  Future<LoyaltyAccount?> getAccount(String userId);

  /// Get or create loyalty account
  Future<LoyaltyAccount> getOrCreateAccount(String userId);

  /// Add points (earn)
  Future<LoyaltyAccount> addPoints(String userId, int points, {
    required TransactionType type,
    required String description,
    String? referenceId,
    Map<String, dynamic> metadata = const {},
  });

  /// Redeem points
  Future<LoyaltyAccount> redeemPoints(String userId, int points, {
    required String description,
    String? referenceId,
    Map<String, dynamic> metadata = const {},
  });

  /// Get point transactions
  Future<List<PointTransaction>> getTransactions(String userId, {
    int limit = 50,
    String? lastDocumentId,
    TransactionType? type,
  });

  /// Get available tiers
  Future<List<LoyaltyTier>> getTiers();

  /// Check and apply tier upgrade
  Future<LoyaltyAccount?> checkTierUpgrade(String userId);

  /// Apply birthday bonus
  Future<void> applyBirthdayBonus(String userId);

  /// Get tier progress
  Future<TierProgress> getTierProgress(String userId);

  /// Expire old points (run via cron)
  Future<int> expireOldPoints({int daysOld = 365});

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 100});
}