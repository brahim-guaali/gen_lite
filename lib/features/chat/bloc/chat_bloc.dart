import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:genlite/shared/models/conversation.dart';
import 'package:genlite/shared/models/message.dart';
import 'package:genlite/shared/services/llm_service.dart';
import '../../settings/models/agent_model.dart';
import 'chat_events.dart';
import 'chat_states.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final LLMService _llmService = LLMService();
  InferenceChat? _currentChat;
  AgentModel? _activeAgent;

  ChatBloc() : super(ChatInitial()) {
    on<CreateNewConversation>(_onCreateNewConversation);
    on<SendMessage>(_onSendMessage);
    on<LoadConversation>(_onLoadConversation);
    on<UpdateConversationTitle>(_onUpdateConversationTitle);
    on<ArchiveConversation>(_onArchiveConversation);
    on<DeleteConversation>(_onDeleteConversation);
    on<UpdateStreamingMessage>(_onUpdateStreamingMessage);
  }

  // Method to set the active agent from outside the bloc
  void setActiveAgent(AgentModel? agent) {
    _activeAgent = agent;
    print('[ChatBloc] Active agent set to: ${agent?.name ?? 'None'}');
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

    print('[ChatBloc] Starting to process message: "${event.content}"');

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

    // Create initial AI message for streaming
    final initialAiMessage = Message.create(
      content: '',
      role: MessageRole.assistant,
      conversationId: updatedConversation.id,
    );

    final conversationWithAiMessage = updatedConversation.copyWith(
      messages: [...updatedConversation.messages, initialAiMessage],
    );

    final conversationsWithAiMessage = updatedConversations.map((conv) {
      if (conv.id == conversationWithAiMessage.id) {
        return conversationWithAiMessage;
      }
      return conv;
    }).toList();

    // Emit processing state with empty AI message
    print('[ChatBloc] Emitting processing state with streaming message...');
    emit(currentState.copyWith(
      currentConversation: conversationWithAiMessage,
      conversations: conversationsWithAiMessage,
      isProcessing: true,
    ));

    try {
      print('[ChatBloc] Checking if LLM service is ready...');
      // Ensure LLM service is ready
      if (!_llmService.isReady) {
        print('[ChatBloc] LLM service not ready, initializing...');
        await _llmService.initialize();
        print('[ChatBloc] LLM service initialization completed');
      } else {
        print('[ChatBloc] LLM service is already ready');
      }

      // Create or get chat session
      print('[ChatBloc] Creating/getting chat session...');
      if (_currentChat == null) {
        _currentChat = await _llmService.createChat();
        if (_currentChat == null) {
          throw Exception('Failed to create chat session');
        }
        print('[ChatBloc] New chat session created');
      } else {
        print('[ChatBloc] Using existing chat session');
      }

      // Log active agent status
      print('[ChatBloc] Active agent: ${_activeAgent?.name ?? 'None'}');

      // Prepare the message with agent context if available
      String messageToSend = event.content;
      if (_activeAgent != null && _activeAgent!.systemPrompt.isNotEmpty) {
        // Prepend the agent's system prompt to provide context
        messageToSend = '${_activeAgent!.systemPrompt}\n\nUser: $event.content';
        print(
            '[ChatBloc] Using agent "${_activeAgent!.name}" with system prompt');
      }

      // Process message with AI using streaming
      print(
          '[ChatBloc] Calling LLM service to process message with streaming...');
      final aiResponse = await _llmService.processMessage(
        messageToSend,
        chat: _currentChat,
        onTokenReceived: (token) {
          // Emit token update event
          add(UpdateStreamingMessage(token: token));
        },
      );

      print(
          '[ChatBloc] LLM service response completed: ${aiResponse?.substring(0, aiResponse.length > 100 ? 100 : aiResponse.length)}...');

      if (aiResponse == null) {
        throw Exception('Failed to get AI response');
      }

      // Final state update (no longer processing)
      final finalConversation = conversationWithAiMessage.copyWith(
        messages: conversationWithAiMessage.messages.map((msg) {
          if (msg.role == MessageRole.assistant && msg.content.isEmpty) {
            return msg.copyWith(content: aiResponse);
          }
          return msg;
        }).toList(),
      );

      final finalConversations = conversationsWithAiMessage.map((conv) {
        if (conv.id == finalConversation.id) {
          return finalConversation;
        }
        return conv;
      }).toList();

      print('[ChatBloc] Emitting final state with completed AI response...');
      emit(currentState.copyWith(
        currentConversation: finalConversation,
        conversations: finalConversations,
        isProcessing: false,
      ));
    } catch (e) {
      print('[ChatBloc] Error processing message: $e');

      // Add error message
      final errorMessage = Message.create(
        content:
            'Sorry, I encountered an error while processing your message. Please try again.',
        role: MessageRole.assistant,
        conversationId: updatedConversation.id,
      );

      final finalConversation = updatedConversation.copyWith(
        messages: [...updatedConversation.messages, errorMessage],
      );

      final finalConversations = updatedConversations.map((conv) {
        if (conv.id == finalConversation.id) {
          return finalConversation;
        }
        return conv;
      }).toList();

      print('[ChatBloc] Emitting error state...');
      emit(currentState.copyWith(
        currentConversation: finalConversation,
        conversations: finalConversations,
        isProcessing: false,
      ));
    }
  }

  void _onUpdateStreamingMessage(
    UpdateStreamingMessage event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final messages = currentState.currentConversation.messages;

    if (messages.isEmpty) return;

    // Find the last assistant message (which should be the streaming one)
    final lastMessage = messages.last;
    if (lastMessage.role != MessageRole.assistant) return;

    // Update the last message with the new token
    final updatedMessage = lastMessage.copyWith(
      content: lastMessage.content + event.token,
    );

    final updatedMessages = [...messages];
    updatedMessages[updatedMessages.length - 1] = updatedMessage;

    final updatedConversation = currentState.currentConversation.copyWith(
      messages: updatedMessages,
    );

    final updatedConversations = currentState.conversations.map((conv) {
      if (conv.id == updatedConversation.id) {
        return updatedConversation;
      }
      return conv;
    }).toList();

    emit(currentState.copyWith(
      currentConversation: updatedConversation,
      conversations: updatedConversations,
      isProcessing: true, // Keep processing until complete
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
      emit(const ChatError(
          'Failed to load conversation: Bad state: No element'));
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

  @override
  Future<void> close() {
    _currentChat = null;
    return super.close();
  }
}
