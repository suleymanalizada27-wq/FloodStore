import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

class ProductSearchParams extends Equatable {
  final String query;
  final List<String>? categoryIds;
  final List<String>? brandIds;
  final double? minPrice;
  final double? maxPrice;
  final ProductSortField? sortField;
  final bool sortDescending;
  final bool inStockOnly;
  final bool freeShippingOnly;
  final double? ratingFilter;

  const ProductSearchParams({
    this.query = '',
    this.categoryIds,
    this.brandIds,
    this.minPrice,
    this.maxPrice,
    this.sortField,
    this.sortDescending = true,
    this.inStockOnly = false,
    this.freeShippingOnly = false,
    this.ratingFilter,
  });

  @override
  List<Object?> get props => [
        query,
        categoryIds,
        brandIds,
        minPrice,
        maxPrice,
        sortField,
        sortDescending,
        inStockOnly,
        freeShippingOnly,
        ratingFilter,
      ];

  ProductSearchParams copyWith({
    String? query,
    List<String>? categoryIds,
    List<String>? brandIds,
    double? minPrice,
    double? maxPrice,
    ProductSortField? sortField,
    bool? sortDescending,
    bool? inStockOnly,
    bool? freeShippingOnly,
    double? ratingFilter,
  }) {
    return ProductSearchParams(
      query: query ?? this.query,
      categoryIds: categoryIds ?? this.categoryIds,
      brandIds: brandIds ?? this.brandIds,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortField: sortField ?? this.sortField,
      sortDescending: sortDescending ?? this.sortDescending,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      freeShippingOnly: freeShippingOnly ?? this.freeShippingOnly,
      ratingFilter: ratingFilter ?? this.ratingFilter,
    );
  }
}
