import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/file_bloc.dart';
import '../bloc/file_events.dart';
import '../bloc/file_states.dart';
import '../models/file_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../../core/constants/app_constants.dart';

class FileManagementScreen extends StatelessWidget {
  const FileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<FileBloc>().add(const PickFile());
            },
          ),
        ],
      ),
      body: BlocBuilder<FileBloc, FileState>(
        builder: (context, state) {
          if (state is FileLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is FileError) {
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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.errorColor,
                              ),
                    ),
                    AppSpacing.sm,
                    Text(
                      state.message,
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

          if (state is FileLoaded) {
            return _buildFileList(context, state.files);
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<FileBloc>().add(const PickFile());
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildFileList(BuildContext context, List<FileModel> files) {
    if (files.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return _FileCard(file: file);
      },
    );
  }
}

class _FileCard extends StatelessWidget {
  final FileModel file;

  const _FileCard({required this.file});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      onTap: () {
        if (file.isProcessed) {
          // Navigate to chat with file context
          Navigator.pop(context, file);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getFileIcon(file.type),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${file.type.toUpperCase()} • ${_formatFileSize(file.size)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
              if (file.isProcessed)
                AppBadge(
                  text: 'Ready',
                  backgroundColor:
                      AppConstants.successColor.withValues(alpha: 0.1),
                  textColor: AppConstants.successColor,
                ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getFileIcon(String fileType) {
    IconData iconData;
    Color iconColor;

    switch (fileType.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'txt':
        iconData = Icons.text_snippet;
        iconColor = Colors.blue;
        break;
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return AppIcon(
      icon: iconData,
      size: 32,
      color: iconColor,
      backgroundColor: iconColor.withValues(alpha: 0.1),
      padding: 8,
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'rename':
        _showRenameDialog(context);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          SecondaryButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            isFullWidth: false,
          ),
          PrimaryButton(
            text: 'Rename',
            onPressed: () {
              // TODO: Implement rename functionality
              Navigator.pop(context);
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          SecondaryButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            isFullWidth: false,
          ),
          DangerButton(
            text: 'Delete',
            onPressed: () {
              context.read<FileBloc>().add(DeleteFile(file.id));
              Navigator.pop(context);
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}
