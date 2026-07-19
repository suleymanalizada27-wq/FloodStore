import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../domain/entities/coupon.dart';
import '../../domain/repositories/coupon_repository.dart';

class FirestoreCouponRepository implements CouponRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreCouponRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference _couponsRef() => _firestore.collection('coupons');
  fs.CollectionReference _bundlesRef() => _firestore.collection('bundles');
  fs.CollectionReference _userCouponsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('coupons');

  @override
  Future<Coupon?> getCouponByCode(String code) async {
    try {
      final query = await _couponsRef().where('code', isEqualTo: code.toUpperCase()).limit(1).get();
      if (query.docs.isEmpty) return null;
      return Coupon.fromFirestore(query.docs.first.data()! as Map<String, dynamic>, query.docs.first.id);
    } catch (e) {
      throw Exception('Failed to get coupon by code: $e');
    }
  }

  @override
  Future<Coupon?> getCouponById(String couponId) async {
    try {
      final doc = await _couponsRef().doc(couponId).get();
      if (!doc.exists) return null;
      return Coupon.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get coupon by ID: $e');
    }
  }

  @override
  Future<CouponValidationResult> validateCoupon({
    required String code,
    required String userId,
    required List<String> productIds,
    required List<String> categoryIds,
    required double subtotal,
    String? userTier,
  }) async {
    final coupon = await getCouponByCode(code);
    if (coupon == null) {
      return CouponValidationResult.invalid('Geçersiz kupon kodu');
    }
    if (!coupon.isValid) {
      return CouponValidationResult.invalid('Kuponun süresi dolmuş');
    }
    if (coupon.hasUsageLimit) {
      return CouponValidationResult.invalid('Kupon kullanım limitine ulaşmış');
    }
    if (!coupon.canApplyToUser(userId, userTier ?? 'bronze')) {
      return CouponValidationResult.invalid('Bu kupon hesabınız için geçerli değil');
    }
    if (!coupon.canApplyToCart(productIds, categoryIds, subtotal)) {
      return CouponValidationResult.invalid('Kupon sepetinizdeki ürünler için geçerli değil');
    }

    // Check per-user usage limit
    final userCouponDoc = await _userCouponsRef(userId).doc(coupon.id).get();
    if (userCouponDoc.exists) {
      final data = userCouponDoc.data()! as Map<String, dynamic>;
      final usedCount = (data['usedCount'] as int?) ?? 0;
      if (usedCount >= coupon.usageLimitPerUser) {
        return CouponValidationResult.invalid('Bu kuponu zaten kullanmışsınız');
      }
    }

    final discount = coupon.calculateDiscount(subtotal);
    return CouponValidationResult.valid(
      coupon: coupon,
      discountAmount: discount,
      applicableProductIds: productIds, // Simplified
    );
  }

  @override
  Future<List<Coupon>> getUserCoupons(String userId, {bool onlyValid = true}) async {
    try {
      var query = _userCouponsRef(userId).limit(50);
      final snapshot = await query.get();
      final coupons = <Coupon>[];
      for (final doc in snapshot.docs) {
        final coupon = await getCouponById(doc.id);
        if (coupon != null && (!onlyValid || coupon.isValid)) {
          coupons.add(coupon);
        }
      }
      return coupons;
    } catch (e) {
      throw Exception('Failed to get user coupons: $e');
    }
  }

  @override
  Future<void> claimCoupon(String userId, String couponId) async {
    try {
      final coupon = await getCouponById(couponId);
      if (coupon == null || !coupon.isValid) {
        throw Exception('Geçersiz kupon');
      }
      await _userCouponsRef(userId).doc(couponId).set({
        'couponId': couponId,
        'claimedAt': fs.FieldValue.serverTimestamp(),
        'usedCount': 0,
      });
    } catch (e) {
      throw Exception('Failed to claim coupon: $e');
    }
  }

  @override
  Future<void> useCoupon(String couponId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      // Increment coupon usage
      batch.update(_couponsRef().doc(couponId), {
        'usedCount': fs.FieldValue.increment(1),
      });

      // Increment user usage
      batch.update(_userCouponsRef(userId).doc(couponId), {
        'usedCount': fs.FieldValue.increment(1),
        'lastUsedAt': fs.FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to use coupon: $e');
    }
  }

  @override
  Future<String> createCoupon(Coupon coupon) async {
    try {
      final docRef = await _couponsRef().add(coupon.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create coupon: $e');
    }
  }

  @override
  Future<void> updateCoupon(Coupon coupon) async {
    try {
      await _couponsRef().doc(coupon.id).update(coupon.toFirestore());
    } catch (e) {
      throw Exception('Failed to update coupon: $e');
    }
  }

  @override
  Future<void> deleteCoupon(String couponId) async {
    try {
      await _couponsRef().doc(couponId).delete();
    } catch (e) {
      throw Exception('Failed to delete coupon: $e');
    }
  }

  @override
  Future<List<Coupon>> getAllCoupons({int limit = 50, String? lastDocumentId}) async {
    try {
      var query = _couponsRef().orderBy('createdAt', descending: true).limit(limit);
      if (lastDocumentId != null) {
        final lastDoc = await _couponsRef().doc(lastDocumentId).get();
        if (lastDoc.exists) query = query.startAfterDocument(lastDoc);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Coupon.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get all coupons: $e');
    }
  }

  @override
  Future<List<Bundle>> getActiveBundles({int limit = 20}) async {
    try {
      final snapshot = await _bundlesRef()
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => Bundle.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get bundles: $e');
    }
  }

  @override
  Future<Bundle?> getBundleById(String bundleId) async {
    try {
      final doc = await _bundlesRef().doc(bundleId).get();
      if (!doc.exists) return null;
      return Bundle.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get bundle: $e');
    }
  }

  @override
  Future<String> createBundle(Bundle bundle) async {
    try {
      final docRef = await _bundlesRef().add(bundle.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create bundle: $e');
    }
  }

  @override
  Future<void> updateBundle(Bundle bundle) async {
    try {
      await _bundlesRef().doc(bundle.id).update(bundle.toFirestore());
    } catch (e) {
      throw Exception('Failed to update bundle: $e');
    }
  }

  @override
  Future<void> deleteBundle(String bundleId) async {
    try {
      await _bundlesRef().doc(bundleId).delete();
    } catch (e) {
      throw Exception('Failed to delete bundle: $e');
    }
  }
}