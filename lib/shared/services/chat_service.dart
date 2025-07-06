import 'dart:async';
import 'package:genlite/shared/models/message.dart';
import 'package:genlite/shared/models/conversation.dart';
import 'package:genlite/features/settings/models/agent_model.dart';
import 'package:genlite/shared/services/storage_service.dart';
import 'package:genlite/shared/services/llm_service.dart';
import 'package:genlite/shared/services/tts_service.dart';
import 'package:genlite/shared/utils/logger.dart';
import 'package:hive/hive.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // In-memory storage for current session
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  AgentModel? _activeAgent;
  bool _isInitialized = false;

  // Getters for current data
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  Conversation? get currentConversation => _currentConversation;
  AgentModel? get activeAgent => _activeAgent;

  // Initialize service
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info(LogTags.chatService, 'ChatService already initialized');
      return;
    }

    try {
      Logger.info(LogTags.chatService, 'Initializing ChatService');
      await _loadConversations();
      _isInitialized = true;
      Logger.info(LogTags.chatService, 'ChatService initialized successfully');
    } catch (e) {
      Logger.error(LogTags.chatService, 'Error loading conversations',
          error: e);
      rethrow;
    }
  }

  // Load conversations from persistent storage
  Future<void> _loadConversations() async {
    try {
      Logger.info(LogTags.chatService, 'Loading conversations from storage');
      // Use the dedicated loadConversations method instead of getSetting
      final conversationsData = await StorageService.loadConversations();
      Logger.info(LogTags.chatService,
          'Loaded ${conversationsData.length} conversations from storage');

      _conversations =
          conversationsData.map((data) => Conversation.fromJson(data)).toList();

      // Load current conversation
      final currentConversationId =
          await StorageService.getSetting<String>('current_conversation_id');
      if (currentConversationId != null) {
        Logger.info(LogTags.chatService,
            'Loading current conversation: $currentConversationId');
        _currentConversation = _conversations.firstWhere(
          (conv) => conv.id == currentConversationId,
          orElse: () => _conversations.isNotEmpty
              ? _conversations.first
              : throw Exception('Conversation not found'),
        );
      } else {
        Logger.info(LogTags.chatService, 'No current conversation ID found');
      }
    } catch (e) {
      Logger.error(LogTags.chatService, 'Error loading conversations',
          error: e);
      rethrow;
    }
  }

  // Create new conversation
  Future<Conversation> createConversation({required String title}) async {
    // Validate title
    if (title.trim().isEmpty) {
      throw Exception('Conversation title cannot be empty');
    }

    final conversation = Conversation.create(
      title: title.trim(),
      messages: [],
    );

    _conversations.insert(0, conversation);
    _currentConversation = conversation;

    // Save to persistent storage
    await _saveConversations();

    return conversation;
  }

  // Send message and get updated conversation
  Future<Conversation> sendMessage({
    required String content,
    required String conversationId,
  }) async {
    // Find the conversation
    final conversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => throw Exception('Conversation not found: $conversationId'),
    );

    // Create user message
    final userMessage = Message.create(
      content: content,
      role: MessageRole.user,
      conversationId: conversation.id,
    );

    // Add user message to conversation
    final updatedConversation = conversation.copyWith(
      messages: [...conversation.messages, userMessage],
    );

    // Update in-memory storage
    final index =
        _conversations.indexWhere((conv) => conv.id == conversationId);
    if (index != -1) {
      _conversations[index] = updatedConversation;
    }

    _currentConversation = updatedConversation;

    // Save to persistent storage
    await _saveConversations();

    return updatedConversation;
  }

  // Add AI response to conversation
  Future<Conversation> addAIResponse({
    required String conversationId,
    required String response,
  }) async {
    final conversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => throw Exception('Conversation not found: $conversationId'),
    );

    // Create AI message
    final aiMessage = Message.create(
      content: response,
      role: MessageRole.assistant,
      conversationId: conversation.id,
    );

    // Add AI message to conversation
    final updatedConversation = conversation.copyWith(
      messages: [...conversation.messages, aiMessage],
    );

    // Update in-memory storage
    final index =
        _conversations.indexWhere((conv) => conv.id == conversationId);
    if (index != -1) {
      _conversations[index] = updatedConversation;
    }

    _currentConversation = updatedConversation;

    // Save to persistent storage
    await _saveConversations();

    return updatedConversation;
  }

  // Update streaming message
  Future<Conversation> updateStreamingMessage({
    required String conversationId,
    required String token,
  }) async {
    final conversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => throw Exception('Conversation not found: $conversationId'),
    );

    // Find the last AI message or create a new one
    List<Message> updatedMessages = List.from(conversation.messages);

    if (updatedMessages.isNotEmpty &&
        updatedMessages.last.role == MessageRole.assistant) {
      // Update existing AI message
      final lastMessage = updatedMessages.last;
      updatedMessages[updatedMessages.length - 1] = lastMessage.copyWith(
        content: lastMessage.content + token,
      );
    } else {
      // Create new AI message
      final aiMessage = Message.create(
        content: token,
        role: MessageRole.assistant,
        conversationId: conversation.id,
      );
      updatedMessages.add(aiMessage);
    }

    final updatedConversation = conversation.copyWith(
      messages: updatedMessages,
    );

    // Update in-memory storage
    final index =
        _conversations.indexWhere((conv) => conv.id == conversationId);
    if (index != -1) {
      _conversations[index] = updatedConversation;
    }

    _currentConversation = updatedConversation;

    // Save to persistent storage
    await _saveConversations();

    return updatedConversation;
  }

  // Load specific conversation
  Future<Conversation?> loadConversation(String conversationId) async {
    try {
      final conversation = _conversations.firstWhere(
        (conv) => conv.id == conversationId,
        orElse: () => throw Exception('Conversation not found'),
      );

      if (conversation != null) {
        _currentConversation = conversation;
        await _saveConversations();
      }

      return conversation;
    } catch (e) {
      Logger.error(LogTags.chatService, 'Error loading conversation', error: e);
      return null;
    }
  }

  // Update conversation title
  Future<Conversation> updateConversationTitle({
    required String conversationId,
    required String newTitle,
  }) async {
    if (newTitle.trim().isEmpty) {
      throw Exception('Conversation title cannot be empty');
    }

    final conversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => throw Exception('Conversation not found: $conversationId'),
    );

    final updatedConversation = conversation.copyWith(
      title: newTitle.trim(),
    );

    // Update in-memory storage
    final index =
        _conversations.indexWhere((conv) => conv.id == conversationId);
    if (index != -1) {
      _conversations[index] = updatedConversation;
    }

    if (_currentConversation?.id == conversationId) {
      _currentConversation = updatedConversation;
    }

    // Save to persistent storage
    await _saveConversations();

    return updatedConversation;
  }

  // Archive conversation
  Future<void> archiveConversation(String conversationId) async {
    final conversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => throw Exception('Conversation not found: $conversationId'),
    );

    final updatedConversation = conversation.copyWith(
      isArchived: true,
    );

    // Update in-memory storage
    final index =
        _conversations.indexWhere((conv) => conv.id == conversationId);
    if (index != -1) {
      _conversations[index] = updatedConversation;
    }

    if (_currentConversation?.id == conversationId) {
      _currentConversation = null;
    }

    // Save to persistent storage
    await _saveConversations();
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    _conversations.removeWhere((conv) => conv.id == conversationId);

    if (_currentConversation?.id == conversationId) {
      _currentConversation =
          _conversations.isNotEmpty ? _conversations.first : null;
    }

    // Save to persistent storage
    await _saveConversations();
  }

  // Set active agent
  void setActiveAgent(AgentModel? agent) {
    _activeAgent = agent;
    Logger.info(
        LogTags.chatService, 'Active agent set to: ${agent?.name ?? 'None'}');
  }

  // Get current data for events
  ChatData getCurrentData() {
    if (!_isInitialized) {
      Logger.warning(
          LogTags.chatService, 'getCurrentData called before initialization');
      return const ChatData(conversations: []);
    }

    return ChatData(
      conversations: _conversations,
      currentConversation: _currentConversation,
      activeAgent: _activeAgent,
    );
  }

  // Save conversations to persistent storage
  Future<void> _saveConversations() async {
    try {
      // Clear existing conversations and save each one individually
      final box = Hive.box('conversations');
      await box.clear();

      for (final conversation in _conversations) {
        await box.put(conversation.id, conversation.toJson());
      }

      // Save current conversation ID to settings
      if (_currentConversation != null) {
        await StorageService.saveSetting(
            'current_conversation_id', _currentConversation!.id);
      }
    } catch (e) {
      Logger.error(LogTags.chatService, 'Error saving conversations', error: e);
      rethrow;
    }
  }

  // Check if service is initialized
  bool get isInitialized => _isInitialized;
}

// Data class to pass current state information
class ChatData {
  final List<Conversation> conversations;
  final Conversation? currentConversation;
  final AgentModel? activeAgent;

  const ChatData({
    required this.conversations,
    this.currentConversation,
    this.activeAgent,
  });
}
