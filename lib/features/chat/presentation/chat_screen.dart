import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_events.dart';
import '../bloc/chat_states.dart';
import '../../../shared/models/message.dart';
import '../../../shared/widgets/message_bubble.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../../shared/widgets/voice_components.dart'
    hide VoiceStatusIndicator;
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
        title: BlocBuilder<AgentBloc, AgentState>(
          builder: (context, agentState) {
            if (agentState is AgentLoaded && agentState.activeAgent != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GenLite'),
                  Text(
                    agentState.activeAgent!.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              );
            }
            return const Text('GenLite');
          },
        ),
        actions: [
          // Voice status indicator
          BlocBuilder<VoiceBloc, VoiceState>(
            builder: (context, voiceState) =>
                VoiceStatusIndicator(voiceState: voiceState),
          ),
          BlocBuilder<AgentBloc, AgentState>(
            builder: (context, agentState) {
              if (agentState is AgentLoaded && agentState.agents.isNotEmpty) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.smart_toy),
                  tooltip: 'Switch Agent',
                  onSelected: (agentId) {
                    if (agentId == 'none') {
                      context.read<AgentBloc>().add(const SetActiveAgent(''));
                    } else {
                      context.read<AgentBloc>().add(SetActiveAgent(agentId));
                    }
                  },
                  itemBuilder: (context) => [
                    ...agentState.agents.map((agent) => PopupMenuItem(
                          value: agent.id,
                          child: Row(
                            children: [
                              Icon(
                                Icons.smart_toy,
                                size: 16,
                                color: agentState.activeAgent?.id == agent.id
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(agent.name)),
                              if (agentState.activeAgent?.id == agent.id)
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                        )),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'none',
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 8),
                          const Text('Default AI'),
                          if (agentState.activeAgent == null)
                            Icon(
                              Icons.check,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
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
