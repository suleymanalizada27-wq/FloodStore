import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../domain/entities/order.dart';
import '../../domain/repositories/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreUserRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference _usersRef() => _firestore.collection('users');

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _usersRef().doc(userId).get();
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      await _usersRef().doc(userId).update({
        ...profileData,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final doc = await _usersRef().doc(userId).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>?;
      return data?['preferences'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  @override
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      await _usersRef().doc(userId).update({
        'preferences': preferences,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserWallet(String userId) async {
    try {
      final doc = await _usersRef().doc(userId).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>?;
      return data?['wallet'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user wallet: $e');
    }
  }

  @override
  Future<void> addFundsToWallet(String userId, double amount) async {
    try {
      await _usersRef().doc(userId).update({
        'wallet.balance': fs.FieldValue.increment(amount),
        'wallet.lifetimeEarnings': fs.FieldValue.increment(amount),
        'wallet.lastUpdated': fs.FieldValue.serverTimestamp(),
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add funds to wallet: $e');
    }
  }

  @override
  Future<void> deductFromWallet(String userId, double amount) async {
    try {
      await _usersRef().doc(userId).update({
        'wallet.balance': fs.FieldValue.increment(-amount),
        'wallet.lifetimeSpent': fs.FieldValue.increment(amount),
        'wallet.lastUpdated': fs.FieldValue.serverTimestamp(),
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to deduct from wallet: $e');
    }
  }

  @override
  Future<List<Order>> getUserOrderHistory(String userId, {
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      fs.Query query = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _firestore.collection('orders').doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Order.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user order history: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserWishlist(String userId, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _usersRef()
          .doc(userId)
          .collection('wishlist')
          .orderBy('addedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw Exception('Failed to get user wishlist: $e');
    }
  }

  @override
  Future<void> addToWishlist(String userId, String productId) async {
    try {
      await _usersRef()
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .set({
        'productId': productId,
        'addedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      await _usersRef()
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  @override
  Future<List<String>> getRecentlyViewed(String userId, {
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _usersRef()
          .doc(userId)
          .collection('recently_viewed')
          .orderBy('viewedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to get recently viewed: $e');
    }
  }

  @override
  Future<void> addToRecentlyViewed(String userId, String productId) async {
    try {
      await _usersRef()
          .doc(userId)
          .collection('recently_viewed')
          .doc(productId)
          .set({
        'productId': productId,
        'viewedAt': fs.FieldValue.serverTimestamp(),
      });

      // Keep only last 50 items
      final querySnapshot = await _usersRef()
          .doc(userId)
          .collection('recently_viewed')
          .orderBy('viewedAt', descending: true)
          .get();

      if (querySnapshot.docs.length > 50) {
        final batch = _firestore.batch();
        for (int i = 50; i < querySnapshot.docs.length; i++) {
          batch.delete(querySnapshot.docs[i].reference);
        }
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to add to recently viewed: $e');
    }
  }

  @override
  Future<void> clearRecentlyViewed(String userId) async {
    try {
      final querySnapshot = await _usersRef()
          .doc(userId)
          .collection('recently_viewed')
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear recently viewed: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    try {
      final querySnapshot = await _usersRef()
          .doc(userId)
          .collection('addresses')
          .orderBy('isDefault', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw Exception('Failed to get user addresses: $e');
    }
  }

  @override
  Future<String> addUserAddress(String userId, Map<String, dynamic> addressData) async {
    try {
      final docRef = await _usersRef()
          .doc(userId)
          .collection('addresses')
          .add({
        ...addressData,
        'createdAt': fs.FieldValue.serverTimestamp(),
        'isDefault': false,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add user address: $e');
    }
  }

  @override
  Future<void> updateUserAddress(String userId, String addressId, Map<String, dynamic> addressData) async {
    try {
      await _usersRef()
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .update({
        ...addressData,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user address: $e');
    }
  }

  @override
  Future<void> deleteUserAddress(String userId, String addressId) async {
    try {
      await _usersRef()
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user address: $e');
    }
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      final batch = _firestore.batch();
      final addressesRef = _usersRef().doc(userId).collection('addresses');

      // Reset all to non-default
      final allAddresses = await addressesRef.get();
      for (final doc in allAddresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set the selected one as default
      batch.update(addressesRef.doc(addressId), {'isDefault': true});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }
}