import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../domain/entities/product.dart';

/// Displays a product card with image, title, price, and add-to-cart functionality
class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.width = 160,
    this.onTap,
  });

  final Product product;
  final double width;
  final VoidCallback? onTap;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isAddedToCart = false;

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
              // Product image placeholder
              Expanded(
                flex: 2,
                child: Container(
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
                      Text(
                        '\$${(widget.product.pricing.basePrice / 100).toStringAsFixed(2)}',
                        style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ) ?? const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Add to cart button
                      SizedBox(
                        height: 32,
                        child: PremiumButton(
                          onPressed: _isAddedToCart
                              ? null
                              : () {
                                  setState(() {
                                    _isAddedToCart = true;
                                  });
                                  // TODO: Implement actual add to cart functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to cart'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                          label: _isAddedToCart ? 'Added' : 'Add to Cart',
                          icon: _isAddedToCart ? Icons.check : Icons.add_shopping_cart,
                          loading: _isAddedToCart,
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