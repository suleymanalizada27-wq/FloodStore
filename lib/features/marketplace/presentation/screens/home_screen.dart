import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../domain/entities/category.dart' as CategoryEntity;
import '../../domain/entities/product.dart';
import '../widgets/category_card.dart';

/// The main marketplace home screen featuring:
/// - Search bar
/// - Featured products section
/// - Categories grid
/// - Trending now section
/// - Flash sale/deals section
/// - Personalized recommendations
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Search functionality will be implemented here
    // For now, we just update the state
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.go('/marketplace/products?search=${query.trim()}');
    }
  }

  void _onCategoryTap(CategoryEntity.Category category) {
    context.go('/marketplace/products?categoryId=${category.id}');
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final userId = currentUserId ?? 'demo-user-id';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => Future.delayed(const Duration(seconds: 1)),
        child: CustomScrollView(
          slivers: [
            // App bar with search
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 100,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover Amazing Products',
                        style: AppTextStyles.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSearchBar(),
                    ],
                  ),
                ),
              ),
            ),

            // Featured products
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Featured Products',
                showSeeAll: true,
                onSeeAll: () => context.go('/marketplace/products?filter=featured'),
                child: _buildFeaturedProducts(),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Categories',
                showSeeAll: true,
                onSeeAll: () => context.go('/categories'),
                child: _buildCategories(),
              ),
            ),

            // Trending now
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Trending Now',
                showSeeAll: true,
                onSeeAll: () => context.go('/marketplace/products?filter=trending'),
                child: _buildTrendingProducts(),
              ),
            ),

            // Flash sale
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Flash Sale',
                showSeeAll: true,
                onSeeAll: () => context.go('/marketplace/products?filter=sale'),
                child: _buildFlashSale(),
              ),
            ),

            // Recommendations
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Recommended for You',
                showSeeAll: true,
                onSeeAll: () => context.go('/recommendations'),
                child: _buildRecommendations(userId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSearchFocused
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode
          ..addListener(() {
            setState(() {
              _isSearchFocused = _searchFocusNode.hasFocus;
            });
          }),
        decoration: InputDecoration(
          hintText: 'Search products, brands, and more',
          hintStyle: AppTextStyles.body(
            size: 14,
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          isDense: true,
        ),
        onSubmitted: _onSearchSubmitted,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    bool showSeeAll = false,
    VoidCallback? onSeeAll,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.titleLarge,
              ),
              if (showSeeAll && onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    'See All',
style: AppTextStyles.body(
                        size: 14,
                        color: AppColors.primary,
                        weight: FontWeight.w600,
                      ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    final featuredAsync = ref.watch(featuredProductsProvider);

    return featuredAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return _buildEmptyState(
            icon: Icons.star_border,
            message: 'No featured products yet',
          );
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                width: 160,
                onTap: () => context.go(
                  '/marketplace/products/${product.id}',
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _buildErrorState(
        message: 'Failed to load featured products',
      ),
    );
  }

  Widget _buildTrendingProducts() {
    final newArrivalsAsync = ref.watch(newArrivalsProvider);

    return newArrivalsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return _buildEmptyState(
            icon: Icons.trending_up,
            message: 'No trending products',
          );
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                width: 160,
                onTap: () => context.go(
                  '/marketplace/products/${product.id}',
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _buildErrorState(
        message: 'Failed to load trending products',
      ),
    );
  }

  Widget _buildFlashSale() {
    final saleProductsAsync = ref.watch(saleProductsProvider);

    return saleProductsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return _buildEmptyState(
            icon: Icons.flash_on,
            message: 'No flash sales currently',
          );
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                width: 160,
                showDiscount: true,
                onTap: () => context.go(
                  '/marketplace/products/${product.id}',
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _buildErrorState(
        message: 'Failed to load flash sales',
      ),
    );
  }

  Widget _buildCategories() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _buildEmptyState(
            icon: Icons.category,
            message: 'No categories available',
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                category: category,
                onTap: () => _onCategoryTap(category),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _buildErrorState(
        message: 'Failed to load categories',
      ),
    );
  }

  Widget _buildRecommendations(String userId) {
    final recommendationsAsync = ref.watch(recommendationsProvider(userId));

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border,
            message: 'No recommendations yet',
          );
        }

        // Placeholder product for recommendations (could be fetched properly later)
        final placeholderProduct = Product(
          id: '',
          sellerId: '',
          categoryId: '',
          secondaryCategories: [],
          base: ProductBase(
            title: 'Recommended',
            description: '',
            brand: '',
            sku: '',
            weight: 0,
            dimensions: ProductDimensions(length: 0, width: 0, height: 0),
            materials: [],
            careInstructions: '',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: [],
            season: [],
            occasion: [],
            style: [],
            color: [],
            pattern: [],
          ),
          pricing: ProductPricing(
            basePrice: 0,
            currency: 'USD',
            taxCode: 'standard',
            shippingTier: 'standard',
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        );

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return ProductCard(
                product: placeholderProduct,
                width: 160,
                onTap: () => context.go('/marketplace/products/${recommendation.productId}'),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _buildErrorState(
        message: 'Failed to load recommendations',
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

// Simple ProductCard widget for use in the home screen
class ProductCard extends ConsumerWidget {
  final Product product;
  final double width;
  final bool showDiscount;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.width = 160,
    this.showDiscount = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.base.title,
                        style: AppTextStyles.textTheme.bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${(product.pricing.basePrice / 100).toStringAsFixed(2)}',
                        style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ) ??
                            const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (showDiscount &&
                          product.pricing.compareAtPrice != null &&
                          product.pricing.compareAtPrice! > 0)
                        Text(
                          '\$${(product.pricing.compareAtPrice! / 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                      const Spacer(),
                      // Add to cart button
                      ElevatedButton(
                        onPressed: () async {
                          final userId = ref.read(currentUserIdProvider);
                          if (userId == null) {
                            // Handle case where user ID is not available
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please log in to add items to cart')),
                            );
                            return;
                          }

                          final cartRepository = ref.read(cartRepositoryProvider);
                          await cartRepository.addItem(
                            userId,
                            product.id,
                            null, // variantId - not used in this simple product card
                            1, // quantity
                            product.pricing.basePrice, // unitPrice
                            product.base.title, // productTitle
                            {}, // variantAttributes - empty map since we don't have variants here
                          );

                            // Show success message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart')),
                              );
                            }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add to Cart'),
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