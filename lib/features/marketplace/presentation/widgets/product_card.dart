import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../domain/entities/product.dart';

/// Displays a product card with image, title, price, add-to-cart and add-to-wishlist functionality
class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.width = 160,
    this.onTap,
    this.showDiscount = false,
    this.showWishlist = true,
  });

  final Product product;
  final double width;
  final VoidCallback? onTap;
  final bool showDiscount;
  final bool showWishlist;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isAddingToCart = false;
  bool _isAddingToWishlist = false;
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final wishlist = await ref.read(wishlistForUserProvider(userId).future);
    if (wishlist != null && mounted) {
      setState(() {
        _isInWishlist = wishlist.contains(widget.product.id, null);
      });
    }
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      _showSnackBar('Zəhmət olmasa daxil olun', isError: true);
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      final cartRepository = ref.read(cartRepositoryProvider);
      await cartRepository.addItem(
        userId,
        widget.product.id,
        null, // variantId - not used in simple product card
        1, // quantity
        widget.product.pricing.basePrice, // unitPrice
        widget.product.base.title, // productTitle
        {}, // variantAttributes - empty since no variant selection here
      );

      if (mounted) {
        _showSnackBar('${widget.product.base.title} sepətə əlavə edildi');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Sepətə əlavə edilə bilmədi: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isAddingToWishlist) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      _showSnackBar('Zəhmət olmasa daxil olun', isError: true);
      return;
    }

    setState(() => _isAddingToWishlist = true);

    try {
      final wishlistRepository = ref.read(wishlistRepositoryProvider);

      if (_isInWishlist) {
        await wishlistRepository.removeItem(userId, widget.product.id, null);
        if (mounted) {
          setState(() => _isInWishlist = false);
          _showSnackBar('İstek siyahısından silindi');
        }
      } else {
        await wishlistRepository.addItem(
          userId,
          widget.product.id,
          null, // variantId
          widget.product.base.title,
          {}, // variantAttributes
        );
        if (mounted) {
          setState(() => _isInWishlist = true);
          _showSnackBar('İstek siyahısına əlavə edildi');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Xəta baş verdi: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToWishlist = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.width,
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image placeholder with wishlist button overlay
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card.withValues(alpha: 0.2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: AppColors.textTertiary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    if (widget.showWishlist)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isAddingToWishlist ? null : _toggleWishlist,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _isInWishlist
                                    ? AppColors.error.withValues(alpha: 0.9)
                                    : AppColors.card.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: _isInWishlist
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (widget.showDiscount &&
                        widget.product.pricing.compareAtPrice != null &&
                        widget.product.pricing.compareAtPrice! > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${((1 - widget.product.pricing.basePrice / widget.product.pricing.compareAtPrice!) * 100).round()}%',
                            style: AppTextStyles.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product info
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.base.title,
                        style: AppTextStyles.textTheme.bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$${(widget.product.pricing.basePrice / 100).toStringAsFixed(2)}',
                            style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ) ??
                                const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (widget.showDiscount &&
                              widget.product.pricing.compareAtPrice != null &&
                              widget.product.pricing.compareAtPrice! > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '\$${(widget.product.pricing.compareAtPrice! / 100).toStringAsFixed(2)}',
                              style:
                                  AppTextStyles.textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      // Add to cart button
                      SizedBox(
                        height: 32,
                        width: double.infinity,
                        child: PremiumButton(
                          onPressed: _isAddingToCart ? null : _addToCart,
                          loading: _isAddingToCart,
                          label: _isAddingToCart
                              ? 'Əlavə oluyor...'
                              : 'Sepətə Əlavə Et',
                          icon: _isAddingToCart
                              ? Icons.hourglass_empty
                              : Icons.add_shopping_cart,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}