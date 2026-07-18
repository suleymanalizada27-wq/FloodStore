import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/sources/firestore_product_data_source.dart';

/// Provider for the Firestore product data source
final firestoreProductDataSourceProvider =
    Provider<FirestoreProductDataSource>((ref) {
  return FirestoreProductDataSource();
});

/// Provider for the product repository
final productRepositoryProvider =
    Provider<ProductRepository>((ref) {
      final dataSource = ref.read(firestoreProductDataSourceProvider);
      return FirestoreProductRepository(dataSource: dataSource);
    });

// Export the product list notifier provider from state layer
export 'state/product_list_notifier.dart';