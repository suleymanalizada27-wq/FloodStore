import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../application/state/product_search_state.dart';

/// Advanced search screen with autocomplete, filters, and sort options
class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _query = '';
  String _selectedCategory = 'all';
  ProductSortField _sortField = ProductSortField.relevance;
  bool _sortAscending = false;
  double _minPrice = 0;
  double _maxPrice = 10000;
  final List<String> _selectedBrands = [];
  final List<String> _selectedAttributes = [];
  bool _showFilters = false;
  bool _inStockOnly = false;
  bool _freeShippingOnly = false;
  String? _ratingFilter;

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final searchResultsAsync = ref.watch(productSearchProvider(
      ProductSearchParams(
        query: _query,
        categoryIds: _selectedCategory == 'all' ? null : [_selectedCategory],
        sortField: _sortField,
        sortDescending: !_sortAscending,
        minPrice: _minPrice > 0 ? _minPrice : null,
        maxPrice: _maxPrice < 10000 ? _maxPrice : null,
        inStockOnly: _inStockOnly,
        freeShippingOnly: _freeShippingOnly,
        ratingFilter: _ratingFilter != null ? double.parse(_ratingFilter!) : null,
      ),
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // Filter Bar
            if (_showFilters) _buildFilterChips(categoriesAsync),

            // Results
            Expanded(
              child: searchResultsAsync.when(
                data: (products) => _buildResults(products),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _buildError(error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Ürün, marka veya kategori ara...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textTertiary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                  onSubmitted: (_) => _searchFocus.unfocus(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: _hasActiveFilters ? AppColors.primary : AppColors.textSecondary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _buildActiveFilterChips(),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearAllFilters,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Temizle'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters {
    return _selectedCategory != 'all' ||
        _sortField != ProductSortField.relevance ||
        _minPrice > 0 ||
        _maxPrice < 10000 ||
        _selectedBrands.isNotEmpty ||
        _inStockOnly ||
        _freeShippingOnly ||
        _ratingFilter != null;
  }

  List<Widget> _buildActiveFilterChips() {
    final chips = <Widget>[];
    if (_selectedCategory != 'all') chips.add(_FilterChip(label: 'Kategori: $_selectedCategory', onDeleted: () => setState(() => _selectedCategory = 'all')));
    if (_sortField != ProductSortField.relevance) chips.add(_FilterChip(label: 'Sıralama: ${_sortField.label}', onDeleted: () => setState(() => _sortField = ProductSortField.relevance)));
    if (_minPrice > 0) chips.add(_FilterChip(label: 'Min: \$$_minPrice', onDeleted: () => setState(() => _minPrice = 0)));
    if (_maxPrice < 10000) chips.add(_FilterChip(label: 'Max: \$$_maxPrice', onDeleted: () => setState(() => _maxPrice = 10000)));
    if (_inStockOnly) chips.add(_FilterChip(label: 'Stokta Var', onDeleted: () => setState(() => _inStockOnly = false)));
    if (_freeShippingOnly) chips.add(_FilterChip(label: 'Ücretsiz Kargo', onDeleted: () => setState(() => _freeShippingOnly = false)));
    if (_ratingFilter != null) chips.add(_FilterChip(label: '$_ratingFilter⭐+', onDeleted: () => setState(() => _ratingFilter = null)));
    for (final brand in _selectedBrands) {
      chips.add(_FilterChip(label: brand, onDeleted: () => setState(() => _selectedBrands.remove(brand))));
    }
    return chips;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = 'all';
      _sortField = ProductSortField.relevance;
      _sortAscending = false;
      _minPrice = 0;
      _maxPrice = 10000;
      _selectedBrands.clear();
      _selectedAttributes.clear();
      _inStockOnly = false;
      _freeShippingOnly = false;
      _ratingFilter = null;
    });
  }

  Widget _buildFilterChips(AsyncValue<List<Category>> categoriesAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Category Filter
            _buildCategoryFilter(categoriesAsync),
            const SizedBox(width: AppSpacing.md),
            // Sort Filter
            _buildSortFilter(),
            const SizedBox(width: AppSpacing.md),
            // Price Range
            _buildPriceFilter(),
            const SizedBox(width: AppSpacing.md),
            // Quick Filters
            _buildQuickFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(AsyncValue<List<Category>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        final allCategories = [
          const Category(id: 'all', name: 'Tümü', level: 0, sortOrder: 0, isActive: true),
          ...categories.where((c) => c.level == 0 && c.isActive),
        ];
        return PopupMenuButton<String>(
          initialValue: _selectedCategory,
          onSelected: (value) => setState(() => _selectedCategory = value),
          child: Chip(
            label: Text(_getCategoryName(_selectedCategory, allCategories)),
            avatar: const Icon(Icons.category_outlined, size: 18),
            onDeleted: _selectedCategory != 'all' ? () => setState(() => _selectedCategory = 'all') : null,
            deleteIconColor: AppColors.primary,
          ),
          itemBuilder: (context) => allCategories.map((c) => PopupMenuItem(
            value: c.id,
            child: Text(c.name),
          )).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _getCategoryName(String categoryId, List<Category> categories) {
    if (categoryId == 'all') return 'Tüm Kategoriler';
    return categories.firstWhere((c) => c.id == categoryId, orElse: () => Category(id: '', name: categoryId, level: 0, sortOrder: 0, isActive: true)).name;
  }

  Widget _buildSortFilter() {
    return PopupMenuButton<ProductSortField>(
      initialValue: _sortField,
      onSelected: (value) => setState(() => _sortField = value),
      child: Chip(
        label: Text(_sortField.label),
        avatar: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
        onDeleted: _sortField != ProductSortField.relevance ? () => setState(() => _sortField = ProductSortField.relevance) : null,
        deleteIconColor: AppColors.primary,
      ),
      itemBuilder: (context) => ProductSortField.values.map((field) => PopupMenuItem(
        value: field,
        child: Row(
          children: [
            Icon(field.icon, size: 18),
            const SizedBox(width: 8),
            Text(field.label),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPriceFilter() {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: _minPrice > 0 ? _minPrice.toInt().toString() : '',
              decoration: const InputDecoration(
                labelText: 'Min',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => _minPrice = double.tryParse(v) ?? 0),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: TextFormField(
              initialValue: _maxPrice < 10000 ? _maxPrice.toInt().toString() : '',
              decoration: const InputDecoration(
                labelText: 'Max',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => _maxPrice = double.tryParse(v) ?? 10000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Row(
      children: [
        FilterChip(
          label: const Text('Stokta Var'),
          selected: _inStockOnly,
          onSelected: (v) => setState(() => _inStockOnly = v),
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Ücretsiz Kargo'),
          selected: _freeShippingOnly,
          onSelected: (v) => setState(() => _freeShippingOnly = v),
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (value) => setState(() => _ratingFilter = value == 'none' ? null : value),
          child: Chip(
            label: Text(_ratingFilter != null ? '$_ratingFilter⭐+' : 'Puan'),
            avatar: const Icon(Icons.star_outline, size: 18, color: AppColors.warning),
            onDeleted: _ratingFilter != null ? () => setState(() => _ratingFilter = null) : null,
            deleteIconColor: AppColors.primary,
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'none', child: Text('Tümü')),
            const PopupMenuItem(value: '4.5', child: Text('4.5 ve üzeri')),
            const PopupMenuItem(value: '4.0', child: Text('4.0 ve üzeri')),
            const PopupMenuItem(value: '3.5', child: Text('3.5 ve üzeri')),
          ],
        ),
      ],
    );
  }

  Widget _buildResults(List<Product> products) {
    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent * 0.8) {
          // Load more
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductSearchCard(product: product);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text('Sonuç bulunamadı', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text('Farklı anahtar kelimeler deneyin veya filtreleri genişletin', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.filter_list_off),
            label: const Text('Filtreleri Temizle'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('Arama hatası', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.error)),
          const SizedBox(height: AppSpacing.sm),
          Text(error, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: () => setState(() {}), child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }
}

/// Search card with quick actions
class _ProductSearchCard extends StatelessWidget {
  const _ProductSearchCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.pricing.compareAtPrice != null && product.pricing.compareAtPrice! > product.pricing.basePrice;
    final discountPercent = hasDiscount ? ((product.pricing.compareAtPrice! - product.pricing.basePrice) / product.pricing.compareAtPrice! * 100).round() : 0;

    return InkWell(
      onTap: () {
        // Navigate to product detail
      },
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: product.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : const Center(child: Icon(Icons.image, size: 40, color: AppColors.textTertiary)),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '%$discountPercent',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (product.rating > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.base.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.base.brand,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '\$${(product.pricing.basePrice / 100).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          '\$${(product.pricing.compareAtPrice! / 100).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        product.pricing.freeShipping ? 'Ücretsiz Kargo' : 'Kargo: \$${(product.pricing.shippingCost / 100).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onDeleted,
      deleteIconColor: AppColors.primary,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: AppColors.primary),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}