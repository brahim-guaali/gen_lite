import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';
import '../bloc/file_bloc.dart';
import '../bloc/file_events.dart';

class FileErrorMessage extends StatelessWidget {
  final String message;

  const FileErrorMessage({super.key, required this.message});

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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.errorColor,
                  ),
            ),
            AppSpacing.sm,
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.lg,
            PrimaryButton(
              text: 'Retry',
              icon: Icons.refresh,
              onPressed: () {
                context.read<FileBloc>().add(LoadFiles());
              },
            ),
          ],
        ),
      ),
    );
  }
}
