import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

/// The type of content a chat message carries.
enum MessageType {
  text,
  productCard,
  productList,
  comparison,
  faq,
  loading,
  error,
}

/// The user's feedback on a bot message.
enum FeedbackType { none, thumbsUp, thumbsDown }

/// Represents a single message within a chat conversation.
class Message extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType messageType;
  final List<Product>? products;
  final FeedbackType feedbackType;

  const Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.products,
    this.feedbackType = FeedbackType.none,
  });

  /// Creates a copy of this message with the given fields replaced.
  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? messageType,
    List<Product>? products,
    FeedbackType? feedbackType,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      products: products ?? this.products,
      feedbackType: feedbackType ?? this.feedbackType,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    isUser,
    timestamp,
    messageType,
    products,
    feedbackType,
  ];
}
