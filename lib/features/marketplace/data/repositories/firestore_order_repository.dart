import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:uuid/uuid.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/order_repository.dart';

class FirestoreOrderRepository implements OrderRepository {
  final fs.FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  FirestoreOrderRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference get _ordersCollection => _firestore.collection('orders');
  fs.CollectionReference _userOrdersCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('orders');
  fs.CollectionReference _sellerOrdersCollection(String sellerId) =>
      _firestore.collection('sellers').doc(sellerId).collection('orders');

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (!doc.exists) return null;
      return Order.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Future<List<Order>> getUserOrders(
    String userId, {
    int limit = 20,
    String? lastDocumentId,
    OrderStatus? statusFilter,
  }) async {
    try {
      fs.Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter.name);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(lastDocumentId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Order.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  @override
  Future<List<Order>> getSellerOrders(
    String sellerId, {
    int limit = 20,
    String? lastDocumentId,
    OrderStatus? statusFilter,
  }) async {
    try {
      fs.Query query = _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter.name);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _firestore
            .collection('sellers')
            .doc(sellerId)
            .collection('orders')
            .doc(lastDocumentId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Order.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get seller orders: $e');
    }
  }

  @override
  Future<String> createOrderFromCart(
    String userId,
    Cart cart, {
    String? couponCode,
    String? notes,
  }) async {
    try {
      if (cart.items.isEmpty) {
        throw Exception('Cannot create order from empty cart');
      }

      // Group items by seller
      final sellerItems = <String, List<CartItem>>{};
      for (final item in cart.items) {
        final productDoc = await _firestore.collection('products').doc(item.productId).get();
        final sellerId = productDoc.data() is Map ? (productDoc.data() as Map)['sellerId'] as String? : 'unknown-seller';
        sellerItems.putIfAbsent(sellerId ?? 'unknown-seller', () => []).add(item);
      }

      String? firstOrderId;
      final batch = _firestore.batch();

      for (final entry in sellerItems.entries) {
        final sellerId = entry.key;
        final items = entry.value;

        final orderItems = items.map((item) => OrderItem(
          id: item.id,
          productId: item.productId,
          variantId: item.variantId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.totalPrice,
          productTitle: item.productTitle,
          variantAttributes: item.variantAttributes,
        )).toList();

        final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
        final shippingAmount = _calculateShipping(items);
        final taxAmount = subtotal * 0.18;
        final discountAmount = couponCode != null ? await _calculateDiscount(couponCode, subtotal) : 0.0;
        final totalAmount = subtotal + shippingAmount + taxAmount - discountAmount;

        final order = Order(
          id: '',
          userId: userId,
          sellerId: sellerId,
          status: OrderStatus.pending,
          fulfillmentStatus: FulfillmentStatus.pending,
          paymentStatus: PaymentStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          placedAt: DateTime.now(),
          subtotalAmount: subtotal,
          taxAmount: taxAmount,
          shippingAmount: shippingAmount,
          discountAmount: discountAmount,
          totalAmount: totalAmount,
          currency: 'USD',
          customerNotes: notes,
          shippingAddress: Address(
            name: '',
            line1: '',
            line2: null,
            city: '',
            state: '',
            postalCode: '',
            country: '',
            phone: '',
          ),
          billingAddress: Address(
            name: '',
            line1: '',
            line2: null,
            city: '',
            state: '',
            postalCode: '',
            country: '',
            phone: '',
          ),
          items: orderItems,
          discounts: couponCode != null ? [Discount(
            promoId: couponCode,
            code: couponCode,
            type: DiscountType.fixedAmount,
            value: discountAmount,
            description: 'Coupon: $couponCode',
          )] : [],
          history: [],
        );

        final docRef = _firestore.collection('orders').doc();
        batch.set(docRef, order.toFirestore());
        
        // Also add to user's orders subcollection
        batch.set(_firestore.collection('users').doc(userId).collection('orders').doc(docRef.id), order.copyWith(id: docRef.id).toFirestore());
        
        // Add to seller's orders subcollection
        batch.set(_firestore.collection('sellers').doc(sellerId).collection('orders').doc(docRef.id), order.copyWith(id: docRef.id).toFirestore());

        // Add history entry
        final historyRef = _firestore.collection('orders').doc(docRef.id).collection('history').doc();
        batch.set(historyRef, OrderHistoryEntry(
          timestamp: DateTime.now(),
          fromStatus: '',
          toStatus: OrderStatus.pending.name,
          changedBy: userId,
          reason: 'Order created',
          notes: 'Order created from cart',
        ).toFirestore());

        if (firstOrderId == null) firstOrderId = docRef.id;
      }

      await batch.commit();

      // Clear user's cart after successful order creation
      await _firestore.collection('carts').doc(userId).update({
        'items': [],
        'couponCode': null,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });

      return firstOrderId!;
    } catch (e) {
      throw Exception('Failed to create order from cart: $e');
    }
  }

  double _calculateShipping(List<CartItem> items) {
    final hasDigital = false;
    if (hasDigital) return 0.0;
    return 500 + (items.length * 100);
  }

  Future<double> _calculateDiscount(String couponCode, double subtotal) async {
    return (subtotal * 0.1).clamp(0.0, 1000.0);
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? changedBy,
    String? reason,
    String? notes,
  }) async {
    try {
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) throw Exception('Order not found');
      
      final currentStatus = OrderStatus.values.firstWhere(
        (e) => e.name == (orderDoc.data() as Map)['status'],
        orElse: () => OrderStatus.pending,
      );

      await _ordersCollection.doc(orderId).update({
        'status': status.name,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });

      await _ordersCollection.doc(orderId).collection('history').add(OrderHistoryEntry(
        timestamp: DateTime.now(),
        fromStatus: currentStatus.name,
        toStatus: status.name,
        changedBy: changedBy ?? 'system',
        reason: reason ?? 'Status updated',
        notes: notes,
      ).toFirestore());
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> updateOrderFulfillmentStatus(
    String orderId,
    FulfillmentStatus status, {
    String? changedBy,
    String? notes,
  }) async {
    try {
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) throw Exception('Order not found');
      
      final currentStatus = FulfillmentStatus.values.firstWhere(
        (e) => e.name == (orderDoc.data() as Map)['fulfillmentStatus'],
        orElse: () => FulfillmentStatus.pending,
      );

      await _ordersCollection.doc(orderId).update({
        'fulfillmentStatus': status.name,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });

      await _ordersCollection.doc(orderId).collection('history').add(OrderHistoryEntry(
        timestamp: DateTime.now(),
        fromStatus: currentStatus.name,
        toStatus: status.name,
        changedBy: changedBy ?? 'system',
        reason: 'Fulfillment status updated',
        notes: notes,
      ).toFirestore());
    } catch (e) {
      throw Exception('Failed to update fulfillment status: $e');
    }
  }

  @override
  Future<void> updateOrderPaymentStatus(
    String orderId,
    PaymentStatus status, {
    String? changedBy,
    String? notes,
  }) async {
    try {
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) throw Exception('Order not found');
      
      final currentStatus = PaymentStatus.values.firstWhere(
        (e) => e.name == (orderDoc.data() as Map)['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      );

      await _ordersCollection.doc(orderId).update({
        'paymentStatus': status.name,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });

      await _ordersCollection.doc(orderId).collection('history').add(OrderHistoryEntry(
        timestamp: DateTime.now(),
        fromStatus: currentStatus.name,
        toStatus: status.name,
        changedBy: changedBy ?? 'system',
        reason: 'Payment status updated',
        notes: notes,
      ).toFirestore());
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  @override
  Future<void> addPaymentInfo(
    String orderId,
    PaymentInfo paymentInfo,
  ) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'payment': paymentInfo.toFirestore(),
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add payment info: $e');
    }
  }

  @override
  Future<void> addTrackingInfo(
    String orderId,
    ShippingInfo trackingInfo,
  ) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'tracking': trackingInfo.toFirestore(),
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add tracking info: $e');
    }
  }

