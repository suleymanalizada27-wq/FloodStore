import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/chat/application/providers/chat_providers.dart';
import 'package:floodstore/features/chat/domain/entities/chat_session.dart';
import 'package:floodstore/features/chat/presentation/screens/message_thread_screen.dart';
import 'package:floodstore/features/marketplace/application/providers/marketplace_providers.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: currentUserId == null
          ? const Center(child: Text('Please log in to see messages'))
          : FutureBuilder<List<ChatSession>>(
              future: ref.read(chatRepositoryProvider).getUserSessions(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final chats = snapshot.data ?? [];
                
                if (chats.isEmpty) {
                  return const Center(
                    child: Text('No conversations yet'),
                  );
                }
                
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];

                    // For simplicity, we'll show the other participant's ID
                    // In a real app, you'd fetch the user details
                    final otherUserId = chat.userId == currentUserId
                        ? 'other-user'
                        : chat.userId;
                        
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: Text(
                          otherUserId.substring(0, 2).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        'User $otherUserId',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        chat.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${chat.messageCount} messages',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          if (chat.status == ChatSessionStatus.active)
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MessageThreadScreen(
                              sessionId: chat.id,
                              otherUserId: otherUserId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new conversation screen
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
