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
      return ConversationModel.fromJson(response.data['data'] ?? response.data);
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
      return ConversationModel.fromJson(response.data['data'] ?? response.data);
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
        ?'lastCursor': lastCursor,
      };

      final response = await _dio.get(
        '/chat/conversations/$conversationId/messages',
        queryParameters: queryParams,
      );

      // Usually API response is wrapped in 'data'
      final json = response.data['data'] ?? response.data;
      return MessageListResponse.fromJson(json);
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
      return ConversationListResponse.fromJson(json);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to list conversations',
      );
    }
  }
}
