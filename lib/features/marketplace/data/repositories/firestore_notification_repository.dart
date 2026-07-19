import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreNotificationRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference _notificationsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  fs.DocumentReference _preferencesRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('settings').doc('notifications');

  @override
  Future<List<Notification>> getNotifications(String userId, {
    int limit = 20,
    String? lastDocumentId,
    bool unreadOnly = false,
    NotificationType? type,
  }) async {
    try {
      var query = _notificationsRef(userId)
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (unreadOnly) {
        query = query.where('isRead', isEqualTo: false);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      if (lastDocumentId != null) {
        final lastDoc = await _notificationsRef(userId).doc(lastDocumentId).get();
        if (lastDoc.exists) query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Notification.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _notificationsRef(userId)
        .where('isRead', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _notificationsRef(userId).doc(notificationId).update({
        'isRead': true,
        'readAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final unread = await _notificationsRef(userId)
          .where('isRead', isEqualTo: false)
          .where('isArchived', isEqualTo: false)
          .get();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': fs.FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  @override
  Future<void> archive(String userId, String notificationId) async {
    try {
      await _notificationsRef(userId).doc(notificationId).update({
        'isArchived': true,
      });
    } catch (e) {
      throw Exception('Failed to archive: $e');
    }
  }

  @override
  Future<void> delete(String userId, String notificationId) async {
    try {
      await _notificationsRef(userId).doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }

  @override
  Future<String> create(Notification notification) async {
    try {
      final docRef = await _notificationsRef(notification.userId).add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  @override
  Future<void> createBulk(List<Notification> notifications) async {
    try {
      final batch = _firestore.batch();
      for (final notification in notifications) {
        final ref = _notificationsRef(notification.userId).doc();
        batch.set(ref, notification.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create bulk notifications: $e');
    }
  }

  @override
  Future<NotificationPreferences> getPreferences(String userId) async {
    try {
      final doc = await _preferencesRef(userId).get();
      if (!doc.exists) {
        return NotificationPreferences(userId: userId);
      }
      return NotificationPreferences.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get preferences: $e');
    }
  }

  @override
  Future<void> updatePreferences(String userId, NotificationPreferences preferences) async {
    try {
      await _preferencesRef(userId).set(preferences.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String userId, String topic) async {
    // This would call Firebase Cloud Messaging API
    // For now, store in user document
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTopics': fs.FieldValue.arrayUnion([topic]),
      });
    } catch (e) {
      throw Exception('Failed to subscribe to topic: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String userId, String topic) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTopics': fs.FieldValue.arrayRemove([topic]),
      });
    } catch (e) {
      throw Exception('Failed to unsubscribe from topic: $e');
    }
  }

  @override
  Future<void> sendPush({
    required String userId,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic> data = const {},
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    // This would call FCM HTTP v1 API or use a Cloud Function
    // Store in notifications for in-app display
    await create(Notification(
      id: '',
      userId: userId,
      type: NotificationType.general,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      priority: priority,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<void> schedule(Notification notification, DateTime scheduledAt) async {
    // Store with future createdAt, use Cloud Function to trigger
    try {
      await _notificationsRef(notification.userId).doc(notification.id).set(
        notification.copyWith(createdAt: scheduledAt).toFirestore(),
      );
    } catch (e) {
      throw Exception('Failed to schedule notification: $e');
    }
  }

  @override
  Future<void> cancelScheduled(String notificationId) async {
    // Would need to find by ID across all users - use a scheduled collection
    try {
      await _firestore.collection('scheduled_notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to cancel scheduled: $e');
    }
  }

  @override
  Future<int> cleanOldNotifications({int daysOld = 90}) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    try {
      // This would be a batch operation across all users
      // For production, use a Cloud Function
      return 0;
    } catch (e) {
      throw Exception('Failed to clean old notifications: $e');
    }
  }
}