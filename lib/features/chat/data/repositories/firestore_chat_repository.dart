import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:floodstore/features/chat/domain/entities/chat_message.dart';
import 'package:floodstore/features/chat/domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';

class FirestoreChatRepository implements ChatRepository {
  final fs.FirebaseFirestore _firestore;

  FirestoreChatRepository({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  fs.CollectionReference _sessionsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('chat_sessions');

  fs.CollectionReference _messagesRef(String sessionId) =>
      _firestore.collection('chat_sessions').doc(sessionId).collection('messages');

  @override
  Future<String> createSession(String userId) async {
    try {
      final docRef = await _sessionsRef(userId).add({
        'userId': userId,
        'title': 'Yeni Sohbet',
        'createdAt': fs.FieldValue.serverTimestamp(),
        'updatedAt': fs.FieldValue.serverTimestamp(),
        'messageCount': 0,
        'status': 'active',
        'context': {},
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create chat session: $e');
    }
  }

  @override
  Future<ChatSession?> getSession(String sessionId) async {
    try {
      final doc = await _firestore.collection('chat_sessions').doc(sessionId).get();
      if (!doc.exists) return null;
      return ChatSession.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get chat session: $e');
    }
  }

  @override
  Future<List<ChatSession>> getUserSessions(String userId, {int limit = 20}) async {
    try {
      final query = await _sessionsRef(userId)
          .where('status', isEqualTo: 'active')
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();
      return query.docs.map((doc) => ChatSession.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get user sessions: $e');
    }
  }

  @override
  Future<ChatMessage> sendMessage(ChatMessage message) async {
    try {
      final docRef = await _messagesRef(message.sessionId).add(message.toFirestore());
      // Update session
      await _firestore.collection('chat_sessions').doc(message.sessionId).update({
        'messageCount': fs.FieldValue.increment(1),
        'updatedAt': fs.FieldValue.serverTimestamp(),
        'lastMessage': message.toFirestore(),
      });
      return message.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId, {int limit = 50, String? lastDocumentId}) async {
    try {
      var query = _messagesRef(sessionId).orderBy('createdAt', descending: true).limit(limit);
      if (lastDocumentId != null) {
        final lastDoc = await _messagesRef(sessionId).doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String sessionId) {
    return _messagesRef(sessionId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id))
            .toList());
  }

  @override
  Future<void> updateMessage(ChatMessage message) async {
    try {
      await _messagesRef(message.sessionId).doc(message.id).update(message.toFirestore());
      // Update lastMessage in session if this is the latest
      final sessionDoc = await _firestore.collection('chat_sessions').doc(message.sessionId).get();
      if (sessionDoc.exists) {
        final lastMsg = (sessionDoc.data()!)['lastMessage'] as Map<String, dynamic>?;
        if (lastMsg != null && lastMsg['id'] == message.id) {
          await _firestore.collection('chat_sessions').doc(message.sessionId).update({
            'lastMessage': message.toFirestore(),
            'updatedAt': fs.FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update message: $e');
    }
  }

  @override
  Future<void> deleteMessage(String sessionId, String messageId) async {
    try {
      await _messagesRef(sessionId).doc(messageId).delete();
      await _firestore.collection('chat_sessions').doc(sessionId).update({
        'messageCount': fs.FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  @override
  Future<void> clearSession(String sessionId) async {
    try {
      final batch = _firestore.batch();
      final messages = await _messagesRef(sessionId).get();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }
      batch.update(_firestore.collection('chat_sessions').doc(sessionId), {
        'messageCount': 0,
        'updatedAt': fs.FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear session: $e');
    }
  }

  @override
  Future<ChatMessage> getAIResponse({
    required String sessionId,
    required String userMessage,
    List<ChatMessage> context = const [],
  }) async {
    // This would call an AI service (Gemini, GPT, etc.)
    // For now, return a mock response
    await Future.delayed(const Duration(milliseconds: 500));
    return ChatMessage.assistant(
      sessionId: sessionId,
      content: 'AI yanıtı buraya gelecek. Mesajınız: "$userMessage"',
      productSuggestions: const [],
    );
  }

  @override
  Future<void> rateResponse(String messageId, bool helpful) async {
    try {
      await _firestore.collection('chat_messages').doc(messageId).update({
        'metadata.helpful': helpful,
        'metadata.ratedAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to rate response: $e');
    }
  }

  @override
  Future<List<ProductSuggestion>> getProductSuggestions(String message, {
    String? categoryId,
    double? maxPrice,
    String? userId,
  }) async {
    // This would use vector search or keyword matching
    // For now, return empty list
    return [];
  }

  @override
  Future<void> saveSuggestionFeedback(String sessionId, String productId, bool clicked) async {
    try {
      await _firestore.collection('chat_sessions').doc(sessionId).collection('feedback').add({
        'productId': productId,
        'clicked': clicked,
        'createdAt': fs.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save suggestion feedback: $e');
    }
  }
}