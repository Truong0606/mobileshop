import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_shopping_chatbot/features/chat/data/repositories/chat_repository.dart';
import 'package:smart_shopping_chatbot/features/chat/data/models/conversation_model.dart';
import 'package:smart_shopping_chatbot/shared/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepository();
}

@riverpod
String chatCustomerId(Ref ref) {
  // Tạm thời gán hardcode id của business owner để test
  return '6a572ade7904e1b8e301a78b';
}

@riverpod
class ConversationList extends _$ConversationList {
  @override
  FutureOr<List<ConversationModel>> build() async {
    return _fetchConversations();
  }

  Future<List<ConversationModel>> _fetchConversations() async {
    final repo = ref.read(chatRepositoryProvider);
    final customerId = ref.read(chatCustomerIdProvider);

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
    final customerId = ref.read(chatCustomerIdProvider);

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
  bool _isTyping = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isTyping => _isTyping;

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || conversationId == 'new') return;

    _isLoadingMore = true;
    state = AsyncData(state.value ?? []);

    try {
      final repo = ref.read(chatRepositoryProvider);
      final customerId = ref.read(chatCustomerIdProvider);

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
    final customerId = ref.read(chatCustomerIdProvider);

    final tempMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      sender: 'User',
      content: text,
      createdAt: DateTime.now(),
    );

    state = AsyncData([...(state.value ?? []), tempMsg]);
    
    _isTyping = true;
    state = AsyncData(state.value ?? []);

    try {
      ConversationModel response;
      if (conversationId == 'new') {
        response = await repo.startConversation(
          SendMessageCommand(message: text, externalCustomerId: customerId),
        );
        ref.read(conversationListProvider.notifier).refresh();
      } else {
        response = await repo.sendMessage(
          conversationId,
          SendMessageCommand(message: text, externalCustomerId: customerId),
        );
      }

      _isTyping = false;

      if (response.messages != null && response.messages!.isNotEmpty) {
        final lastMsg = response.messages!.last;
        
        // Cập nhật bằng cách lấy state hiện tại (đã chứa tin nhắn của user) và append thêm tin nhắn của bot
        final currentMessages = state.value ?? [];

        if (lastMsg.sender.toLowerCase() != 'user' && lastMsg.sender.toLowerCase() != 'customer') {
          String currentText = '';
          final words = lastMsg.content.split(' ');
          
          for (int i = 0; i < words.length; i++) {
            currentText += (i == 0 ? '' : ' ') + words[i];
            final streamingMsg = ChatMessageModel(
              id: lastMsg.id,
              conversationId: lastMsg.conversationId,
              sender: lastMsg.sender,
              content: currentText,
              createdAt: lastMsg.createdAt,
            );
            
            // Xóa đi các tin nhắn streaming trước đó của chính nó (nếu có) bằng cách lọc theo id
            // Hoặc đơn giản là thêm trực tiếp nếu ta giả định id tin nhắn bot là duy nhất và luôn ở cuối
            // Để an toàn, filter các tin nhắn không phải là streamingMsg hiện tại
            final msgsWithoutCurrentStreaming = currentMessages.where((m) => m.id != lastMsg.id).toList();
            
            state = AsyncData([...msgsWithoutCurrentStreaming, streamingMsg]);
            await Future.delayed(const Duration(milliseconds: 30));
          }
        } else {
          // Trừ trường hợp fallback
          state = AsyncData([...currentMessages, lastMsg]);
        }
      }
    } catch (e, st) {
      _isTyping = false;
      state = AsyncData(state.value ?? []);
      print('=== CHAT ERROR ===');
      print(e);
      print(st);
      // Revert optimistic message on error (ignored for demo simplicity)
    }
  }
}
