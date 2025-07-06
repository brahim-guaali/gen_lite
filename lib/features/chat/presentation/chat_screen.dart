import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_events.dart';
import 'package:genlite/features/chat/bloc/chat_states.dart';
import 'package:genlite/shared/models/message.dart';
import 'package:genlite/shared/widgets/loading_indicator.dart';
import 'package:genlite/core/constants/app_constants.dart';

import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';
import 'package:genlite/features/chat/widgets/chat_welcome_message.dart';
import 'package:genlite/features/chat/widgets/chat_error_message.dart';
import 'package:genlite/features/chat/widgets/chat_message_list.dart';
import 'package:genlite/features/chat/widgets/voice_status_indicator.dart';
import 'package:genlite/features/chat/widgets/chat_input_bar.dart';
import 'package:genlite/features/chat/widgets/chat_app_bar_title.dart';
import 'package:genlite/features/chat/widgets/agent_switcher_menu.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppConstants.animationMedium,
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    context.read<ChatBloc>().add(SendMessage(content: text.trim()));
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Chat'),
          content: const Text('What would you like to clear?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ChatBloc>().add(ClearCurrentConversation());
              },
              child: const Text('Current Chat'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showConfirmClearAllDialog(context);
              },
              child: const Text('All Chats'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Chats'),
          content: const Text(
            'This will permanently delete all your conversations. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ChatBloc>().add(ClearAllConversations());
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ChatAppBarTitle(),
        actions: [
          // Voice status indicator
          BlocBuilder<VoiceBloc, VoiceState>(
            builder: (context, voiceState) =>
                VoiceStatusIndicator(voiceState: voiceState),
          ),
          // Clear chat menu
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, chatState) {
              if (chatState is ChatLoaded &&
                  chatState.currentConversation.messages.isNotEmpty) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'clear') {
                      _showClearChatDialog(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Clear Chat'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const AgentSwitcherMenu(),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<VoiceBloc, VoiceState>(
            listener: (context, voiceState) {
              if (voiceState is VoiceReady && voiceState.isListening) {
                // Voice input is active, could show a snackbar or other feedback
              }
            },
          ),
          BlocListener<ChatBloc, ChatState>(
            listener: (context, chatState) {
              if (chatState is ChatLoaded &&
                  chatState.currentConversation.messages.isNotEmpty) {
                final lastMessage = chatState.currentConversation.messages.last;
                final voiceState = context.read<VoiceBloc>().state;

                // Auto-speak AI responses when voice output is enabled
                if (lastMessage.role == MessageRole.assistant &&
                    voiceState is VoiceReady &&
                    voiceState.voiceOutputEnabled &&
                    !chatState.isProcessing) {
                  context.read<VoiceBloc>().add(SpeakText(lastMessage.content));
                }
              }
            },
          ),
        ],
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: LoadingIndicator(),
                    );
                  }

                  if (state is ChatError) {
                    return ChatErrorMessage(message: state.message);
                  }

                  if (state is ChatInitial) {
                    // Show welcome message when no conversations exist
                    return const ChatWelcomeMessage();
                  }

                  if (state is ChatLoaded) {
                    final messages = state.currentConversation.messages;

                    if (messages.isEmpty) {
                      // Show a welcome message for empty conversation
                      return const ChatWelcomeMessage();
                    }

                    return ChatMessageList(
                      messages: messages,
                      isProcessing: state.isProcessing,
                      scrollController: _scrollController,
                    );
                  }

                  return const Center(
                    child: LoadingIndicator(),
                  );
                },
              ),
            ),
            ChatInputBar(
              messageController: _messageController,
              isComposing: _isComposing,
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: _handleSubmitted,
              onAttach: () {
                // TODO: Implement file upload
              },
            ),
          ],
        ),
      ),
    );
  }
}
