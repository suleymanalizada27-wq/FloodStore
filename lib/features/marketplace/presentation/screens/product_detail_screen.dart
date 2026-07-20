import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../application/providers/marketplace_providers.dart';

/// Detailed view for a single product.
class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final wishlistRepo = ref.watch(wishlistRepositoryProvider);

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
                                .copyWith(decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: PremiumButton(
                          label: 'Sepete Ekle',
                          icon: Icons.add_shopping_cart,
                          onPressed: () async {
                            final userId = ref.read(currentUserIdProvider);
                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lütfen giriş yapın')),
                              );
                              return;
                            }
                            try {
                              final cartRepo = ref.read(cartRepositoryProvider);
                              await cartRepo.addItem(
                                userId,
                                product.id,
                                null, // variantId - null for now
                                1, // quantity
                                product.pricing.basePrice,
                                product.base.title,
                                {}, // variantAttributes - empty for now
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.base.title} sepete eklendi'),
                                    action: SnackBarAction(
                                      label: 'Sepeti Gör',
                                      onPressed: () => context.push(AppRoutes.cart),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Sepete eklenemedi: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: PremiumButton(
                          label: 'İstek Listesine Ekle',
                          icon: Icons.favorite_border,
                          onPressed: () async {
                            final userId = ref.read(currentUserIdProvider);
                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lütfen giriş yapın')),
                              );
                              return;
                            }
                            try {
                              await wishlistRepo.addItem(
                                userId,
                                product.id,
                                null, // variantId - null for now
                                product.base.title,
                                {}, // variantAttributes - empty for now
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.base.title} istek listesine eklendi'),
                                    action: SnackBarAction(
                                      label: 'Listeyi Gör',
                                      onPressed: () => context.push(AppRoutes.wishlist),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('İstek listesine eklenemedi: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
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