  @override
  Future<void> addOrderHistoryEntry(
    String orderId,
    OrderHistoryEntry entry,
  ) async {
    try {
      await _ordersCollection.doc(orderId).collection('history').add(entry.toFirestore());
    } catch (e) {
      throw Exception('Failed to add order history entry: $e');
    }
  }

  @override
  Future<void> cancelOrder(
    String orderId, {
    required String cancelledBy,
    required String reason,
  }) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.cancelled,
        changedBy: cancelledBy,
        reason: reason,
        notes: 'Order cancelled by user',
      );
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  @override
  Future<Cart?> getUserCart(String userId) async {
    try {
      final doc = await _firestore.collection('carts').doc(userId).get();
      if (!doc.exists) return null;
      return Cart.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get user cart: $e');
    }
  }

  @override
  Future<void> saveUserCart(String userId, Cart cart) async {
    try {
      await _firestore.collection('carts').doc(userId).set(cart.toFirestore());
    } catch (e) {
      throw Exception('Failed to save user cart: $e');
    }
  }

  @override
  Future<void> clearUserCart(String userId) async {
    try {
      await _firestore.collection('carts').doc(userId).update({
        'items': [],
        'couponCode': null,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to clear user cart: $e');
    }
  }

  @override
  Future<void> addItemToCart(
    String userId,
    String productId,
    String? variantId,
    int quantity,
  ) async {
    try {
      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) throw Exception('Product not found');
      
      final productData = productDoc.data() as Map<String, dynamic>;
      final pricing = productData['pricing'] as Map<String, dynamic>;
      final base = productData['base'] as Map<String, dynamic>;
      
      final cartItem = CartItem(
        id: Uuid().v4(),
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        unitPrice: (pricing['basePrice'] as num?)?.toDouble() ?? 0.0,
        totalPrice: ((pricing['basePrice'] as num?)?.toDouble() ?? 0.0) * quantity,
        productTitle: base['title'] as String? ?? '',
        variantAttributes: variantId != null ? {'variantId': variantId} : {},
      );

      final cartRef = _firestore.collection('carts').doc(userId);
      final cartDoc = await cartRef.get();
      
      if (cartDoc.exists) {
        final items = List<Map<String, dynamic>>.from((cartDoc.data() as Map)['items'] ?? []);
        final existingIndex = items.indexWhere(
          (i) => i['productId'] == productId && i['variantId'] == variantId,
        );
        
        if (existingIndex >= 0) {
          final currentQty = (items[existingIndex]['quantity'] as num?)?.toInt() ?? 0;
          final newQty = currentQty + quantity;
          items[existingIndex] = {
            ...items[existingIndex],
            'quantity': newQty,
            'totalPrice': newQty * (items[existingIndex]['unitPrice'] as num),
            'updatedAt': fs.FieldValue.serverTimestamp(),
          };
        } else {
          items.add(cartItem.toFirestore());
        }
        
        await cartRef.update({
          'items': items,
          'updatedAt': fs.FieldValue.serverTimestamp(),
        });
      } else {
        await cartRef.set({
          'userId': userId,
          'items': [cartItem.toFirestore()],
          'createdAt': fs.FieldValue.serverTimestamp(),
          'updatedAt': fs.FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  @override
  Future<void> updateCartItemQuantity(
    String userId,
    String productId,
    String? variantId,
    int quantity,
  ) async {
    try {
      if (quantity <= 0) {
        await removeItemFromCart(userId, productId, variantId);
        return;
      }
      
      final cartRef = _firestore.collection('carts').doc(userId);
      final cartDoc = await cartRef.get();
      if (!cartDoc.exists) return;
      
      final items = List<Map<String, dynamic>>.from((cartDoc.data() as Map)['items'] ?? []);
      final index = items.indexWhere(
        (i) => i['productId'] == productId && i['variantId'] == variantId,
      );
      
      if (index < 0) return;
      
      final unitPrice = (items[index]['unitPrice'] as num?)?.toDouble() ?? 0.0;
      items[index] = {
        ...items[index],
        'quantity': quantity,
        'totalPrice': quantity * unitPrice,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      };
      
      await cartRef.update({'items': items});
    } catch (e) {
      throw Exception('Failed to update cart item quantity: $e');
    }
  }

  @override
  Future<void> removeItemFromCart(
    String userId,
    String productId,
    String? variantId,
  ) async {
    try {
      final cartRef = _firestore.collection('carts').doc(userId);
      final cartDoc = await cartRef.get();
      if (!cartDoc.exists) return;
      
      final items = List<Map<String, dynamic>>.from((cartDoc.data() as Map)['items'] ?? []);
      items.removeWhere(
        (i) => i['productId'] == productId && i['variantId'] == variantId,
      );
      
      await cartRef.update({'items': items});
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  @override
  Future<void> saveCartForLater(String userId, Cart cart) async {
    try {
      await _firestore.collection('users').doc(userId).collection('saved_carts').doc(cart.id).set(cart.toFirestore());
    } catch (e) {
      throw Exception('Failed to save cart for later: $e');
    }
  }

  @override
  Future<List<CartItem>> getSavedItems(String userId) async {
    try {
      final querySnapshot = await _firestore.collection('users').doc(userId).collection('saved_carts').get();
      return querySnapshot.docs
          .map((doc) => Cart.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .expand((cart) => cart.items)
          .toList();
    } catch (e) {
      throw Exception('Failed to get saved items: $e');
    }
  }
}