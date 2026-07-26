import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:floodstore/features/business/domain/entities/business_account.dart';
import 'package:floodstore/features/marketplace/domain/entities/order.dart';
import 'package:floodstore/features/marketplace/domain/entities/product.dart';
import 'package:floodstore/features/business/domain/repositories/seller_repository.dart';

class FirestoreSellerRepository implements SellerRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreSellerRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference _businessAccountsRef() =>
      _firestore.collection('business_accounts');

  fs.CollectionReference _productsRef() => _firestore.collection('products');

  fs.CollectionReference _ordersRef() => _firestore.collection('orders');

  @override
  Future<BusinessAccount?> getBusinessAccount(String userId) async {
    try {
      final doc = await _businessAccountsRef().doc(userId).get();
      if (!doc.exists) return null;
      return BusinessAccount.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get business account: $e');
    }
  }

  @override
  Future<List<Product>> getSellerProducts(String sellerId, {
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      var query = _productsRef()
          .where('sellerId', isEqualTo: sellerId)
          .limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _productsRef().doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Product.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get seller products: $e');
    }
  }

  @override
  Future<List<Order>> getSellerOrders(String sellerId, {
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      var query = _ordersRef()
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _ordersRef().doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Order.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get seller orders: $e');
    }
  }

  @override
  Future<void> updateBusinessAccount(BusinessAccount account) async {
    try {
      await _businessAccountsRef()
          .doc(account.userId)
          .set(account.toFirestore());
    } catch (e) {
      throw Exception('Failed to update business account: $e');
    }
  }
}