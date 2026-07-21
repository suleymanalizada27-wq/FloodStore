import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:floodstore/features/business/domain/entities/loyalty.dart';
import 'package:floodstore/features/business/domain/repositories/loyalty_repository.dart';

class FirestoreLoyaltyRepository implements LoyaltyRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreLoyaltyRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.DocumentReference _accountRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('loyalty').doc('account');

  fs.CollectionReference _transactionsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('loyalty').doc('account').collection('transactions');

  fs.CollectionReference _tiersRef() => _firestore.collection('loyalty_tiers');

  @override
  Future<LoyaltyAccount?> getAccount(String userId) async {
    try {
      final doc = await _accountRef(userId).get();
      if (!doc.exists) return null;
      return LoyaltyAccount.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get loyalty account: $e');
    }
  }

  @override
  Future<LoyaltyAccount> getOrCreateAccount(String userId) async {
    try {
      final doc = await _accountRef(userId).get();
      if (doc.exists) {
        return LoyaltyAccount.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
      }
      // Create new account with Bronze tier
      final tiers = LoyaltyTier.defaultTiers;
      final bronze = tiers.firstWhere((t) => t.id == 'bronze');
      final account = LoyaltyAccount(
        userId: userId,
        currentPoints: 0,
        lifetimePointsEarned: 0,
        lifetimePointsRedeemed: 0,
        currentTierId: 'bronze',
        tierAchievedAt: DateTime.now(),
        pointsToNextTier: tiers[1].requiredPoints,
      );
      await _accountRef(userId).set(account.toFirestore());
      return account;
    } catch (e) {
      throw Exception('Failed to get or create loyalty account: $e');
    }
  }

  @override
  Future<LoyaltyAccount> addPoints(String userId, int points, {
    required TransactionType type,
    required String description,
    String? referenceId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final account = await getOrCreateAccount(userId);
      final newBalance = account.currentPoints + points;
      final newLifetimeEarned = account.lifetimePointsEarned + points;

      // Get current tier to calculate points to next tier
      final tiers = LoyaltyTier.defaultTiers;
      final currentTierIndex = tiers.indexWhere((t) => t.id == account.currentTierId);
      int pointsToNext = 0;
      if (currentTierIndex != -1 && currentTierIndex < tiers.length - 1) {
        pointsToNext = tiers[currentTierIndex + 1].requiredPoints - newBalance;
      }

      final transaction = PointTransaction(
        id: '',
        userId: userId,
        type: type,
        points: points,
        balanceAfter: newBalance,
        description: description,
        referenceId: referenceId,
        metadata: metadata,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();
      batch.update(_accountRef(userId), {
        'currentPoints': newBalance,
        'lifetimePointsEarned': newLifetimeEarned,
        'pointsToNextTier': pointsToNext > 0 ? pointsToNext : 0,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
      batch.set(_transactionsRef(userId).doc(), transaction.toFirestore());

      await batch.commit();

      // Check for tier upgrade
      await checkTierUpgrade(userId);

      return account.copyWith(
        currentPoints: newBalance,
        lifetimePointsEarned: newLifetimeEarned,
        pointsToNextTier: pointsToNext > 0 ? pointsToNext : 0,
        transactions: [transaction, ...account.transactions],
      );
    } catch (e) {
      throw Exception('Failed to add points: $e');
    }
  }

  @override
  Future<LoyaltyAccount> redeemPoints(String userId, int points, {
    required String description,
    String? referenceId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final account = await getOrCreateAccount(userId);
      if (account.currentPoints < points) {
        throw Exception('Yetersiz puan');
      }

      final newBalance = account.currentPoints - points;
      final newLifetimeRedeemed = account.lifetimePointsRedeemed + points;

      final tiers = LoyaltyTier.defaultTiers;
      final currentTierIndex = tiers.indexWhere((t) => t.id == account.currentTierId);
      int pointsToNext = 0;
      if (currentTierIndex != -1 && currentTierIndex < tiers.length - 1) {
        pointsToNext = tiers[currentTierIndex + 1].requiredPoints - newBalance;
      }

      final transaction = PointTransaction(
        id: '',
        userId: userId,
        type: TransactionType.redemption,
        points: -points,
        balanceAfter: newBalance,
        description: description,
        referenceId: referenceId,
        metadata: metadata,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();
      batch.update(_accountRef(userId), {
        'currentPoints': newBalance,
        'lifetimePointsRedeemed': newLifetimeRedeemed,
        'pointsToNextTier': pointsToNext > 0 ? pointsToNext : 0,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
      batch.set(_transactionsRef(userId).doc(), transaction.toFirestore());

      await batch.commit();

      return account.copyWith(
        currentPoints: newBalance,
        lifetimePointsRedeemed: newLifetimeRedeemed,
        pointsToNextTier: pointsToNext > 0 ? pointsToNext : 0,
        transactions: [transaction, ...account.transactions],
      );
    } catch (e) {
      throw Exception('Failed to redeem points: $e');
    }
  }

  @override
  Future<List<PointTransaction>> getTransactions(String userId, {
    int limit = 50,
    String? lastDocumentId,
    TransactionType? type,
  }) async {
    try {
      var query = _transactionsRef(userId).orderBy('createdAt', descending: true).limit(limit);
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      if (lastDocumentId != null) {
        final lastDoc = await _transactionsRef(userId).doc(lastDocumentId).get();
        if (lastDoc.exists) query = query.startAfterDocument(lastDoc);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => PointTransaction.fromFirestore(doc.data()! as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  @override
  Future<List<LoyaltyTier>> getTiers() async {
    try {
      final snapshot = await _tiersRef().where('isActive', isEqualTo: true).orderBy('requiredPoints').get();
      if (snapshot.docs.isEmpty) {
        return LoyaltyTier.defaultTiers;
      }
      return snapshot.docs.map((doc) => LoyaltyTier.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      // Return default tiers if collection doesn't exist
      return LoyaltyTier.defaultTiers;
    }
  }

  @override
  Future<LoyaltyAccount?> checkTierUpgrade(String userId) async {
    try {
      final account = await getAccount(userId);
      if (account == null) return null;

      final tiers = await getTiers();
      final currentTierIndex = tiers.indexWhere((t) => t.id == account.currentTierId);

      if (currentTierIndex == -1 || currentTierIndex == tiers.length - 1) {
        return account; // Already at max tier
      }

      final nextTier = tiers[currentTierIndex + 1];
      if (account.currentPoints >= nextTier.requiredPoints) {
        // Upgrade!
        final batch = _firestore.batch();
        batch.update(_accountRef(userId), {
          'currentTierId': nextTier.id,
          'tierAchievedAt': fs.FieldValue.serverTimestamp(),
          'pointsToNextTier': currentTierIndex + 1 < tiers.length - 1
              ? tiers[currentTierIndex + 2].requiredPoints - account.currentPoints
              : 0,
        });

        // Add tier upgrade transaction
        final transaction = PointTransaction(
          id: '',
          userId: userId,
          type: TransactionType.tierUpgrade,
          points: 0,
          balanceAfter: account.currentPoints,
          description: '${nextTier.displayName} seviyesine yükseldiniz!',
          referenceId: nextTier.id,
          createdAt: DateTime.now(),
        );
        batch.set(_transactionsRef(userId).doc(), transaction.toFirestore());

        await batch.commit();

        // Send notification about tier upgrade
        // (Would use NotificationRepository here)

        return account.copyWith(
          currentTierId: nextTier.id,
          tierAchievedAt: DateTime.now(),
          pointsToNextTier: currentTierIndex + 1 < tiers.length - 1
              ? tiers[currentTierIndex + 2].requiredPoints - account.currentPoints
              : 0,
        );
      }
      return account;
    } catch (e) {
      throw Exception('Failed to check tier upgrade: $e');
    }
  }

  @override
  Future<void> applyBirthdayBonus(String userId) async {
    try {
      final account = await getOrCreateAccount(userId);
      if (account.lastBirthdayBonusAt != null) {
        final lastBirthday = account.lastBirthdayBonusAt!;
        final now = DateTime.now();
        if (lastBirthday.year == now.year) return; // Already got bonus this year
      }

      final tiers = await getTiers();
      final currentTier = tiers.firstWhere(
        (t) => t.id == account.currentTierId,
        orElse: () => tiers[0],
      );

      if (currentTier.birthdayBonusPoints > 0) {
        await addPoints(userId, currentTier.birthdayBonusPoints.toInt(),
            type: TransactionType.birthday,
            description: '${currentTier.displayName} seviyesi doğum günü bonusu',
            metadata: {'tier': currentTier.id});
      }

      await _accountRef(userId).update({
        'lastBirthdayBonusAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to apply birthday bonus: $e');
    }
  }

  @override
  Future<TierProgress> getTierProgress(String userId) async {
    final account = await getOrCreateAccount(userId);
    final tiers = await getTiers();
    final currentTier = tiers.firstWhere(
      (t) => t.id == account.currentTierId,
      orElse: () => tiers[0],
    );

    LoyaltyTier? nextTier;
    double progress = 1.0;
    int pointsNeeded = 0;

    final currentIndex = tiers.indexWhere((t) => t.id == account.currentTierId);
    if (currentIndex != -1 && currentIndex < tiers.length - 1) {
      nextTier = tiers[currentIndex + 1];
      final totalNeeded = nextTier.requiredPoints - currentTier.requiredPoints;
      final currentProgress = account.currentPoints - currentTier.requiredPoints;
      progress = (currentProgress / totalNeeded).clamp(0.0, 1.0);
      pointsNeeded = nextTier.requiredPoints - account.currentPoints;
    }

    return TierProgress(
      currentTier: currentTier,
      nextTier: nextTier,
      progress: progress,
      pointsNeeded: pointsNeeded,
    );
  }

  @override
  Future<int> expireOldPoints({int daysOld = 365}) async {
    // This should be a Cloud Function/cron job
    // For now, return 0
    return 0;
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('loyalty')
          .where('__name__', isEqualTo: 'account')
          .orderBy('currentPoints', descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        final userId = doc.reference.parent.parent!.id;
        // Get user name from users collection
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userName = userDoc.data()?['displayName'] ?? 'Kullanıcı';
        final userAvatar = userDoc.data()?['photoUrl'];

        entries.add(LeaderboardEntry(
          userId: userId,
          userName: userName,
          userAvatar: userAvatar ?? '',
          points: data['currentPoints'] ?? 0,
          tierId: data['currentTierId'] ?? 'bronze',
          rank: i + 1,
        ));
      }
      return entries;
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }
}