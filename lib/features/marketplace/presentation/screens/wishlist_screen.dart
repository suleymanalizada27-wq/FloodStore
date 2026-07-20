import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../domain/entities/wishlist.dart';
import '../../application/providers/marketplace_providers.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('İstek Listesi')),
        body: const Center(child: Text('Lütfen giriş yapın')),
      );
    }

    final wishlistAsync = ref.watch(wishlistProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'İstek Listem',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearWishlistDialog(context, ref, userId),
            tooltip: 'Listeyi Temizle',
          ),
        ],
      ),
      body: wishlistAsync.when(
        data: (wishlist) {
          if (wishlist == null || wishlist.isEmpty) {
            return _buildEmptyWishlist(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: wishlist.items.length,
                  itemBuilder: (context, index) {
                    final item = wishlist.items[index];
                    return _WishlistItemTile(
                      item: item,
                      onRemove: () => ref
                          .read(wishlistRepositoryProvider)
                          .removeItem(userId, item.productId, item.variantId),
                      onMoveToCart: () => _moveToCart(
                          context, ref, userId, item.productId, item.variantId),
                    );
                  },
                ),
              ),
              _WishlistActions(
                wishlist: wishlist,
                onMoveAllToCart: () => _moveAllToCart(context, ref, userId),
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
              Text('İstek listesi yüklenemedi',
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

  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('İstek listeniz boş',
              style: AppTextStyles.textTheme.headlineSmall
                  ?.copyWith(color: AppColors.textSecondary) ??
                  AppTextStyles.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Henüz ürün eklememişsiniz',
              style: AppTextStyles.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textTertiary) ??
                  AppTextStyles.textTheme.bodyMedium),
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

  void _showClearWishlistDialog(
      BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('İstek Listesini Temizle',
            style: AppTextStyles.textTheme.titleLarge),
        content: Text('Tüm ürünler istek listenizden kaldırılacak. Emin misiniz?',
            style: AppTextStyles.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal',
                style: AppTextStyles.textTheme.labelLarge
                    ?.copyWith(color: AppColors.textSecondary) ??
                    AppTextStyles.textTheme.labelLarge),
          ),
          PremiumButton(
            label: 'Temizle',
            onPressed: () {
              ref.read(wishlistRepositoryProvider).clearWishlist(userId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _moveToCart(BuildContext context, WidgetRef ref, String userId,
      String productId, String? variantId) async {
    try {
      // Get the wishlist to get the item's variantAttributes and productTitle
      final wishlist = ref.read(wishlistForUserProvider(userId)).valueOrNull;
      if (wishlist == null) return;

      final item = wishlist.getItem(productId, variantId);
      if (item == null) return;

      // Get the product to get the current price and title (we'll use the product's title and price for consistency)
      final product = await ref.read(productRepositoryProvider).getProductById(productId);
      if (product == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ürün bulunamadı')),
          );
        }
        return;
      }

      // Add to cart with the product's current price and title, and wishlist item's variantAttributes
      await ref.read(cartRepositoryProvider).addItem(
            userId,
            product.id,
            variantId,
            1,
            product.pricing.basePrice,
            product.base.title,
            item.variantAttributes,
          );

      // Remove from wishlist
      await ref
          .read(wishlistRepositoryProvider)
          .removeItem(userId, productId, variantId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün sepete eklendi')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _moveAllToCart(BuildContext context, WidgetRef ref, String userId) async {
    try {
      final wishlist = ref.read(wishlistForUserProvider(userId)).valueOrNull;
      if (wishlist == null || wishlist.isEmpty) return;

      // For each item in the wishlist, get the product details and add to cart
      for (final item in wishlist.items) {
        final product = await ref
            .read(productRepositoryProvider)
            .getProductById(item.productId);
        if (product == null) {
          // Skip this item if product not found
          continue;
        }

        await ref.read(cartRepositoryProvider).addItem(
              userId,
              product.id,
              item.variantId,
              1,
              product.pricing.basePrice,
              product.base.title,
              item.variantAttributes,
            );
      }

      // Clear wishlist after moving all items
      await ref.read(wishlistRepositoryProvider).clearWishlist(userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tüm ürünler sepete eklendi')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}

class _WishlistItemTile extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onRemove;
  final VoidCallback onMoveToCart;

  const _WishlistItemTile({
    required this.item,
    required this.onRemove,
    required this.onMoveToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMoveToCart, // Tap to move to cart (alternative: long press for options)
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 32, color: AppColors.textTertiary),
            ),
          ),
          title: Text(
            item.productTitle,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: item.variantAttributes.isNotEmpty
              ? Text(
                  item.variantAttributes.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join(', '),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              : null,
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onRemove,
                tooltip: 'Kaldır',
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: onMoveToCart,
                tooltip: 'Sepete Ekle',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishlistActions extends StatelessWidget {
  final Wishlist wishlist;
  final VoidCallback onMoveAllToCart;

  const _WishlistActions({
    required this.wishlist,
    required this.onMoveAllToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${wishlist.itemCount} ürün',
                style: AppTextStyles.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Tümünü Sepete Ekle'),
                onPressed: onMoveAllToCart,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // We could add a total price here if we had prices in wishlist items
          // For now, we'll leave it out since wishlist doesn't store prices
        ],
      ),
    );
  }
}