import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/services/file_processing_service.dart';
import '../../../shared/services/storage_service.dart';
import 'file_events.dart';
import 'file_states.dart';
import '../models/file_model.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final Uuid _uuid = const Uuid();
  List<FileModel> _files = [];

  FileBloc() : super(FileInitial()) {
    on<PickFile>(_onPickFile);
    on<ProcessFile>(_onProcessFile);
    on<ExtractFileContent>(_onExtractFileContent);
    on<DeleteFile>(_onDeleteFile);
    on<RenameFile>(_onRenameFile);
    on<LoadFiles>(_onLoadFiles);
    on<ClearFiles>(_onClearFiles);
  }

  Future<void> _onPickFile(PickFile event, Emitter<FileState> emit) async {
    try {
      emit(FileLoading());

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: event.allowedExtensions,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileModel = FileModel.create(
          name: result.files.single.name,
          path: file.path,
          type: result.files.single.extension ?? 'unknown',
          size: result.files.single.size,
        );

        _files.add(fileModel);
        emit(FileLoaded(files: List.from(_files)));

        // Auto-process the file
        add(ProcessFile(file));
      } else {
        emit(FileLoaded(files: List.from(_files)));
      }
    } catch (e) {
      emit(FileError('Failed to pick file: ${e.toString()}'));
    }
  }

  Future<void> _onProcessFile(
      ProcessFile event, Emitter<FileState> emit) async {
    try {
      final fileIndex = _files.indexWhere((f) => f.path == event.file.path);
      if (fileIndex == -1) return;

      final file = _files[fileIndex];
      emit(FileProcessing(file: file, progress: 0.0));

      // Extract content using FileProcessingService
      final content = await FileProcessingService.extractTextFromFile(
        event.file,
        file.type,
      );

      // Clean the extracted text
      final cleanedContent = FileProcessingService.cleanExtractedText(content);

      final processedFile = file.copyWith(
        content: cleanedContent,
        isProcessed: true,
      );

      _files[fileIndex] = processedFile;

      // Save to persistent storage
      await StorageService.saveFile(processedFile);

      emit(FileLoaded(files: List.from(_files)));
    } catch (e) {
      emit(FileError('Failed to process file: ${e.toString()}'));
    }
  }

  Future<void> _onExtractFileContent(
    ExtractFileContent event,
    Emitter<FileState> emit,
  ) async {
    try {
      final fileIndex = _files.indexWhere((f) => f.path == event.filePath);
      if (fileIndex == -1) return;

      final file = _files[fileIndex];
      emit(FileProcessing(file: file, progress: 0.5));

      final fileObj = File(event.filePath);
      final content = await FileProcessingService.extractTextFromFile(
        fileObj,
        event.fileType,
      );

      final cleanedContent = FileProcessingService.cleanExtractedText(content);
      final processedFile = file.copyWith(
        content: cleanedContent,
        isProcessed: true,
      );

      _files[fileIndex] = processedFile;

      // Save to persistent storage
      await StorageService.saveFile(processedFile);

      emit(FileLoaded(files: List.from(_files)));
    } catch (e) {
      emit(FileError('Failed to extract content: ${e.toString()}'));
    }
  }

  void _onDeleteFile(DeleteFile event, Emitter<FileState> emit) async {
    try {
      final fileToDelete = _files.firstWhere((file) => file.id == event.fileId);

      // Delete from storage
      await StorageService.deleteFile(event.fileId);

      // Remove from memory
      _files.removeWhere((file) => file.id == event.fileId);

      emit(FileLoaded(files: List.from(_files)));
    } catch (e) {
      emit(FileError('Failed to delete file: ${e.toString()}'));
    }
  }

  void _onRenameFile(RenameFile event, Emitter<FileState> emit) async {
    try {
      final fileIndex = _files.indexWhere((file) => file.id == event.fileId);
      if (fileIndex == -1) return;

      final file = _files[fileIndex];
      final renamedFile = file.copyWith(name: event.newName);
      _files[fileIndex] = renamedFile;

      // Update in storage
      await StorageService.updateFile(renamedFile);

      emit(FileLoaded(files: List.from(_files)));
    } catch (e) {
      emit(FileError('Failed to rename file: ${e.toString()}'));
    }
  }

  void _onLoadFiles(LoadFiles event, Emitter<FileState> emit) async {
    try {
      emit(FileLoading());

      // Load files from persistent storage
      final savedFiles = await StorageService.loadFiles();
      _files = savedFiles;

      emit(FileLoaded(files: List.from(_files)));
    } catch (e) {
      emit(FileError('Failed to load files: ${e.toString()}'));
    }
  }

  void _onClearFiles(ClearFiles event, Emitter<FileState> emit) async {
    try {
      // Clear from storage
      for (final file in _files) {
        await StorageService.deleteFile(file.id);
      }

      _files.clear();
      emit(FileLoaded(files: List.from(_files)));
    } catch (e) {
      emit(FileError('Failed to clear files: ${e.toString()}'));
    }
  }

  // Helper methods
  List<FileModel> get files => List.from(_files);

  FileModel? getFileById(String id) {
    try {
      return _files.firstWhere((file) => file.id == id);
    } catch (e) {
      return null;
    }
  }

  List<FileModel> getProcessedFiles() {
    return _files.where((file) => file.isProcessed).toList();
  }
}
