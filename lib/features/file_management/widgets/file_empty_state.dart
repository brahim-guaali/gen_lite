import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';
import '../bloc/file_bloc.dart';
import '../bloc/file_events.dart';

class FileEmptyState extends StatelessWidget {
  const FileEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon(
              icon: Icons.folder_open,
              size: 64,
              color: AppConstants.primaryColor,
            ),
            AppSpacing.md,
            Text(
              'No Files Uploaded',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
            ),
            AppSpacing.sm,
            Text(
              'Upload PDF, TXT, or DOCX files to start asking questions',
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
              text: 'Upload File',
              icon: Icons.upload_file,
              onPressed: () {
                context.read<FileBloc>().add(const PickFile());
              },
            ),
          ],
        ),
      ),
    );
  }
}
