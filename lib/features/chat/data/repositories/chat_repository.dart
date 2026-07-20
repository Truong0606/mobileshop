import 'package:smart_shopping_chatbot/core/config/app_config.dart';
import 'package:smart_shopping_chatbot/features/chat/data/models/conversation_model.dart';
import 'package:smart_shopping_chatbot/core/network/api_exceptions.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.instance.chatbotApiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            if (AppConfig.instance.chatbotApiKey.isNotEmpty)
              'x-api-key': AppConfig.instance.chatbotApiKey,
          },
        ),
      );

  // Helper method no longer needed since it's in BaseOptions, but we can keep empty options or remove it.

  // Helper method to add x-api-key to headers
  // Options _getOptions() {
  //   final apiKey = AppConfig.instance.chatbotApiKey;
  //   return Options(headers: {if (apiKey.isNotEmpty) 'x-api-key': apiKey});
  // }

  /// 1. Start a New Conversation
  /// POST /api/v1/chat/conversations/messages
  Future<ConversationModel> startConversation(
    SendMessageCommand command,
  ) async {
    try {
      final response = await _dio.post(
        '/chat/conversations/messages',
        data: command.toJson(),
      );
      final data = response.data['data'] ?? response.data;
      return ConversationModel(
        id: data['conversationId'] ?? '',
        title: data['conversationTitle'] ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [
          ChatMessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            conversationId: data['conversationId'] ?? '',
            sender: 'Bot',
            content: data['messageResponse'] ?? '',
            createdAt: DateTime.now(),
          )
        ],
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to start conversation',
      );
    }
  }

  /// 2. Continue an Existing Conversation
  /// POST /api/v1/chat/conversations/{id}/messages
  Future<ConversationModel> sendMessage(
    String conversationId,
    SendMessageCommand command,
  ) async {
    try {
      final response = await _dio.post(
        '/chat/conversations/$conversationId/messages',
        data: command.toJson(),
      );
      final data = response.data['data'] ?? response.data;
      return ConversationModel(
        id: data['conversationId'] ?? conversationId,
        title: data['conversationTitle'] ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [
          ChatMessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            conversationId: data['conversationId'] ?? conversationId,
            sender: 'Bot',
            content: data['messageResponse'] ?? '',
            createdAt: DateTime.now(),
          )
        ],
      );
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to send message');
    }
  }

  /// 3. Get Chat History (Infinite Scroll with Cursor)
  /// GET /api/v1/chat/conversations/{id}/messages
  Future<MessageListResponse> getMessages(
    String conversationId,
    String externalCustomerId, {
    String? lastCursor,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'externalCustomerId': externalCustomerId,
        'limit': limit,
        // ignore: use_null_aware_elements
        if (lastCursor != null) 'lastCursor': lastCursor,
      };

      final response = await _dio.get(
        '/chat/conversations/$conversationId/messages',
        queryParameters: queryParams,
      );

      final json = response.data['data'] ?? response.data;
      final itemsList = json['items'] as List? ?? [];
      return MessageListResponse(
        items: itemsList.map((e) => ChatMessageModel(
          id: e['id'] ?? '',
          conversationId: conversationId,
          sender: e['senderType'] ?? 'User',
          content: e['content'] ?? '',
          createdAt: DateTime.tryParse(e['createdAt'] ?? '') ?? DateTime.now(),
        )).toList(),
        nextCursor: json['nextCursor'],
      );
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get messages');
    }
  }

  /// 4. List All Conversations for a Customer
  /// GET /api/v1/chat/conversations
  Future<ConversationListResponse> getConversations(
    String externalCustomerId, {
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = {
        'externalCustomerId': externalCustomerId,
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      };

      final response = await _dio.get(
        '/chat/conversations',
        queryParameters: queryParams,
      );

      final json = response.data['data'] ?? response.data;
      final itemsList = json['items'] as List? ?? [];
      return ConversationListResponse(
        items: itemsList.map((e) => ConversationModel(
          id: e['id'] ?? '',
          title: e['title'] ?? '',
          createdAt: DateTime.tryParse(e['createAt'] ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(e['lastMessageAt'] ?? '') ?? DateTime.now(),
        )).toList(),
        pageIndex: json['pageIndex'] ?? pageIndex,
        pageSize: json['pageSize'] ?? pageSize,
        totalCount: json['totalItems'] ?? 0,
        totalPages: json['totalPages'] ?? 0,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ConversationListResponse(
          items: [],
          pageIndex: pageIndex,
          pageSize: pageSize,
          totalCount: 0,
          totalPages: 0,
        );
      }
      throw ServerException(
        message: e.message ?? 'Failed to list conversations',
      );
    }
  }
}
