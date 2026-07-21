import 'package:equatable/equatable.dart';

/// Chat session
class ChatSession extends Equatable {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final ChatSessionStatus status;
  final Map<String, dynamic> context;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.status = ChatSessionStatus.active,
    this.context = const {},
  });

  @override
  List<Object?> get props => [id, userId, title, createdAt, updatedAt, messageCount, status, context];

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messageCount': messageCount,
        'status': status.name,
        'context': context,
      };

  static ChatSession fromFirestore(Map<String, dynamic> data, String id) {
    return ChatSession(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
      messageCount: data['messageCount'] ?? 0,
      status: ChatSessionStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ChatSessionStatus.active,
      ),
      context: Map<String, dynamic>.from(data['context'] ?? {}),
    );
  }
}

enum ChatSessionStatus { active, archived, deleted }