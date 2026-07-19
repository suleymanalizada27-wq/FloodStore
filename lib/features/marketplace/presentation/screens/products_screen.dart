import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';

final _uuid = const Uuid();

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  Future<List<Product>>? _productsFuture;
  static const int _pageSize = 20;
  String? _lastDocumentId;
  bool _isLoadingMore = false;
  List<Product> _products = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeProducts();
  }

  Future<void> _initializeProducts() async {
    final productRepository = ref.read(productRepositoryProvider);

    try {
      final sampleProducts = await productRepository.getProductsByCategory(
        'default',
        limit: 1,
      );

      if (sampleProducts.isEmpty) {
        await _createSampleData();
      }
    } catch (e) {
      await _createSampleData();
    }

    _loadProducts();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _createSampleData() async {
    try {
      final productRepository = ref.read(productRepositoryProvider);

      final defaultCategory = Category(
        id: 'default',
        name: 'Default Category',
        level: 0,
        sortOrder: 0,
        isActive: true,
      );

      try {
        await productRepository.createCategory(defaultCategory);
      } catch (e) {
        // Category might already exist, which is fine
      }

      for (int i = 0; i < 5; i++) {
        final sampleProduct = Product(
          id: _uuid.v4(),
          sellerId: 'demo-seller-id',
          categoryId: 'default',
          secondaryCategories: const [],
          base: ProductBase(
            title: 'Sample Product ${i + 1}',
            description:
                'This is a sample product for demonstration purposes. This is product number $i+1.',
            brand: 'SampleBrand',
            sku:
                'SAMPLE-${_uuid.v4().substring(0, 8).toUpperCase()}-$i',
            weight: 250.0 + (i * 50.0),
            dimensions: ProductDimensions(
              length: 10.0 + (i * 2.0),
              width: 10.0 + (i * 2.0),
              height: 5.0 + (i * 1.0),
            ),
            materials: ['Cotton', 'Polyester'],
            careInstructions: 'Machine wash cold, tumble dry low',
            isDigital: false,
          ),
          metadata: ProductMetadata(
            tags: ['sample', 'demo', 'test', 'product$i'],
            ageRange: null,
            gender: null,
            season: ['all'],
            occasion: ['casual'],
            style: ['modern'],
            color: ['blue', 'white', 'black'][i % 3] == 'blue'
                ? ['blue']
                : ['white', 'black'][i % 3] == 'white'
                    ? ['white']
                    : ['black'],
            pattern: ['solid'],
          ),
          pricing: ProductPricing(
            basePrice: 1999 + (i * 500),
            currency: 'USD',
            compareAtPrice: 2499 + (i * 500),
            taxCode: 'standard',
            shippingTier: 'standard',
          ),
          createdAt: DateTime.now().subtract(Duration(days: i)),
          updatedAt: DateTime.now(),
          status: ProductStatus.active,
        );

        await productRepository.createProduct(sampleProduct);
      }
    } catch (e) {
      debugPrint('Error creating sample data: $e');
    }
  }

  void _loadProducts() {
    final productRepository = ref.read(productRepositoryProvider);
    _productsFuture = productRepository.getProductsByCategory(
      'default',
      limit: _pageSize,
    );
    _productsFuture!.then((products) {
      if (mounted) {
        setState(() {
          _products = products;
          _lastDocumentId = products.isNotEmpty ? products.last.id : null;
        });
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _refreshProducts() async {
    _loadProducts();
  }

  void _loadMoreProducts() {
    if (_isLoadingMore || _lastDocumentId == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    final productRepository = ref.read(productRepositoryProvider);
    productRepository
        .getProductsByCategory(
      'default',
      limit: _pageSize,
      lastDocumentId: _lastDocumentId,
    )
        .then((moreProducts) {
      if (mounted) {
        setState(() {
          _products.addAll(moreProducts);
          _lastDocumentId =
              moreProducts.isNotEmpty ? moreProducts.last.id : null;
          _isLoadingMore = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading more products: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _addSampleProduct() async {
    try {
      final productRepository = ref.read(productRepositoryProvider);

      final sampleProduct = Product(
        id: _uuid.v4(),
        sellerId: 'demo-seller-id',
        categoryId: 'default',
        secondaryCategories: const [],
        base: ProductBase(
          title: 'Sample Product ${DateTime.now().millisecondsSinceEpoch}',
          description: 'This is a sample product for demonstration purposes.',
          brand: 'SampleBrand',
          sku: 'SAMPLE-${_uuid.v4().substring(0, 8).toUpperCase()}',
          weight: 250.0,
          dimensions: const ProductDimensions(
            length: 10.0,
            width: 10.0,
            height: 5.0,
          ),
          materials: ['Cotton', 'Polyester'],
          careInstructions: 'Machine wash cold, tumble dry low',
          isDigital: false,
        ),
        metadata: ProductMetadata(
          tags: ['sample', 'demo', 'test'],
          ageRange: null,
          gender: null,
          season: ['all'],
          occasion: ['casual'],
          style: ['modern'],
          color: ['blue', 'white'],
          pattern: ['solid'],
        ),
        pricing: ProductPricing(
          basePrice: 1999,
          currency: 'USD',
          compareAtPrice: 2499,
          taxCode: 'standard',
          shippingTier: 'standard',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: ProductStatus.active,
      );

      await productRepository.createProduct(sampleProduct);
      _loadProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample product added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding sample product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      final userId = ref.read(currentUserIdProvider) ?? 'demo-user-id';
      final cartRepository = ref.read(cartRepositoryProvider);
      await cartRepository.addItem(
        userId,
        product.id,
        null,
        1,
        product.pricing.basePrice,
        product.base.title,
        {},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.base.title} added to cart!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Products',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          if (bool.fromEnvironment('dart.vm.product') == false)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Sample Product',
              onPressed: _addSampleProduct,
            ),
        ],
      ),
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshProducts,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search,
                            color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Product>>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: AppColors.error),
                            ),
                          );
                        }

                        final products = snapshot.data ?? [];

                        if (products.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.store_outlined,
                                  size: 48,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: TextStyle(
                                      color: AppColors.textTertiary),
                                ),
                                const SizedBox(height: 8),
                                if (bool.fromEnvironment(
                                        'dart.vm.product') ==
                                    false)
                                  ElevatedButton.icon(
                                    onPressed: _addSampleProduct,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Sample Product'),
                                  ),
                              ],
                            ),
                          );
                        }

                        return NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                    scrollInfo.metrics.maxScrollExtent *
                                        0.8 &&
                                !_isLoadingMore) {
                              _loadMoreProducts();
                            }
                            return false;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                product: product,
                                onAddToCart: () => _addToCart(product),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSampleProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Sample'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
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
                    style: AppTextStyles.textTheme.bodyLarge!.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    child: PremiumButton(
                      onPressed: onAddToCart,
                      label: 'Add to Cart',
                      icon: Icons.add_shopping_cart,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}