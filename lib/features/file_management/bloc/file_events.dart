import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class FileEvent extends Equatable {
  const FileEvent();

  @override
  List<Object?> get props => [];
}

class PickFile extends FileEvent {
  final List<String> allowedExtensions;

  const PickFile({this.allowedExtensions = const ['pdf', 'txt', 'docx']});

  @override
  List<Object?> get props => [allowedExtensions];
}

class ProcessFile extends FileEvent {
  final File file;

  const ProcessFile(this.file);

  @override
  List<Object?> get props => [file];
}

class ExtractFileContent extends FileEvent {
  final String filePath;
  final String fileType;

  const ExtractFileContent({
    required this.filePath,
    required this.fileType,
  });

  @override
  List<Object?> get props => [filePath, fileType];
}

class DeleteFile extends FileEvent {
  final String fileId;

  const DeleteFile(this.fileId);

  @override
  List<Object?> get props => [fileId];
}

class RenameFile extends FileEvent {
  final String fileId;
  final String newName;

  const RenameFile({
    required this.fileId,
    required this.newName,
  });

  @override
  List<Object?> get props => [fileId, newName];
}

class LoadFiles extends FileEvent {}

class ClearFiles extends FileEvent {}
