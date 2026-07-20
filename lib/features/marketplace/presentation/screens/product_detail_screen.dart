import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../domain/entities/product.dart';

/// Detailed view for a single product.
class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Ürün'), backgroundColor: AppColors.background),
            body: const Center(child: Text('Ürün bulunamadı')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(product.base.title),
            backgroundColor: AppColors.background,
          ),
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image carousel (placeholder for now)
                  SizedBox(
                    height: 250,
                    child: product.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.images.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.image, size: 80, color: AppColors.textTertiary),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(product.base.title, style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(product.base.description, style: AppTextStyles.body(size: 14)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Marka: ${product.base.brand}', style: AppTextStyles.body(size: 14)),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Text('\$${(product.pricing.basePrice / 100).toStringAsFixed(2)}',
                          style: AppTextStyles.titleLarge?.copyWith(color: AppColors.primary)),
                      if (product.pricing.compareAtPrice != null && product.pricing.compareAtPrice! > 0) ...[
                        const SizedBox(width: 8),
                        Text('\$${(product.pricing.compareAtPrice! / 100).toStringAsFixed(2)}',
                            style: AppTextStyles.body(size: 14, color: AppColors.textTertiary)
                                ?.copyWith(decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PremiumButton(
                    label: 'Sepete Ekle',
                    icon: Icons.add_shopping_cart,
                    onPressed: () {
                      // TODO: implement add‑to‑cart functionality
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Ürün yüklenemedi: $error'))),
    );
  }
}
