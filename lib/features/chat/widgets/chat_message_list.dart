import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/message.dart';
import '../../../shared/widgets/message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<Message> messages;
  final bool isProcessing;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.isProcessing,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isLastMessage = index == messages.length - 1;
        final isStreamingAssistant = isLastMessage &&
            message.role == MessageRole.assistant &&
            isProcessing;
        return MessageBubble(
          message: message,
          isStreaming: isStreamingAssistant,
        );
      },
    );
  }
}
