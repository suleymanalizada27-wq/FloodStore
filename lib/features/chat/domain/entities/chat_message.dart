import 'package:equatable/equatable.dart';

/// Represents a chat message in the AI Shopping Assistant
class ChatMessage extends Equatable {
  final String id;
  final String sessionId;
  final ChatRole role;
  final String content;
  final List<ChatAttachment> attachments;
  final List<ProductSuggestion> productSuggestions;
  final DateTime createdAt;
  final bool isStreaming;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.attachments = const [],
    this.productSuggestions = const [],
    required this.createdAt,
    this.isStreaming = false,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        role,
        content,
        attachments,
        productSuggestions,
        createdAt,
        isStreaming,
        metadata,
      ];

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    ChatRole? role,
    String? content,
    List<ChatAttachment>? attachments,
    List<ProductSuggestion>? productSuggestions,
    DateTime? createdAt,
    bool? isStreaming,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      productSuggestions: productSuggestions ?? this.productSuggestions,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
      metadata: metadata ?? this.metadata,
    );
  }

  factory ChatMessage.user({
    required String sessionId,
    required String content,
    List<ChatAttachment> attachments = const [],
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      role: ChatRole.user,
      content: content,
      attachments: attachments,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.assistant({
    required String sessionId,
    required String content,
    List<ProductSuggestion> productSuggestions = const [],
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      role: ChatRole.assistant,
      content: content,
      productSuggestions: productSuggestions,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  factory ChatMessage.streaming({
    required String sessionId,
    required String content,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      role: ChatRole.assistant,
      content: content,
      createdAt: DateTime.now(),
      isStreaming: true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'role': role.name,
      'content': content,
      'attachments': attachments.map((a) => a.toFirestore()).toList(),
      'productSuggestions': productSuggestions.map((p) => p.toFirestore()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isStreaming': isStreaming,
      'metadata': metadata,
    };
  }

  static ChatMessage fromFirestore(Map<String, dynamic> data, String id) {
    return ChatMessage(
      id: id,
      sessionId: data['sessionId'] ?? '',
      role: ChatRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => ChatRole.assistant,
      ),
      content: data['content'] ?? '',
      attachments: (data['attachments'] as List?)
              ?.map((a) => ChatAttachment.fromFirestore(a))
              .toList() ??
          [],
      productSuggestions: (data['productSuggestions'] as List?)
              ?.map((p) => ProductSuggestion.fromFirestore(p))
              .toList() ??
          [],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      isStreaming: data['isStreaming'] ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}

enum ChatRole { user, assistant, system }

class ChatAttachment extends Equatable {
  final String id;
  final AttachmentType type;
  final String url;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final Duration? duration;

  const ChatAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.duration,
  });

  @override
  List<Object?> get props => [id, type, url, thumbnailUrl, fileName, fileSize, duration];

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type.name,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration?.inMilliseconds,
    };
  }

  static ChatAttachment fromFirestore(Map<String, dynamic> data) {
    return ChatAttachment(
      id: data['id'] ?? '',
      type: AttachmentType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => AttachmentType.image,
      ),
      url: data['url'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      fileName: data['fileName'],
      fileSize: data['fileSize'],
      duration: data['duration'] != null
          ? Duration(milliseconds: data['duration'])
          : null,
    );
  }
}

enum AttachmentType { image, voice, document, product_link }

class ProductSuggestion extends Equatable {
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String reason;

  const ProductSuggestion({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.reason,
  });

  @override
  List<Object?> get props => [
        productId,
        title,
        imageUrl,
        price,
        originalPrice,
        rating,
        reviewCount,
        reason,
      ];

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'reason': reason,
    };
  }

  static ProductSuggestion fromFirestore(Map<String, dynamic> data) {
    return ProductSuggestion(
      productId: data['productId'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      reason: data['reason'] ?? '',
    );
  }
}