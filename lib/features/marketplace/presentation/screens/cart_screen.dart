import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../domain/entities/cart.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../domain/entities/coupon.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  String? _couponError;
  String? _appliedCouponCode;
  bool _isApplyingCoupon = false;
  double _discountAmount = 0.0;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    if (_couponController.text.trim().isEmpty) {
      setState(() {
        _couponError = 'Please enter a coupon code';
      });
      return;
    }

    setState(() {
      _isApplyingCoupon = true;
      _couponError = null;
    });

    try {
      final userId = ref.read(currentUserIdProvider)!;
      final cart = await ref.read(cartRepositoryProvider).getCart(userId);

      if (cart == null) {
        throw Exception('Cart not found');
      }

      // Validate coupon using the coupon repository
      final couponRepo = ref.read(couponRepositoryProvider);
      final validationResult = await couponRepo.validateCoupon(
        code: _couponController.text.trim(),
        userId: userId,
        productIds: cart.items.map((item) => item.productId).toList(),
        categoryIds: [], // We don't have category IDs in cart items easily
        subtotal: cart.subtotalAmount,
      );

      if (validationResult.isValid) {
        // Apply coupon to cart
        await ref.read(cartRepositoryProvider).applyCoupon(userId, _couponController.text.trim());
        setState(() {
          _appliedCouponCode = _couponController.text.trim();
          _discountAmount = validationResult.discountAmount;
          _couponError = null;
        });
      } else {
        setState(() {
          _couponError = validationResult.errorMessage;
          _appliedCouponCode = null;
          _discountAmount = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        _couponError = 'Failed to apply coupon: $e';
        _appliedCouponCode = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isApplyingCoupon = false);
      }
    }
  }

  Future<void> _removeCoupon() async {
    try {
      final userId = ref.read(currentUserIdProvider)!;
      await ref.read(cartRepositoryProvider).removeCoupon(userId);
      setState(() {
        _appliedCouponCode = null;
        _couponController.clear();
        _couponError = null;
        _discountAmount = 0.0;
      });
    } catch (e) {
      setState(() {
        _couponError = 'Failed to remove coupon: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final cartAsync = ref.watch(cartProvider(userId!));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sepetim',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearCartDialog(context, userId),
            tooltip: 'Sepeti Temizle',
          ),
        ],
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemTile(
                      item: item,
                      onQuantityChanged: (newQuantity) {
                        if (newQuantity <= 0) {
                          ref.read(cartRepositoryProvider).removeItem(
                              userId, item.productId, item.variantId);
                        } else {
                          ref.read(cartRepositoryProvider).updateItemQuantity(
                              userId,
                              item.productId,
                              item.variantId,
                              newQuantity);
                        }
                      },
                      onRemove: () => ref
                          .read(cartRepositoryProvider)
                          .removeItem(userId, item.productId, item.variantId),
                    );
                  },
                ),
              ),
              _CouponSection(
                couponController: _couponController,
                couponError: _couponError,
                appliedCouponCode: _appliedCouponCode,
                isApplyingCoupon: _isApplyingCoupon,
                onApplyCoupon: _applyCoupon,
                onRemoveCoupon: _removeCoupon,
              ),
              _CartSummary(
                subtotal: cart.subtotalAmount,
                discountAmount: _discountAmount,
                onCheckout: () => context.push(AppRoutes.checkout),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Sepet yüklenemedi',
                  style: AppTextStyles.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(),
                  style: AppTextStyles.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('Sepetiniz boş',
              style: AppTextStyles.textTheme.headlineSmall
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Henüz ürün eklenmemiş',
              style: AppTextStyles.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 24),
          PremiumButton(
            label: 'Alışverişe Başla',
            icon: Icons.shopping_bag_outlined,
            onPressed: () => context.push(AppRoutes.marketplaceProducts),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(
      BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title:
            Text('Sepeti Temizle', style: AppTextStyles.textTheme.titleLarge),
        content: Text('Tüm ürünler sepetenizden kaldırılacak. Emin misiniz?',
            style: AppTextStyles.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal',
                style: AppTextStyles.textTheme.labelLarge
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
          PremiumButton(
            label: 'Temizle',
            onPressed: () {
              ref.read(cartRepositoryProvider).clearCart(userId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 32, color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  style: AppTextStyles.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variantAttributes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.variantAttributes.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join(', '),
                    style: AppTextStyles.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '\$${(item.unitPrice / 100).toStringAsFixed(2)}',
                  style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Column(
            children: [
              Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: () => onQuantityChanged(item.quantity - 1),
                    enabled: item.quantity > 1,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: AppTextStyles.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    onPressed: () => onQuantityChanged(item.quantity + 1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$${(item.totalPrice / 100).toStringAsFixed(2)}',
                style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          // Remove button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: onRemove,
            tooltip: 'Kaldır',
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color:
              enabled ? AppColors.card : AppColors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? AppColors.border
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double subtotal;
  final double discountAmount;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.subtotal,
    required this.discountAmount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    const shipping = 5.00;
    const tax = 0.18;
    final taxAmount = (subtotal - discountAmount) * tax;
    final total = subtotal - discountAmount + shipping + taxAmount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
              label: 'Ara Toplam',
              value: '\$${(subtotal / 100).toStringAsFixed(2)}'),
          if (discountAmount > 0)
            _SummaryRow(
                label: 'İndirim',
                value: '\$-${(discountAmount / 100).toStringAsFixed(2)}'),
          _SummaryRow(
              label: 'Kargo', value: '\$${shipping.toStringAsFixed(2)}'),
          _SummaryRow(
              label: 'KDV (%18)',
              value: '\$${(taxAmount / 100).toStringAsFixed(2)}'),
          const Divider(height: 24, thickness: 1, color: AppColors.border),
          _SummaryRow(
            label: 'TOPLAM',
            value: '\$${(total / 100).toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumButton(
            label: 'Ödemeye Geç',
            icon: Icons.arrow_forward,
            expand: true,
            onPressed: onCheckout,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )
                : AppTextStyles.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  final TextEditingController couponController;
  final String? couponError;
  final String? appliedCouponCode;
  final bool isApplyingCoupon;
  final VoidCallback onApplyCoupon;
  final VoidCallback onRemoveCoupon;

  const _CouponSection({
    required this.couponController,
    required this.couponError,
    required this.appliedCouponCode,
    required this.isApplyingCoupon,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kupon İndirimi',
            style: AppTextStyles.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  decoration: InputDecoration(
                    labelText: 'Kupon Kodu Girin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: couponError,
                    suffixIcon: isApplyingCoupon
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : appliedCouponCode != null
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: onRemoveCoupon,
                              )
                            : null,
                  ),
                  onSubmitted: (_) => onApplyCoupon(),
                ),
              ),
              const SizedBox(width: 8),
              PremiumButton(
                label: 'Uygula',
                loading: isApplyingCoupon,
                onPressed: onApplyCoupon,
                expand: false,
              ),
            ],
          ),
          if (appliedCouponCode != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Uygulanan Kupon:',
                    style: AppTextStyles.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    appliedCouponCode!.toUpperCase(),
                    style: AppTextStyles.textTheme.bodyMedium
                        ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
