import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';

class ChatWelcomeMessage extends StatelessWidget {
  const ChatWelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              icon: Icons.chat_bubble_outline,
              size: 80,
              color: AppConstants.primaryColor.withValues(alpha: 0.5),
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
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.xl,
          ],
        ),
      ),
    );
  }
}
