import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../data/repositories/firestore_product_repository.dart';
import '../../data/repositories/firestore_cart_repository.dart';
import '../../data/sources/firestore_product_data_source.dart';
import '../state/product_list_notifier.dart';

final firestoreProductDataSourceProvider =
    Provider<FirestoreProductDataSource>((ref) {
  return FirestoreProductDataSource();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dataSource = ref.read(firestoreProductDataSourceProvider);
  return FirestoreProductRepository(dataSource: dataSource);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return FirestoreCartRepository();
});

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return ProductListNotifier(repository);
});
