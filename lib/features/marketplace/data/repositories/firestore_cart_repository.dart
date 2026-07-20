import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import 'package:uuid/uuid.dart';

class FirestoreCartRepository implements CartRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  FirestoreCartRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference _cartRef(String userId) =>
      _firestore.collection('carts').doc(userId);

  @override
  Future<Cart?> getCart(String userId) async {
    try {
      final doc = await _cartRef(userId).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return Cart.fromFirestore(data, doc.id);
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  @override
  Future<void> saveCart(String userId, Cart cart) async {
    try {
      await _cartRef(userId).set(cart.toFirestore());
    } catch (e) {
      throw Exception('Failed to save cart: $e');
    }
  }

  @override
  Future<void> createEmptyCart(String userId) async {
    try {
      final cart = Cart(
        id: userId,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: const [],
      );
      await _cartRef(userId).set(cart.toFirestore());
    } catch (e) {
      throw Exception('Failed to create empty cart: $e');
    }
  }

  @override
  Future<void> addItem(
    String userId,
    String productId,
    String? variantId,
    int quantity,
    double unitPrice,
    String productTitle,
    Map<String, String> variantAttributes,
  ) async {
    try {
      final docRef = _cartRef(userId);
      final doc = await docRef.get();
      final items = doc.exists
          ? List<Map<String, dynamic>>.from(
              (doc.data() as Map<String, dynamic>)['items'] ?? [])
          : <Map<String, dynamic>>[];
      final existingIndex = items.indexWhere(
        (i) => i['productId'] == productId && i['variantId'] == variantId,
      );
      if (existingIndex >= 0) {
        final currentQty = (items[existingIndex]['quantity'] as num?)?.toInt() ?? 0;
        final newQty = currentQty + quantity;
        items[existingIndex] = {
          ...items[existingIndex],
          'quantity': newQty,
          'totalPrice': newQty * unitPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        };
      } else {
        items.add({
          'id': _uuid.v4(),
          'productId': productId,
          'variantId': variantId,
          'quantity': quantity,
          'unitPrice': unitPrice,
          'totalPrice': quantity * unitPrice,
          'productTitle': productTitle,
          'variantAttributes': variantAttributes,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
      await docRef.set({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  @override
  Future<void> updateItemQuantity(
    String userId,
    String productId,
    String? variantId,
    int quantity,
  ) async {
    try {
      if (quantity <= 0) {
        await removeItem(userId, productId, variantId);
        return;
      }
      final docRef = _cartRef(userId);
      final doc = await docRef.get();
      if (!doc.exists) return;
      final items = List<Map<String, dynamic>>.from(
          (doc.data() as Map<String, dynamic>)['items'] ?? []);
      final index = items.indexWhere(
        (i) => i['productId'] == productId && i['variantId'] == variantId,
      );
      if (index < 0) return;
      final unitPrice =
          (items[index]['unitPrice'] as num?)?.toDouble() ?? 0.0;
      items[index] = {
        ...items[index],
        'quantity': quantity,
        'totalPrice': quantity * unitPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await docRef.update({'items': items});
    } catch (e) {
      throw Exception('Failed to update item quantity: $e');
    }
  }

  @override
  Future<void> removeItem(
    String userId,
    String productId,
    String? variantId,
  ) async {
    try {
      final docRef = _cartRef(userId);
      final doc = await docRef.get();
      if (!doc.exists) return;
      final items = List<Map<String, dynamic>>.from(
          (doc.data() as Map<String, dynamic>)['items'] ?? []);
      items.removeWhere(
        (i) => i['productId'] == productId && i['variantId'] == variantId,
      );
      await docRef.update({'items': items});
    } catch (e) {
      throw Exception('Failed to remove item: $e');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      await _cartRef(userId).update({
        'items': [],
        'couponCode': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  @override
  Future<void> saveForLater(String userId, List<String> itemIds) async {
    try {
      final docRef = _cartRef(userId);
      final doc = await docRef.get();
      if (!doc.exists) return;
      final items = List<Map<String, dynamic>>.from(
          (doc.data() as Map<String, dynamic>)['items'] ?? []);
      for (final item in items) {
        if (itemIds.contains(item['id'])) {
          item['isSavedForLater'] = true;
        }
      }
      await docRef.update({'items': items});
    } catch (e) {
      throw Exception('Failed to save for later: $e');
    }
  }

  @override
  Future<void> moveToCart(String userId, List<String> itemIds) async {
    try {
      final docRef = _cartRef(userId);
      final doc = await docRef.get();
      if (!doc.exists) return;
      final items = List<Map<String, dynamic>>.from(
          (doc.data() as Map<String, dynamic>)['items'] ?? []);
      for (final item in items) {
        if (itemIds.contains(item['id'])) {
          item['isSavedForLater'] = false;
        }
      }
      await docRef.update({'items': items});
    } catch (e) {
      throw Exception('Failed to move to cart: $e');
    }
  }

  @override
  Future<void> applyCoupon(String userId, String couponCode) async {
    try {
      await _cartRef(userId).update({
        'couponCode': couponCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to apply coupon: $e');
    }
  }

  @override
  Future<void> removeCoupon(String userId) async {
    try {
      await _cartRef(userId).update({
        'couponCode': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove coupon: $e');
    }
  }

  @override
  Future<Map<String, double>> calculateCartTotals(String userId) async {
    final cart = await getCart(userId);
    if (cart == null) return const {'subtotal': 0, 'total': 0};
    final subtotal = cart.subtotalAmount;
    return {
      'subtotal': subtotal,
      'shipping': 0,
      'tax': 0,
      'discount': 0,
      'total': subtotal,
    };
  }

  @override
  Stream<Cart?> watchCart(String userId) {
    try {
      return _cartRef(userId).snapshots().map((doc) {
        if (!doc.exists) return null;
        final data = doc.data() as Map<String, dynamic>;
        return Cart.fromFirestore(data, doc.id);
      });
    } catch (e) {
      throw Exception('Failed to watch cart: $e');
    }
  }
}