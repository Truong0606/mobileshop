import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/features/chat/data/models/conversation_model.dart';
import 'package:smart_shopping_chatbot/shared/providers/chat_provider.dart';
import 'package:smart_shopping_chatbot/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:smart_shopping_chatbot/features/chat/presentation/widgets/rich_text_message.dart';
import 'package:smart_shopping_chatbot/shared/widgets/empty_state_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId, this.initialMessage});

  final String chatId;
  final String? initialMessage;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  bool _initialMessageSent = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Auto-send initialMessage after first frame
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_initialMessageSent && widget.initialMessage != null) {
          _initialMessageSent = true;
          ref
              .read(chatMessagesProvider(widget.chatId).notifier)
              .sendMessage(widget.initialMessage!);
          _scrollToBottom();
        }
      });
    }
  }

  void _onScroll() {
    // Với reverse: true, "trên cùng" (tin cũ nhất) là maxScrollExtent
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      ref.read(chatMessagesProvider(widget.chatId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    ref.read(chatMessagesProvider(widget.chatId).notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        // reverse: true nghĩa là dưới cùng màn hình có pixels = 0.0
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) {
              setState(() => _isListening = false);
              // Auto-send khi speech kết thúc và có text
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) _sendMessage();
                });
              }
            }
          }
        },
        onError: (val) {
          if (mounted) setState(() => _isListening = false);
        },
      );
      if (available) {
        if (mounted) setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _controller.text = val.recognizedWords;
              });
            }
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể truy cập Microphone.')),
          );
        }
      }
    } else {
      if (mounted) setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final notifier = ref.read(chatMessagesProvider(widget.chatId).notifier);

    return Scaffold(
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty && widget.chatId != 'new') {
                  return const Center(child: Text('No messages.'));
                }

                final reversedMessages = messages.reversed.toList();

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: reversedMessages.length + (notifier.isLoadingMore ? 1 : 0) + (notifier.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // index 0 là dưới cùng màn hình (tin mới nhất) do reverse = true
                    
                    if (notifier.isTyping && index == 0) {
                      return TypingIndicator(isDark: isDark);
                    }

                    final lastIndex = reversedMessages.length + (notifier.isLoadingMore ? 1 : 0) + (notifier.isTyping ? 1 : 0) - 1;
                    if (notifier.isLoadingMore && index == lastIndex) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final msgIndex = index - (notifier.isTyping ? 1 : 0);
                    final msg = reversedMessages[msgIndex];
                    return _buildMessageBubble(
                      context,
                      msg,
                      isDark,
                      notifier.effectiveId,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => EmptyStateWidget(
                icon: Icons.error_outline_rounded,
                title: 'Lỗi tải tin nhắn',
                message: 'Hệ thống AI đang bảo trì hoặc mất kết nối mạng. Vui lòng thử lại sau.',
                buttonText: 'Thử lại',
                onButtonPressed: () {
                  ref.invalidate(chatMessagesProvider(widget.chatId));
                },
              ),
            ),
          ),
          _buildInputBar(context, isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Shopping Assistant',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Online • Powered by RAG',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessageModel message,
    bool isDark,
    String? conversationId,
  ) {
    final senderLower = message.sender.toLowerCase();
    final isUser = senderLower == 'user' || senderLower == 'customer';

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? (isDark
                        ? AppColors.userBubbleDark
                        : AppColors.userBubbleLight)
                  : (isDark
                        ? AppColors.botBubbleDark
                        : AppColors.botBubbleLight),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: isUser
                ? Text(
                    message.content,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.userBubbleText,
                    ),
                  )
                : RichTextMessage(
                    text: message.content,
                    isDark: isDark,
                    isUser: isUser,
                    conversationId: conversationId,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              DateFormat('HH:mm').format(message.createdAt.toLocal()),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceContainer
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkOnSurface
                      : AppColors.lightOnSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Hỏi về sản phẩm...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _listen,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isListening
                    ? Colors.red.withValues(alpha: 0.1)
                    : (isDark
                        ? AppColors.darkSurfaceContainer
                        : AppColors.lightSurfaceVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening
                    ? Colors.red
                    : (isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
