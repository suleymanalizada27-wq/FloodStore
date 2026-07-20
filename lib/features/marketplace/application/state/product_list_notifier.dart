import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductListState {
  final bool isLoading;
  final List<Product> products;
  final String? errorMessage;
  final bool hasReachedEnd;

  const ProductListState({
    this.isLoading = false,
    this.products = const [],
    this.errorMessage,
    this.hasReachedEnd = false,
  });

  ProductListState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? errorMessage,
    bool? hasReachedEnd,
  }) {
    return ProductListState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository _productRepository;

  ProductListNotifier(this._productRepository) : super(const ProductListState());

  Future<void> loadProductsByCategory(String categoryId, {int limit = 20}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final products = await _productRepository.getProductsByCategory(
        categoryId,
        limit: limit,
      );
      state = state.copyWith(
        isLoading: false,
        products: products,
        hasReachedEnd: products.length < limit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMoreProducts(String categoryId, {int limit = 20}) async {
    if (state.isLoading || state.hasReachedEnd) return;
    state = state.copyWith(isLoading: true);
    try {
      final moreProducts = await _productRepository
          .getProductsByCategory(
            categoryId,
            limit: limit + state.products.length,
          )
          .then((products) => products
              .skipWhile((p) => state.products.any((e) => e.id == p.id))
              .take(limit)
              .toList());
      state = state.copyWith(
        isLoading: false,
        products: [...state.products, ...moreProducts],
        hasReachedEnd: moreProducts.length < limit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> searchProducts(String query, {int limit = 20}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final products = await _productRepository.searchProducts(query, limit: limit);
      state = state.copyWith(
        isLoading: false,
        products: products,
        hasReachedEnd: products.length < limit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearProducts() {
    state = const ProductListState();
  }
}
