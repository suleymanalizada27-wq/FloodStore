import '../entities/notification.dart';

abstract class NotificationRepository {
  /// Get user notifications
  Future<List<Notification>> getNotifications(String userId, {
    int limit = 20,
    String? lastDocumentId,
    bool unreadOnly = false,
    NotificationType? type,
  });

  /// Stream unread count
  Stream<int> watchUnreadCount(String userId);

  /// Mark as read
  Future<void> markAsRead(String userId, String notificationId);

  /// Mark all as read
  Future<void> markAllAsRead(String userId);

  /// Archive notification
  Future<void> archive(String userId, String notificationId);

  /// Delete notification
  Future<void> delete(String userId, String notificationId);

  /// Create notification
  Future<String> create(Notification notification);

  /// Create bulk notifications
  Future<void> createBulk(List<Notification> notifications);

  /// Get notification preferences
  Future<NotificationPreferences> getPreferences(String userId);

  /// Update notification preferences
  Future<void> updatePreferences(String userId, NotificationPreferences preferences);

  /// Subscribe to topic (for FCM)
  Future<void> subscribeToTopic(String userId, String topic);

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String userId, String topic);

  /// Send push notification (via FCM)
  Future<void> sendPush({
    required String userId,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic> data = const {},
    NotificationPriority priority = NotificationPriority.normal,
  });

  /// Schedule notification
  Future<void> schedule(Notification notification, DateTime scheduledAt);

  /// Cancel scheduled notification
  Future<void> cancelScheduled(String notificationId);

  /// Clean old notifications (cron job)
  Future<int> cleanOldNotifications({int daysOld = 90});
}