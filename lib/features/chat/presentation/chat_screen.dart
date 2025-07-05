import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_events.dart';
import '../bloc/chat_states.dart';
import '../../../shared/models/message.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/constants/app_constants.dart';
import '../../settings/bloc/agent_bloc.dart';
import '../../settings/bloc/agent_events.dart';
import '../../settings/bloc/agent_states.dart';
import '../../voice/bloc/voice_bloc.dart';
import '../../voice/bloc/voice_event.dart';
import '../../voice/bloc/voice_state.dart';
import '../widgets/chat_welcome_message.dart';
import '../widgets/chat_error_message.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/voice_status_indicator.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_app_bar_title.dart';
import '../widgets/agent_switcher_menu.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  bool _hasAutoCreated = false;

  @override
  void initState() {
    super.initState();
    // Automatically create a new conversation if none exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatBloc = context.read<ChatBloc>();
      final state = chatBloc.state;
      if (state is ChatInitial && !_hasAutoCreated) {
        chatBloc.add(const CreateNewConversation(title: 'New Conversation'));
        setState(() {
          _hasAutoCreated = true;
        });
      }
    });
  }

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
                  if (state is ChatInitial) {
                    // Show a loading indicator while the conversation is being created
                    return const Center(child: LoadingIndicator());
                  }

                  if (state is ChatLoading) {
                    return const Center(
                      child: LoadingIndicator(),
                    );
                  }

                  if (state is ChatError) {
                    return ChatErrorMessage(message: state.message);
                  }

                  if (state is ChatLoaded) {
                    final messages = state.currentConversation.messages;

                    if (messages.isEmpty) {
                      // Show a welcome message, but no button
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
