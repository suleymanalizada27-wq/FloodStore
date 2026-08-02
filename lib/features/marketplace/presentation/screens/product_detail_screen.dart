import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../features/chat/presentation/screens/message_thread_screen.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../application/providers/review_providers.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/order.dart';
import '../../../review/domain/entities/review.dart';

/// Detailed view for a single product.
class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final purchaseStatusAsync = ref.watch(purchaseStatusProvider(productId));
    final reviewsAsync = ref.watch(reviewsForProductProvider(productId));

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(
                title: const Text('Ürün'),
                backgroundColor: AppColors.background),
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
                            child: Icon(Icons.image,
                                size: 80, color: AppColors.textTertiary),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(product.base.title, style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(product.base.description,
                      style: AppTextStyles.body(size: 14)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Marka: ${product.base.brand}',
                      style: AppTextStyles.body(size: 14)),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Text(
                          '\$${(product.pricing.basePrice / 100).toStringAsFixed(2)}',
                          style: AppTextStyles.titleLarge
                              ?.copyWith(color: AppColors.primary)),
                      if (product.pricing.compareAtPrice != null &&
                          product.pricing.compareAtPrice! > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                            '\$${(product.pricing.compareAtPrice! / 100).toStringAsFixed(2)}',
                            style: AppTextStyles.body(
                                    size: 14, color: AppColors.textTertiary)
                                .copyWith(
                                    decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Reviews Section
                  _buildReviewsSection(context, ref, productId, reviewsAsync),
                  const SizedBox(height: AppSpacing.lg),
                  // Add to Cart Button
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
                                const SnackBar(
                                    content: Text('Lütfen giriş yapın')),
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
                                    content: Text(
                                        '${product.base.title} sepete eklendi'),
                                    action: SnackBarAction(
                                      label: 'Sepeti Gör',
                                      onPressed: () =>
                                          context.push(AppRoutes.cart),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Hata: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  // Write Review Button (only if purchased)
                  if (purchaseStatusAsync.hasValue &&
                      purchaseStatusAsync.requireValue)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: AppSpacing.md),
                      child: SizedBox(
                        width: double.infinity,
                        child: PremiumButton(
                          label: 'Rəy Yaz',
                          icon: Icons.edit_note,
                          onPressed: () {
                            _showWriteReviewDialog(context, ref, product.id);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildReviewsSection(
      BuildContext context,
      WidgetRef ref,
      String productId,
      AsyncValue<List<Review>> reviewsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Müşteri Rəyleri',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // FutureBuilder for reviews
        reviewsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, __) => Text(
            'Xəta: $error',
            style: TextStyle(color: Colors.red),
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return const Text(
                'Hələ heç bir rəy yoxdur.',
                style: TextStyle(color: Colors.grey),
              );
            }
            // Calculate average rating
            double avgRating = 0;
            if (reviews.isNotEmpty) {
              double totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
              avgRating = totalRating / reviews.length;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Ortalama: $avgRating/5',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Star rating display
                    SizedBox(
                      width: 110,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < avgRating.floor()
                                ? Icons.star
                                : (index < avgRating
                                    ? Icons.star_half
                                    : Icons.star_border),
                            color: Colors.amber,
                            size: 20.0,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // List of reviews
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          review.userId.substring(0, 2).toUpperCase(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Text(
                        review.title ?? 'Başlıqsız',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.comment ?? 'Yorum yoxdur'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Yardımlı: ${review.helpfulPercentage.toStringAsFixed(0)}% ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Tarih: ${review.createdAt.toString()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showWriteReviewDialog(
      BuildContext context,
      WidgetRef ref,
      String productId,
  ) {
    int _rating = 0;
    String _title = '';
    String _comment = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rəy Yazın'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rating selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Title (optional)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Başlık (isteğe bağlı)',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _title = value ?? '',
                ),
                const SizedBox(height: 12),
                // Comment
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Şərhiniz',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  onSaved: (value) => _comment = value ?? '',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İmtina'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate: at least one star and comment not empty
                if (_rating > 0 && _comment.isNotEmpty) {
                  // Create a review object
                  final review = Review(
                    id: '', // Will be generated by Firestore
                    productId: productId,
                    userId: ref.read(currentUserIdProvider)!,
                    rating: _rating.toDouble(),
                    title: _title.isEmpty ? null : _title,
                    comment: _comment.isEmpty ? null : _comment,
                    images: [],
                    isVerifiedPurchase: true, // Since we checked purchase
                    helpfulVotes: 0,
                    totalVotes: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isApproved: true, // Auto-approve for simplicity
                    isFlagged: false,
                  );
                  // Save the review
                  final addReview =
                      ref.read(addReviewProvider(productId));
                  addReview(review).then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rəyiniz yaradıldı')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xəta: $error')),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xahiş edərik, bir reytinq verin və şərh yazın')),
                  );
                }
              },
              child: const Text('Göndər'),
            ),
          ],
        ),
      ),
    );
  }
}