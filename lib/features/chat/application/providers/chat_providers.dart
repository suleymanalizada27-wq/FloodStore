import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/visual_search_repository.dart';
import '../../data/repositories/firestore_chat_repository.dart';
import '../../data/repositories/firestore_notification_repository.dart';
import '../../data/repositories/firestore_visual_search_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/visual_search.dart';

// Repository Providers
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirestoreChatRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FirestoreNotificationRepository();
});

final visualSearchRepositoryProvider = Provider<VisualSearchRepository>((ref) {
  return FirestoreVisualSearchRepository();
});

// Chat Providers
final chatSessionsProvider =
    FutureProvider.family<List<ChatSession>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).getUserSessions(userId);
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, sessionId) {
  return ref.watch(chatRepositoryProvider).watchMessages(sessionId);
});

// Notification Providers
final notificationsProvider =
    FutureProvider.family<List<Notification>, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).getNotifications(userId);
});

final unreadNotificationCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).watchUnreadCount(userId);
});

final notificationPreferencesProvider =
    FutureProvider.family<NotificationPreferences, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).getPreferences(userId);
});

// Visual Search Providers
final visualSearchHistoryProvider =
    FutureProvider.family<List<VisualSearchResult>, String>((ref, userId) {
  return ref.watch(visualSearchRepositoryProvider).getHistory(userId);
});
