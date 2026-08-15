import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_shopping_chatbot/features/chat/data/repositories/chat_repository.dart';
import 'package:smart_shopping_chatbot/features/chat/data/models/conversation_model.dart';
import 'package:smart_shopping_chatbot/shared/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepository();
}



@riverpod
class ConversationList extends _$ConversationList {
  @override
  FutureOr<List<ConversationModel>> build() async {
    final authState = ref.watch(authProvider);
    if (!authState.isLoggedIn) {
      return [];
    }
    return _fetchConversations();
  }

  Future<List<ConversationModel>> _fetchConversations() async {
    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.getConversations(pageSize: 50);
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

    final res = await repo.getMessages(conversationId);

    final messages = res.items;
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _lastCursor = res.nextCursor;
    _hasMore = res.nextCursor != null;

    return messages;
  }

  // Lưu conversation ID thật sau khi tạo hội thoại mới,
  // để các tin nhắn tiếp theo dùng sendMessage thay vì startConversation.
  String? _realConversationId;
  String? _lastCursor;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  bool _isTyping = false;

  /// ID hội thoại thực tế (dùng cho API calls)
  String get _effectiveId => _realConversationId ?? conversationId;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isTyping => _isTyping;
  /// Expose real ID để UI biết conversation đã được tạo
  String? get realConversationId => _realConversationId;

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _effectiveId == 'new') return;

    _isLoadingMore = true;
    state = AsyncData(state.value ?? []);

    try {
      final repo = ref.read(chatRepositoryProvider);

      final res = await repo.getMessages(
        _effectiveId,
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

    final tempMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: _effectiveId,
      sender: 'User',
      content: text,
      createdAt: DateTime.now(),
    );

    state = AsyncData([...(state.value ?? []), tempMsg]);
    
    _isTyping = true;
    state = AsyncData(state.value ?? []);

    try {
      ConversationModel response;
      // Chỉ gọi startConversation nếu chưa có realConversationId
      if (_effectiveId == 'new') {
        response = await repo.startConversation(
          SendMessageCommand(message: text),
        );
        // Lưu lại ID thật để các tin nhắn sau dùng sendMessage
        _realConversationId = response.id;
        ref.read(conversationListProvider.notifier).refresh();
      } else {
        response = await repo.sendMessage(
          _effectiveId,
          SendMessageCommand(message: text),
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
            
            final msgsWithoutCurrentStreaming = currentMessages.where((m) => m.id != lastMsg.id).toList();
            
            state = AsyncData([...msgsWithoutCurrentStreaming, streamingMsg]);
            await Future.delayed(const Duration(milliseconds: 30));
          }
        } else {
          state = AsyncData([...currentMessages, lastMsg]);
        }
      }
    } catch (e, st) {
      _isTyping = false;
      // Hiển thị lỗi dưới dạng tin nhắn bot thân thiện
      final errorMsg = ChatMessageModel(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: _effectiveId,
        sender: 'Bot',
        content: e.toString().replaceAll('ServerException: ', '').replaceAll('Exception: ', ''),
        createdAt: DateTime.now(),
      );
      state = AsyncData([...(state.value ?? []), errorMsg]);
      debugPrint('=== CHAT ERROR ===');
      debugPrint(e.toString());
      debugPrint(st.toString());
    }
  }
}
