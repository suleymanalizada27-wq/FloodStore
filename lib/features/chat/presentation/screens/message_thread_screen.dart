import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/chat/application/providers/chat_providers.dart';
import 'package:floodstore/features/chat/domain/entities/chat_message.dart';
import 'package:floodstore/features/marketplace/application/providers/marketplace_providers.dart';

class MessageThreadScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String otherUserId;

  const MessageThreadScreen({
    Key? key,
    required this.sessionId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  ConsumerState<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    
    final message = ChatMessage.user(
      sessionId: widget.sessionId,
      content: text,
    );

    ref.read(chatRepositoryProvider).sendMessage(message).then((sentMessage) {
      _messageController.clear();
    }).catchError((error) {
      // Handle error
    }).whenComplete(() {
      setState(() => _isSending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with User ${widget.otherUserId}'),
        actions: [
          // TODO: Add menu for more options (view profile, etc.)
        ],
      ),
      body: currentUserId == null
          ? const Center(child: Text('Please log in to continue'))
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: ref.read(chatRepositoryProvider).watchMessages(widget.sessionId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      final messages = snapshot.data ?? [];
                      
                      if (messages.isEmpty) {
                        return const Center(
                          child: Text('No messages yet'),
                        );
                      }
                      
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.role == ChatRole.user;
                          
                          return Align(
                            alignment: 
                                isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isMe 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe 
                                      ? Colors.white 
                                      : Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildMessageInput(currentUserId),
              ],
            ),
    );
  }

  Widget _buildMessageInput(String currentUserId) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          if (_isSending)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
        ],
      ),
    );
  }
}
