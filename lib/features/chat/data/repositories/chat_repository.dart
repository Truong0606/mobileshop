import 'package:smart_shopping_chatbot/core/network/api_client.dart';
import 'package:smart_shopping_chatbot/features/chat/data/models/conversation_model.dart';
import 'package:smart_shopping_chatbot/core/network/api_exceptions.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  ChatRepository();

  Dio get _dio => ApiClient.instance.dio;

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
        '/chat/messages',
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
        message: '${e.message} - Data: ${e.response?.data}',
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
        '/chat/$conversationId/messages',
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
      throw ServerException(
        message: '${e.message} - Data: ${e.response?.data}',
      );
    }
  }

  /// 3. Get Chat History (Infinite Scroll with Cursor)
  /// GET /api/v1/chat/conversations/{id}/messages
  Future<MessageListResponse> getMessages(
    String conversationId, {
    String? lastCursor,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (lastCursor != null) {
        queryParams['lastCursor'] = lastCursor;
      }

      final response = await _dio.get(
        '/chat/$conversationId/messages',
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
      throw ServerException(
        message: '${e.message} - Data: ${e.response?.data}',
      );
    }
  }

  /// 4. List All Conversations for a Customer
  /// GET /api/v1/chat/conversations
  Future<ConversationListResponse> getConversations({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      };

      final response = await _dio.get(
        '/chat',
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
      // Handle 404 (no conversations endpoint) or 400 "Customer not found"
      // (customer hasn't chatted yet, so no customer record exists in chat service)
      if (e.response?.statusCode == 404 ||
          (e.response?.statusCode == 400 &&
              e.response?.data?.toString().contains('Customer not found') == true)) {
        return ConversationListResponse(
          items: [],
          pageIndex: pageIndex,
          pageSize: pageSize,
          totalCount: 0,
          totalPages: 0,
        );
      }
      throw ServerException(
        message: '${e.message} - Data: ${e.response?.data}',
      );
    }
  }
}
