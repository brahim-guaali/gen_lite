import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../models/file_model.dart';
import 'file_card.dart';
import 'file_empty_state.dart';

class FileList extends StatelessWidget {
  final List<FileModel> files;

  const FileList({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const FileEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return FileCard(file: file);
      },
    );
  }
}
