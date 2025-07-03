import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:genlite/shared/models/message.dart';
import 'package:genlite/shared/services/llm_service.dart';
import 'package:genlite/shared/services/chat_service.dart';
import '../../settings/models/agent_model.dart';
import 'chat_events.dart';
import 'chat_states.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final LLMService _llmService = LLMService();
  final ChatService _chatService = ChatService();
  InferenceChat? _currentChat;

  ChatBloc() : super(ChatInitial()) {
    on<CreateNewConversation>(_onCreateNewConversation);
    on<SendMessage>(_onSendMessage);
    on<LoadConversation>(_onLoadConversation);
    on<UpdateConversationTitle>(_onUpdateConversationTitle);
    on<ArchiveConversation>(_onArchiveConversation);
    on<DeleteConversation>(_onDeleteConversation);
    on<UpdateStreamingMessage>(_onUpdateStreamingMessage);

    // Initialize the service
    _chatService.initialize();
  }

  // Method to set the active agent from outside the bloc
  void setActiveAgent(AgentModel? agent) {
    _chatService.setActiveAgent(agent);
    print('[ChatBloc] Active agent set to: ${agent?.name ?? 'None'}');
  }

  void _onCreateNewConversation(
    CreateNewConversation event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final newConversation = await _chatService.createConversation(
        title: event.title,
      );

      final currentData = _chatService.getCurrentData();

      emit(ChatLoaded(
        currentConversation: newConversation,
        conversations: currentData.conversations,
      ));
    } catch (e) {
      emit(ChatError('Failed to create conversation: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Get current data from service
      final currentData = _chatService.getCurrentData();

      if (currentData.currentConversation == null) {
        emit(ChatError('No active conversation'));
        return;
      }

      print('[ChatBloc] Starting to process message: "${event.content}"');

      // Add user message and empty AI message to conversation via service
      final updatedConversation = await _chatService.sendMessage(
        content: event.content,
        conversationId: currentData.currentConversation!.id,
      );

      // Get updated data from service
      final updatedData = _chatService.getCurrentData();

      // Emit processing state with empty AI message
      print('[ChatBloc] Emitting processing state with streaming message...');
      emit(ChatLoaded(
        currentConversation: updatedConversation,
        conversations: updatedData.conversations,
        isProcessing: true,
      ));

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

      // Get active agent from service
      final activeAgent = _chatService.activeAgent;
      print('[ChatBloc] Active agent: ${activeAgent?.name ?? 'None'}');

      // Prepare the message with agent context if available
      String messageToSend = event.content;
      if (activeAgent != null && activeAgent.systemPrompt.isNotEmpty) {
        // Prepend the agent's system prompt to provide context
        messageToSend = '${activeAgent.systemPrompt}\n\nUser: $event.content';
        print(
            '[ChatBloc] Using agent "${activeAgent.name}" with system prompt');
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

      if (aiResponse == null || aiResponse.isEmpty) {
        throw Exception('Failed to get AI response');
      }

      // Add AI response to conversation via service
      final finalConversation = await _chatService.addAIResponse(
        conversationId: updatedConversation.id,
        response: aiResponse,
      );

      // Get final data from service
      final finalData = _chatService.getCurrentData();

      print('[ChatBloc] Emitting final state with completed AI response...');
      emit(ChatLoaded(
        currentConversation: finalConversation,
        conversations: finalData.conversations,
        isProcessing: false,
      ));
    } catch (e) {
      print('[ChatBloc] Error processing message: $e');

      // Get current data for error handling
      final currentData = _chatService.getCurrentData();

      if (currentData.currentConversation != null) {
        // Add error message via service
        final errorMessage = Message.create(
          content:
              'Sorry, I encountered an error while processing your message. Please try again.',
          role: MessageRole.assistant,
          conversationId: currentData.currentConversation!.id,
        );

        final finalConversation = currentData.currentConversation!.copyWith(
          messages: [
            ...currentData.currentConversation!.messages,
            errorMessage
          ],
        );

        print('[ChatBloc] Emitting error state...');
        emit(ChatLoaded(
          currentConversation: finalConversation,
          conversations: currentData.conversations,
          isProcessing: false,
        ));
      } else {
        emit(ChatError('Failed to process message: $e'));
      }
    }
  }

  void _onUpdateStreamingMessage(
    UpdateStreamingMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Get current data from service
      final currentData = _chatService.getCurrentData();

      if (currentData.currentConversation == null) {
        return;
      }

      // Update streaming message via service
      final updatedConversation = await _chatService.updateStreamingMessage(
        conversationId: currentData.currentConversation!.id,
        token: event.token,
      );

      // Get updated data from service
      final updatedData = _chatService.getCurrentData();

      emit(ChatLoaded(
        currentConversation: updatedConversation,
        conversations: updatedData.conversations,
        isProcessing: true, // Keep processing until complete
      ));
    } catch (e) {
      print('[ChatBloc] Error updating streaming message: $e');
    }
  }

  void _onLoadConversation(
    LoadConversation event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final conversation =
          await _chatService.loadConversation(event.conversationId);

      if (conversation != null) {
        final currentData = _chatService.getCurrentData();
        emit(ChatLoaded(
          currentConversation: conversation,
          conversations: currentData.conversations,
        ));
      } else {
        emit(const ChatError(
            'Failed to load conversation: Conversation not found'));
      }
    } catch (e) {
      emit(ChatError('Failed to load conversation: $e'));
    }
  }

  void _onUpdateConversationTitle(
    UpdateConversationTitle event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final updatedConversation = await _chatService.updateConversationTitle(
        conversationId: event.conversationId,
        newTitle: event.newTitle,
      );

      final currentData = _chatService.getCurrentData();

      emit(ChatLoaded(
        currentConversation: updatedConversation,
        conversations: currentData.conversations,
      ));
    } catch (e) {
      emit(ChatError('Failed to update conversation title: $e'));
    }
  }

  void _onArchiveConversation(
    ArchiveConversation event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.archiveConversation(event.conversationId);

      final currentData = _chatService.getCurrentData();

      if (currentData.currentConversation != null) {
        emit(ChatLoaded(
          currentConversation: currentData.currentConversation!,
          conversations: currentData.conversations,
        ));
      } else {
        emit(ChatInitial());
      }
    } catch (e) {
      emit(ChatError('Failed to archive conversation: $e'));
    }
  }

  void _onDeleteConversation(
    DeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.deleteConversation(event.conversationId);

      final currentData = _chatService.getCurrentData();

      if (currentData.currentConversation != null) {
        emit(ChatLoaded(
          currentConversation: currentData.currentConversation!,
          conversations: currentData.conversations,
        ));
      } else {
        emit(ChatInitial());
      }
    } catch (e) {
      emit(ChatError('Failed to delete conversation: $e'));
    }
  }

  @override
  Future<void> close() {
    _currentChat = null;
    return super.close();
  }
}
