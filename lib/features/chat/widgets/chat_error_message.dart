import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';

class ChatErrorMessage extends StatelessWidget {
  final String message;
  const ChatErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.errorColor,
                  ),
            ),
            AppSpacing.sm,
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.lg,
          ],
        ),
      ),
    );
  }
}
