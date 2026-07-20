import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/wishlist.dart';
import '../../domain/repositories/wishlist_repository.dart';

class FirestoreWishlistRepository implements WishlistRepository {
  final FirebaseFirestore _firestore;

  FirestoreWishlistRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference _wishlistRef(String userId) =>
      _firestore.collection('wishlists').doc(userId);

  @override
  Future<Wishlist?> getWishlist(String userId) async {
    try {
      final doc = await _wishlistRef(userId).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return Wishlist.fromFirestore(data, doc.id);
    } catch (e) {
      throw Exception('Failed to get wishlist: $e');
    }
  }

  @override
  Future<void> saveWishlist(String userId, Wishlist wishlist) async {
    try {
      await _wishlistRef(userId).set(wishlist.toFirestore());
    } catch (e) {
      throw Exception('Failed to save wishlist: $e');
    }
  }

  @override
  Future<void> createEmptyWishlist(String userId) async {
    try {
      final wishlist = Wishlist(
        id: userId,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: const [],
      );
      await _wishlistRef(userId).set(wishlist.toFirestore());
    } catch (e) {
      throw Exception('Failed to create empty wishlist: $e');
    }
  }

  @override
  Future<void> addItem(
    String userId,
    String productId,
    String? variantId,
    String productTitle,
    Map<String, String> variantAttributes,
  ) async {
    try {
      final docRef = _wishlistRef(userId);
      final doc = await docRef.get();
      final items = doc.exists
          ? List<Map<String, dynamic>>.from(
              (doc.data() as Map<String, dynamic>)['items'] ?? [])
          : <Map<String, dynamic>>[];
      final existingIndex = items.indexWhere(
        (i) => i['productId'] == productId && i['variantId'] == variantId,
      );
      if (existingIndex >= 0) {
        // Item already exists, no need to add again
        return;
      }
      items.add({
        'id': '${productId}_${variantId ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}',
        'productId': productId,
        'variantId': variantId,
        'addedAt': FieldValue.serverTimestamp(),
        'productTitle': productTitle,
        'variantAttributes': variantAttributes,
      });
      await docRef.update({'items': items});
    } catch (e) {
      throw Exception('Failed to add item to wishlist: $e');
    }
  }

  @override
  Future<void> removeItem(
    String userId,
    String productId,
    String? variantId,
  ) async {
    try {
      final docRef = _wishlistRef(userId);
      final doc = await docRef.get();
      if (!doc.exists) return;
      final items = List<Map<String, dynamic>>.from(
          (doc.data() as Map<String, dynamic>)['items'] ?? []);
      items.removeWhere(
        (i) => i['productId'] == productId && i['variantId'] == variantId,
      );
      await docRef.update({'items': items});
    } catch (e) {
      throw Exception('Failed to remove item from wishlist: $e');
    }
  }

  @override
  Future<void> clearWishlist(String userId) async {
    try {
      await _wishlistRef(userId).update({
        'items': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to clear wishlist: $e');
    }
  }

  @override
  Stream<Wishlist?> watchWishlist(String userId) {
    try {
      return _wishlistRef(userId).snapshots().map((doc) {
        if (!doc.exists) return null;
        final data = doc.data() as Map<String, dynamic>;
        return Wishlist.fromFirestore(data, doc.id);
      });
    } catch (e) {
      throw Exception('Failed to watch wishlist: $e');
    }
  }
}