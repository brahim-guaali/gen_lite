import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_events.dart';
import '../bloc/chat_states.dart';
import '../../../shared/models/message.dart';
import '../../../shared/models/conversation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/message_bubble.dart';
import '../../../shared/widgets/loading_indicator.dart';

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
    // Create initial conversation if none exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatBloc = context.read<ChatBloc>();
      if (chatBloc.state is ChatInitial) {
        chatBloc.add(const CreateNewConversation(title: 'New Conversation'));
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

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoaded) {
              return Text(
                state.currentConversation.title,
                style: const TextStyle(fontSize: 18),
              );
            }
            return const Text('GenLite');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<ChatBloc>().add(
                    const CreateNewConversation(title: 'New Conversation'),
                  );
            },
            tooltip: 'New Conversation',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
            tooltip: 'Settings',
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppConstants.errorColor,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ChatBloc>().add(
                                  const CreateNewConversation(
                                      title: 'New Conversation'),
                                );
                          },
                          child: const Text('Start New Conversation'),
                        ),
                      ],
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
                    itemCount: messages.length + (state.isProcessing ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && state.isProcessing) {
                        return const Padding(
                          padding: EdgeInsets.all(AppConstants.paddingMedium),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: AppConstants.paddingMedium),
                              Text('AI is thinking...'),
                            ],
                          ),
                        );
                      }

                      final message = messages[index];
                      return MessageBubble(message: message);
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
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppConstants.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              'Welcome to GenLite',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppConstants.primaryColor,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Your offline AI assistant is ready to help.\nStart a conversation below.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingXLarge),
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
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _handleSubmitted(prompt),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                alignment: Alignment.centerLeft,
              ),
              child: Text(prompt),
            ),
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
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
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
            Container(
              decoration: BoxDecoration(
                color: _isComposing
                    ? AppConstants.primaryColor
                    : AppConstants.primaryColor.withOpacity(0.3),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_messageController.text)
                    : null,
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
