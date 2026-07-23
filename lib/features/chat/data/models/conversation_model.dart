import 'package:json_annotation/json_annotation.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel {
  final String id;
  final String title;
  final String? externalCustomerId;
  final String? tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessageModel>? messages;

  ConversationModel({
    required this.id,
    required this.title,
    this.externalCustomerId,
    this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);
}

@JsonSerializable()
class ChatMessageModel {
  final String id;
  final String conversationId;
  final String sender;
  final String content;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);
}

@JsonSerializable(createToJson: false)
class ConversationListResponse {
  final List<ConversationModel> items;
  final int pageIndex;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  ConversationListResponse({
    required this.items,
    required this.pageIndex,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationListResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class MessageListResponse {
  final List<ChatMessageModel> items;
  final String? nextCursor;

  MessageListResponse({required this.items, this.nextCursor});

  factory MessageListResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageListResponseFromJson(json);
}

@JsonSerializable(createFactory: false)
class SendMessageCommand {
  final String message;

  SendMessageCommand({required this.message});

  Map<String, dynamic> toJson() => _$SendMessageCommandToJson(this);
}
