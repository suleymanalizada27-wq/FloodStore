import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// User notification
class Notification extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt;
  final bool isRead;
  final bool isArchived;
  final String? actionUrl;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    this.priority = NotificationPriority.normal,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
    this.isRead = false,
    this.isArchived = false,
    this.actionUrl,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        body,
        imageUrl,
        data,
        priority,
        createdAt,
        readAt,
        expiresAt,
        isRead,
        isArchived,
        actionUrl,
      ];

  Notification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    NotificationPriority? priority,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? expiresAt,
    bool? isRead,
    bool? isArchived,
    String? actionUrl,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isRead': isRead,
      'isArchived': isArchived,
      'actionUrl': actionUrl,
    };
  }

  static Notification fromFirestore(Map<String, dynamic> data, String id) {
    return Notification(
      id: id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => NotificationType.general,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      priority: NotificationPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      readAt: data['readAt'] != null ? DateTime.parse(data['readAt']) : null,
      expiresAt: data['expiresAt'] != null ? DateTime.parse(data['expiresAt']) : null,
      isRead: data['isRead'] ?? false,
      isArchived: data['isArchived'] ?? false,
      actionUrl: data['actionUrl'],
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

enum NotificationType {
  priceDrop,
  backInStock,
  orderStatus,
  shippingUpdate,
  promotion,
  newArrival,
  reviewRequest,
  sellerMessage,
  paymentSuccess,
  paymentFailed,
  refundProcessed,
  wishlistSale,
  priceAlert,
  loyaltyReward,
  securityAlert,
  general,
}

enum NotificationPriority { low, normal, high, urgent }

/// Notification preferences per user
class NotificationPreferences extends Equatable {
  final String userId;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final Map<NotificationType, bool> typeEnabled;
  final Map<NotificationType, NotificationChannel> preferredChannel;
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final String timezone;

  const NotificationPreferences({
    required this.userId,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
    this.typeEnabled = const {},
    this.preferredChannel = const {},
    this.quietHoursEnabled = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 8, minute: 0),
    this.timezone = 'UTC',
  });

  @override
  List<Object?> get props => [
        userId,
        pushEnabled,
        emailEnabled,
        smsEnabled,
        typeEnabled,
        preferredChannel,
        quietHoursEnabled,
        quietHoursStart,
        quietHoursEnd,
        timezone,
      ];

  bool isTypeEnabled(NotificationType type) => typeEnabled[type] ?? true;

  NotificationChannel getPreferredChannel(NotificationType type) =>
      preferredChannel[type] ?? NotificationChannel.push;

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
      'typeEnabled': typeEnabled.map((k, v) => MapEntry(k.name, v)),
      'preferredChannel': preferredChannel.map((k, v) => MapEntry(k.name, v.name)),
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': '${quietHoursStart.hour}:${quietHoursStart.minute}',
      'quietHoursEnd': '${quietHoursEnd.hour}:${quietHoursEnd.minute}',
      'timezone': timezone,
    };
  }

  static NotificationPreferences fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationPreferences(
      userId: data['userId'] ?? '',
      pushEnabled: data['pushEnabled'] ?? true,
      emailEnabled: data['emailEnabled'] ?? true,
      smsEnabled: data['smsEnabled'] ?? false,
      typeEnabled: (data['typeEnabled'] as Map?)?.map((k, v) => MapEntry(
            NotificationType.values.firstWhere((t) => t.name == k, orElse: () => NotificationType.general),
            v as bool,
          )) ??
          {},
      preferredChannel: (data['preferredChannel'] as Map?)?.map((k, v) => MapEntry(
            NotificationType.values.firstWhere((t) => t.name == k, orElse: () => NotificationType.general),
            NotificationChannel.values.firstWhere((c) => c.name == v, orElse: () => NotificationChannel.push),
          )) ??
          {},
      quietHoursEnabled: data['quietHoursEnabled'] ?? false,
      quietHoursStart: _parseTime(data['quietHoursStart']) ?? const TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: _parseTime(data['quietHoursEnd']) ?? const TimeOfDay(hour: 8, minute: 0),
      timezone: data['timezone'] ?? 'UTC',
    );
  }

  static TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }
}

enum NotificationChannel { push, email, sms, inApp }