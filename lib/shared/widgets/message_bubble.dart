import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../../core/constants/app_constants.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isStreaming;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );

    if (widget.isStreaming) {
      _typingController.repeat();
    }
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !oldWidget.isStreaming) {
      _typingController.repeat();
    } else if (!widget.isStreaming && oldWidget.isStreaming) {
      _typingController.stop();
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.paddingSmall,
        horizontal: AppConstants.paddingMedium,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppConstants.primaryColor,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: isUser ? AppConstants.primaryColor : theme.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft:
                      const Radius.circular(AppConstants.borderRadiusMedium),
                  topRight:
                      const Radius.circular(AppConstants.borderRadiusMedium),
                  bottomLeft: Radius.circular(
                    isUser
                        ? AppConstants.borderRadiusMedium
                        : AppConstants.borderRadiusSmall,
                  ),
                  bottomRight: Radius.circular(
                    isUser
                        ? AppConstants.borderRadiusSmall
                        : AppConstants.borderRadiusMedium,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUser)
                    Text(
                      'You',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    )
                  else
                    Text(
                      'GenLite',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (isUser)
                    Text(
                      widget.message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarkdownBody(
                          data: widget.message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 16,
                            ),
                            code: TextStyle(
                              backgroundColor: theme.colorScheme.surface,
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 14,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusSmall),
                            ),
                          ),
                          shrinkWrap: true,
                        ),
                        if (widget.isStreaming) ...[
                          const SizedBox(height: AppConstants.paddingSmall),
                          AnimatedBuilder(
                            animation: _typingAnimation,
                            builder: (context, child) {
                              return Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(
                                        alpha:
                                            _typingAnimation.value * 0.5 + 0.3,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(
                                        alpha:
                                            _typingAnimation.value * 0.5 + 0.3,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    _formatTimestamp(widget.message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.6)
                          : theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppConstants.paddingSmall),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppConstants.secondaryColor,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
