// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      externalCustomerId: json['externalCustomerId'] as String?,
      tenantId: json['tenantId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'externalCustomerId': instance.externalCustomerId,
      'tenantId': instance.tenantId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'messages': instance.messages,
    };

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      sender: json['sender'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'sender': instance.sender,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };

ConversationListResponse _$ConversationListResponseFromJson(
  Map<String, dynamic> json,
) => ConversationListResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  pageIndex: (json['pageIndex'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

MessageListResponse _$MessageListResponseFromJson(Map<String, dynamic> json) =>
    MessageListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$SendMessageCommandToJson(SendMessageCommand instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
