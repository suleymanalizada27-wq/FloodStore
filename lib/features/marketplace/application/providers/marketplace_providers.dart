import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/order.dart';
import '../../data/repositories/firestore_product_repository.dart';
import '../../data/repositories/firestore_cart_repository.dart';
import '../../data/repositories/firestore_order_repository.dart';
import '../../data/repositories/firestore_user_repository.dart';
import '../../data/sources/firestore_product_data_source.dart';
import '../state/product_list_notifier.dart';

final firestoreProductDataSourceProvider = Provider<FirestoreProductDataSource>((ref) {
  return FirestoreProductDataSource();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dataSource = ref.read(firestoreProductDataSourceProvider);
  return FirestoreProductRepository(dataSource: dataSource);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return FirestoreCartRepository();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirestoreOrderRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirestoreUserRepository();
});

final productListProvider = StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return ProductListNotifier(repository);
});

final cartProvider = StreamProvider<Cart?>((ref) {
  return const Stream.empty();
});

final currentUserIdProvider = StateProvider<String?>((ref) => 'demo-user-id');

final cartForUserProvider = FutureProvider.family<Cart?, String>((ref, userId) {
  return ref.watch(cartRepositoryProvider).getCart(userId);
});

final orderForIdProvider = FutureProvider.family<Order?, String>((ref, orderId) {
  return ref.watch(orderRepositoryProvider).getOrderById(orderId);
});