import '../entities/coupon.dart';

abstract class CouponRepository {
  /// Get coupon by code
  Future<Coupon?> getCouponByCode(String code);

  /// Get coupon by ID
  Future<Coupon?> getCouponById(String couponId);

  /// Validate and apply coupon to cart
  Future<CouponValidationResult> validateCoupon({
    required String code,
    required String userId,
    required List<String> productIds,
    required List<String> categoryIds,
    required double subtotal,
    String? userTier,
  });

  /// Get user's available coupons
  Future<List<Coupon>> getUserCoupons(String userId, {bool onlyValid = true});

  /// Claim coupon for user
  Future<void> claimCoupon(String userId, String couponId);

  /// Use coupon (increment usage count)
  Future<void> useCoupon(String couponId, String userId);

  /// Create coupon (admin/seller)
  Future<String> createCoupon(Coupon coupon);

  /// Update coupon
  Future<void> updateCoupon(Coupon coupon);

  /// Delete coupon
  Future<void> deleteCoupon(String couponId);

  /// Get all coupons (admin)
  Future<List<Coupon>> getAllCoupons({int limit = 50, String? lastDocumentId});

  /// Get bundles
  Future<List<Bundle>> getActiveBundles({int limit = 20});
  Future<Bundle?> getBundleById(String bundleId);
  Future<String> createBundle(Bundle bundle);
  Future<void> updateBundle(Bundle bundle);
  Future<void> deleteBundle(String bundleId);
}

class CouponValidationResult {
  final bool isValid;
  final Coupon? coupon;
  final double discountAmount;
  final String? errorMessage;
  final List<String> applicableProductIds;

  const CouponValidationResult({
    required this.isValid,
    this.coupon,
    this.discountAmount = 0,
    this.errorMessage,
    this.applicableProductIds = const [],
  });

  factory CouponValidationResult.valid({
    required Coupon coupon,
    required double discountAmount,
    required List<String> applicableProductIds,
  }) = _ValidCouponResult;

  factory CouponValidationResult.invalid(String errorMessage) = _InvalidCouponResult;
}

class _ValidCouponResult extends CouponValidationResult {
  const _ValidCouponResult({
    required Coupon coupon,
    required double discountAmount,
    required List<String> applicableProductIds,
  }) : super(isValid: true, coupon: coupon, discountAmount: discountAmount, applicableProductIds: applicableProductIds);
}

class _InvalidCouponResult extends CouponValidationResult {
  const _InvalidCouponResult(String errorMessage) : super(isValid: false, errorMessage: errorMessage);
}