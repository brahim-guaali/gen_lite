import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/shared/models/conversation.dart';
import 'package:genlite/shared/models/message.dart';
import 'chat_events.dart';
import 'chat_states.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<CreateNewConversation>(_onCreateNewConversation);
    on<SendMessage>(_onSendMessage);
    on<LoadConversation>(_onLoadConversation);
    on<UpdateConversationTitle>(_onUpdateConversationTitle);
    on<ArchiveConversation>(_onArchiveConversation);
    on<DeleteConversation>(_onDeleteConversation);
  }

  void _onCreateNewConversation(
    CreateNewConversation event,
    Emitter<ChatState> emit,
  ) {
    final newConversation = Conversation.create(title: event.title);

    if (state is ChatInitial) {
      emit(ChatLoaded(
        currentConversation: newConversation,
        conversations: [newConversation],
      ));
    } else if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(ChatLoaded(
        currentConversation: newConversation,
        conversations: [...currentState.conversations, newConversation],
      ));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final userMessage = Message.create(
      content: event.content,
      role: MessageRole.user,
      conversationId: currentState.currentConversation.id,
    );

    // Add user message to conversation
    final updatedConversation = currentState.currentConversation.copyWith(
      messages: [...currentState.currentConversation.messages, userMessage],
    );

    // Update conversations list
    final updatedConversations = currentState.conversations.map((conv) {
      if (conv.id == updatedConversation.id) {
        return updatedConversation;
      }
      return conv;
    }).toList();

    // Emit processing state
    emit(currentState.copyWith(
      currentConversation: updatedConversation,
      conversations: updatedConversations,
      isProcessing: true,
    ));

    // Simulate AI response
    await Future.delayed(const Duration(milliseconds: 100));

    final aiResponse = Message.create(
      content: _generateMockResponse(event.content),
      role: MessageRole.assistant,
      conversationId: updatedConversation.id,
    );

    final finalConversation = updatedConversation.copyWith(
      messages: [...updatedConversation.messages, aiResponse],
    );

    final finalConversations = updatedConversations.map((conv) {
      if (conv.id == finalConversation.id) {
        return finalConversation;
      }
      return conv;
    }).toList();

    emit(currentState.copyWith(
      currentConversation: finalConversation,
      conversations: finalConversations,
      isProcessing: false,
    ));
  }

  void _onLoadConversation(
    LoadConversation event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final conversation = currentState.conversations
        .where((conv) => conv.id == event.conversationId)
        .firstOrNull;

    if (conversation != null) {
      emit(currentState.copyWith(currentConversation: conversation));
    } else {
      emit(ChatError('Failed to load conversation: Bad state: No element'));
    }
  }

  void _onUpdateConversationTitle(
    UpdateConversationTitle event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final updatedConversations = currentState.conversations.map((conv) {
      if (conv.id == event.conversationId) {
        return conv.copyWith(title: event.newTitle);
      }
      return conv;
    }).toList();

    final updatedCurrentConversation =
        currentState.currentConversation.id == event.conversationId
            ? currentState.currentConversation.copyWith(title: event.newTitle)
            : currentState.currentConversation;

    emit(currentState.copyWith(
      currentConversation: updatedCurrentConversation,
      conversations: updatedConversations,
    ));
  }

  void _onArchiveConversation(
    ArchiveConversation event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final updatedConversations = currentState.conversations.map((conv) {
      if (conv.id == event.conversationId) {
        return conv.copyWith(isArchived: true);
      }
      return conv;
    }).toList();

    emit(currentState.copyWith(conversations: updatedConversations));
  }

  void _onDeleteConversation(
    DeleteConversation event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final updatedConversations = currentState.conversations
        .where((conv) => conv.id != event.conversationId)
        .toList();

    if (updatedConversations.isEmpty) {
      emit(ChatInitial());
    } else {
      final newCurrentConversation =
          currentState.currentConversation.id == event.conversationId
              ? updatedConversations.first
              : currentState.currentConversation;

      emit(currentState.copyWith(
        currentConversation: newCurrentConversation,
        conversations: updatedConversations,
      ));
    }
  }

  String _generateMockResponse(String userMessage) {
    final responses = [
      'I understand you\'re asking about "$userMessage". Let me help you with that.',
      'That\'s an interesting question about "$userMessage". Here\'s what I think...',
      'Regarding "$userMessage", I can provide some insights...',
      'I\'d be happy to help you with "$userMessage". Here\'s my response...',
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }
}
