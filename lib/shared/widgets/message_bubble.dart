import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../../core/constants/app_constants.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
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
            CircleAvatar(
              radius: 16,
              backgroundColor: AppConstants.primaryColor,
              child: const Icon(
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
                    color: Colors.black.withOpacity(0.1),
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
                        color: Colors.white.withOpacity(0.8),
                      ),
                    )
                  else
                    Text(
                      'GenLite',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (isUser)
                    Text(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.content,
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
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isUser
                          ? Colors.white.withOpacity(0.6)
                          : theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppConstants.paddingSmall),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppConstants.secondaryColor,
              child: const Icon(
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
