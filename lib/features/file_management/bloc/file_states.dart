import 'package:equatable/equatable.dart';
import '../models/file_model.dart';

abstract class FileState extends Equatable {
  const FileState();

  @override
  List<Object?> get props => [];
}

class FileInitial extends FileState {}

class FileLoading extends FileState {}

class FileLoaded extends FileState {
  final List<FileModel> files;
  final bool isProcessing;

  const FileLoaded({
    required this.files,
    this.isProcessing = false,
  });

  FileLoaded copyWith({
    List<FileModel>? files,
    bool? isProcessing,
  }) {
    return FileLoaded(
      files: files ?? this.files,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [files, isProcessing];
}

class FileError extends FileState {
  final String message;

  const FileError(this.message);

  @override
  List<Object?> get props => [message];
}

class FileProcessing extends FileState {
  final FileModel file;
  final double progress;

  const FileProcessing({
    required this.file,
    required this.progress,
  });

  @override
  List<Object?> get props => [file, progress];
}
