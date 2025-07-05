import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/file_bloc.dart';
import '../bloc/file_events.dart';
import '../bloc/file_states.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/file_error_message.dart';
import '../widgets/file_empty_state.dart';
import '../widgets/file_list.dart';

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
            return FileErrorMessage(message: state.message);
          }

          if (state is FileLoaded) {
            return FileList(files: state.files);
          }

          return const FileEmptyState();
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
}
