import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';
import '../bloc/file_bloc.dart';
import '../bloc/file_events.dart';
import '../models/file_model.dart';

class FileCard extends StatelessWidget {
  final FileModel file;

  const FileCard({super.key, required this.file});

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
