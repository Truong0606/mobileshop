import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_shopping_chatbot/core/network/api_client.dart';
import 'package:smart_shopping_chatbot/features/chat/data/repositories/chat_repository.dart';
import 'package:smart_shopping_chatbot/features/chat/data/models/conversation_model.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(ApiClient.instance);
}

@riverpod
class ConversationList extends _$ConversationList {
  @override
  FutureOr<List<ConversationModel>> build() async {
    return _fetchConversations();
  }

  Future<List<ConversationModel>> _fetchConversations() async {
    final repo = ref.read(chatRepositoryProvider);
    const customerId = "demo-customer-123";

    final res = await repo.getConversations(customerId, pageSize: 50);
    final items = res.items;
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchConversations());
  }
}

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  FutureOr<List<ChatMessageModel>> build(String conversationId) async {
    if (conversationId == 'new') return [];

    final repo = ref.read(chatRepositoryProvider);
    const customerId = "demo-customer-123";

    final res = await repo.getMessages(conversationId, customerId);

    final messages = res.items;
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _lastCursor = res.nextCursor;
    _hasMore = res.nextCursor != null;

    return messages;
  }

  String? _lastCursor;
  bool _hasMore = false;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || conversationId == 'new') return;

    _isLoadingMore = true;
    state = AsyncData(state.value ?? []);

    try {
      final repo = ref.read(chatRepositoryProvider);
      const customerId = "demo-customer-123";

      final res = await repo.getMessages(
        conversationId,
        customerId,
        lastCursor: _lastCursor,
      );

      final newMessages = res.items;
      newMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _lastCursor = res.nextCursor;
      _hasMore = res.nextCursor != null;

      state = AsyncData([...newMessages, ...state.value!]);
    } finally {
      _isLoadingMore = false;
      state = AsyncData(state.value ?? []);
    }
  }

  Future<void> sendMessage(String text) async {
    final repo = ref.read(chatRepositoryProvider);
    const customerId = "demo-customer-123";

    final tempMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      sender: 'User',
      content: text,
      createdAt: DateTime.now(),
    );

    state = AsyncData([...(state.value ?? []), tempMsg]);

    try {
      if (conversationId == 'new') {
        await repo.startConversation(
          SendMessageCommand(message: text, externalCustomerId: customerId),
        );
        ref.read(conversationListProvider.notifier).refresh();
      } else {
        final response = await repo.sendMessage(
          conversationId,
          SendMessageCommand(message: text, externalCustomerId: customerId),
        );
        if (response.messages != null) {
          final sorted = List<ChatMessageModel>.from(response.messages!);
          sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          state = AsyncData(sorted);
        }
      }
    } catch (e) {
      // Revert optimistic message on error (ignored for demo simplicity)
    }
  }
}
