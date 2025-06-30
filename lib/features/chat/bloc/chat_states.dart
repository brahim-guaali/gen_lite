import 'package:equatable/equatable.dart';
import 'package:genlite/shared/models/conversation.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final Conversation currentConversation;
  final List<Conversation> conversations;
  final bool isProcessing;

  const ChatLoaded({
    required this.currentConversation,
    required this.conversations,
    this.isProcessing = false,
  });

  ChatLoaded copyWith({
    Conversation? currentConversation,
    List<Conversation>? conversations,
    bool? isProcessing,
  }) {
    return ChatLoaded(
      currentConversation: currentConversation ?? this.currentConversation,
      conversations: conversations ?? this.conversations,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [currentConversation, conversations, isProcessing];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
