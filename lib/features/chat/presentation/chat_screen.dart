import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_events.dart';
import '../bloc/chat_states.dart';
import '../../../shared/models/message.dart';
import '../../../shared/widgets/message_bubble.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../../shared/widgets/voice_components.dart';
import '../../../core/constants/app_constants.dart';
import '../../settings/bloc/agent_bloc.dart';
import '../../settings/bloc/agent_events.dart';
import '../../settings/bloc/agent_states.dart';
import '../../voice/bloc/voice_bloc.dart';
import '../../voice/bloc/voice_event.dart';
import '../../voice/bloc/voice_state.dart';

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
            builder: (context, voiceState) {
              if (voiceState is VoiceReady && voiceState.isListening) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Listening',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (voiceState is VoiceReady && voiceState.voiceOutputEnabled) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.volume_up,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Voice On',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
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
                    return Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppIcon(
                              icon: Icons.error_outline,
                              size: 64,
                              color: AppConstants.errorColor,
                            ),
                            AppSpacing.md,
                            Text(
                              'Error',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.errorColor,
                                  ),
                            ),
                            AppSpacing.sm,
                            Text(
                              state.message,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.lg,
                            // Remove the button, just show error
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is ChatLoaded) {
                    final messages = state.currentConversation.messages;

                    if (messages.isEmpty) {
                      // Show a welcome message, but no button
                      return _buildWelcomeMessage();
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];

                        // Check if this is the last message and it's an assistant message being streamed
                        final isLastMessage = index == messages.length - 1;
                        final isStreamingAssistant = isLastMessage &&
                            message.role == MessageRole.assistant &&
                            state.isProcessing;

                        return MessageBubble(
                          message: message,
                          isStreaming: isStreamingAssistant,
                        );
                      },
                    );
                  }

                  return const Center(
                    child: LoadingIndicator(),
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              icon: Icons.chat_bubble_outline,
              size: 80,
              color: AppConstants.primaryColor.withOpacity(0.5),
            ),
            AppSpacing.lg,
            Text(
              'Welcome to GenLite',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
            ),
            AppSpacing.md,
            Text(
              'Your offline AI assistant is ready to help. Start chatting below.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.xl,
            // No button here
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: _isComposing ? _handleSubmitted : null,
              decoration: InputDecoration(
                hintText: 'Type a message or tap the mic...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
                isDense: true,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 4),
          BlocListener<VoiceBloc, VoiceState>(
            listener: (context, voiceState) {
              if (voiceState is VoiceReady && voiceState.isListening) {
                // Handle voice input received
              }
            },
            child: VoiceInputButton(
              onVoiceInput: (text) {
                _messageController.text = text;
                _handleSubmitted(text);
              },
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO: Implement file upload
            },
            tooltip: 'Attach file',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isComposing
                ? () => _handleSubmitted(_messageController.text)
                : null,
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}
