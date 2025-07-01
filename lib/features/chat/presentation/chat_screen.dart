import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_events.dart';
import '../bloc/chat_states.dart';
import '../../../shared/models/conversation.dart';
import '../../../shared/models/message.dart';
import '../../../shared/widgets/message_bubble.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../../core/constants/app_constants.dart';
import '../../settings/bloc/agent_bloc.dart';
import '../../settings/bloc/agent_events.dart';
import '../../settings/bloc/agent_states.dart';

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
  void initState() {
    super.initState();
    context
        .read<ChatBloc>()
        .add(const CreateNewConversation(title: 'New Conversation'));
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
          BlocBuilder<AgentBloc, AgentState>(
            builder: (context, agentState) {
              if (agentState is AgentLoaded && agentState.agents.isNotEmpty) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.smart_toy),
                  tooltip: 'Switch Agent',
                  onSelected: (agentId) {
                    if (agentId == 'none') {
                      context.read<AgentBloc>().add(SetActiveAgent(''));
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
      body: Column(
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
                  return const Center(
                    child: LoadingIndicator(),
                  );
                }

                if (state is ChatLoading) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                }

                if (state is ChatError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcon(
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
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.lg,
                          PrimaryButton(
                            text: 'Start New Conversation',
                            icon: Icons.add,
                            onPressed: () {
                              context.read<ChatBloc>().add(
                                    const CreateNewConversation(
                                        title: 'New Conversation'),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ChatLoaded) {
                  final messages = state.currentConversation.messages;

                  if (messages.isEmpty) {
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
              'Your offline AI assistant is ready to help.\nStart a conversation below.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.xl,
            _buildQuickStartButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartButtons() {
    final quickPrompts = [
      'Help me write a professional email',
      'Explain a complex topic simply',
      'Brainstorm ideas for a project',
      'Help me learn something new',
    ];

    return Column(
      children: quickPrompts.map((prompt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
          child: SecondaryButton(
            text: prompt,
            onPressed: () => _handleSubmitted(prompt),
            isFullWidth: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
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
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                // TODO: Implement file upload
              },
              tooltip: 'Attach file',
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isComposing
                  ? () => _handleSubmitted(_messageController.text)
                  : null,
              tooltip: 'Send message',
            ),
          ],
        ),
      ),
    );
  }
}
