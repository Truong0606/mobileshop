import 'package:equatable/equatable.dart';

/// Represents a chat conversation (thread) in the sidebar/history.
class Conversation extends Equatable {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int messageCount;

  const Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    this.messageCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    lastMessage,
    lastMessageTime,
    messageCount,
  ];
}
