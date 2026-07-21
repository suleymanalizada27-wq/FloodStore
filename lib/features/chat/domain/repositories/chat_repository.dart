import '../entities/chat_message.dart';
import '../entities/chat_session.dart';

abstract class ChatRepository {
  /// Create or get chat session
  Future<String> createSession(String userId);

  /// Get session
  Future<ChatSession?> getSession(String sessionId);

  /// Get user's sessions
  Future<List<ChatSession>> getUserSessions(String userId, {int limit = 20});

  /// Send message
  Future<ChatMessage> sendMessage(ChatMessage message);

  /// Get messages for session
  Future<List<ChatMessage>> getMessages(String sessionId, {
    int limit = 50,
    String? lastDocumentId,
  });

  /// Stream messages (real-time)
  Stream<List<ChatMessage>> watchMessages(String sessionId);

  /// Update message (for streaming)
  Future<void> updateMessage(ChatMessage message);

  /// Delete message
  Future<void> deleteMessage(String sessionId, String messageId);

  /// Clear session history
  Future<void> clearSession(String sessionId);

  /// Get AI response (calls AI service)
  Future<ChatMessage> getAIResponse({
    required String sessionId,
    required String userMessage,
    List<ChatMessage> context = const [],
  });

  /// Rate AI response (helpful/not helpful)
  Future<void> rateResponse(String messageId, bool helpful);

  /// Get product suggestions for message
  Future<List<ProductSuggestion>> getProductSuggestions(String message, {
    String? categoryId,
    double? maxPrice,
    String? userId,
  });

  /// Save user feedback on suggestion
  Future<void> saveSuggestionFeedback(String sessionId, String productId, bool clicked);
}