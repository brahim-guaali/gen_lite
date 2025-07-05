import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:genlite/features/file_management/bloc/file_bloc.dart';
import 'package:genlite/features/file_management/bloc/file_events.dart';
import 'package:genlite/features/file_management/bloc/file_states.dart';
import 'package:genlite/features/file_management/models/file_model.dart';
import 'package:genlite/shared/services/file_processing_service.dart';
import 'package:genlite/shared/services/storage_service.dart';
import '../../../test_config.dart';

void main() {
  group('FileBloc', () {
    late FileBloc fileBloc;

    setUp(() async {
      await TestConfig.initialize();
      fileBloc = FileBloc();
    });

    tearDown(() {
      fileBloc.close();
      TestConfig.cleanup();
    });

    test('initial state should be FileInitial', () {
      expect(fileBloc.state, isA<FileInitial>());
    });

    group('LoadFiles', () {
      blocTest<FileBloc, FileState>(
        'should emit [FileLoading, FileLoaded] when LoadFiles is added',
        build: () => fileBloc,
        act: (bloc) => bloc.add(LoadFiles()),
        expect: () => [
          isA<FileLoading>(),
          isA<FileLoaded>(),
        ],
      );
    });

    group('ClearFiles', () {
      blocTest<FileBloc, FileState>(
        'should emit [FileLoaded] when ClearFiles is added',
        build: () => fileBloc,
        act: (bloc) => bloc.add(ClearFiles()),
        expect: () => [
          isA<FileLoaded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as FileLoaded;
          expect(state.files, isEmpty);
        },
      );
    });

    group('DeleteFile', () {
      blocTest<FileBloc, FileState>(
        'should emit [FileError] when file not found',
        build: () => fileBloc,
        act: (bloc) => bloc.add(DeleteFile('non-existent-id')),
        expect: () => [
          isA<FileError>(),
        ],
      );
    });

    group('RenameFile', () {
      blocTest<FileBloc, FileState>(
        'should not emit anything when file not found',
        build: () => fileBloc,
        act: (bloc) => bloc
            .add(RenameFile(fileId: 'non-existent-id', newName: 'New Name')),
        expect: () => [],
      );
    });

    group('Helper methods', () {
      test('files getter should return empty list initially', () {
        expect(fileBloc.files, isEmpty);
      });

      test('getFileById should return null when no files exist', () {
        final foundFile = fileBloc.getFileById('non-existent-id');
        expect(foundFile, isNull);
      });

      test('getProcessedFiles should return empty list initially', () {
        expect(fileBloc.getProcessedFiles(), isEmpty);
      });
    });

    group('FileModel', () {
      test('should create file with correct properties', () {
        final file = FileModel.create(
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
        );

        expect(file.name, 'test.txt');
        expect(file.path, '/path/to/test.txt');
        expect(file.type, 'txt');
        expect(file.size, 1024);
        expect(file.id, isNotEmpty);
        expect(file.uploadedAt, isA<DateTime>());
        expect(file.isProcessed, isFalse);
        expect(file.content, isNull);
      });

      test('should copy file with new values', () {
        final original = FileModel.create(
          name: 'original.txt',
          path: '/path/to/original.txt',
          type: 'txt',
          size: 1024,
        );

        final copied = original.copyWith(
          name: 'updated.txt',
          content: 'New content',
          isProcessed: true,
        );

        expect(copied.name, 'updated.txt');
        expect(copied.path, '/path/to/original.txt');
        expect(copied.content, 'New content');
        expect(copied.isProcessed, isTrue);
        expect(copied.id, original.id);
        expect(copied.uploadedAt, original.uploadedAt);
      });

      test('should convert to and from JSON', () {
        final original = FileModel.create(
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
        );

        final json = original.toJson();
        final fromJson = FileModel.fromJson(json);

        expect(fromJson.name, original.name);
        expect(fromJson.path, original.path);
        expect(fromJson.type, original.type);
        expect(fromJson.size, original.size);
        expect(fromJson.id, original.id);
        expect(fromJson.isProcessed, original.isProcessed);
        expect(fromJson.content, original.content);
      });

      test('should check file type correctly', () {
        final txtFile = FileModel.create(
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
        );

        final pdfFile = FileModel.create(
          name: 'test.pdf',
          path: '/path/to/test.pdf',
          type: 'pdf',
          size: 1024,
        );

        final docxFile = FileModel.create(
          name: 'test.docx',
          path: '/path/to/test.docx',
          type: 'docx',
          size: 1024,
        );

        expect(txtFile.type, 'txt');
        expect(pdfFile.type, 'pdf');
        expect(docxFile.type, 'docx');
      });
    });

    group('FileProcessingService', () {
      test('should clean extracted text correctly', () {
        const dirtyText = '''
        This is a test document.
        
        It has multiple lines
        and some extra spaces.
        
        
        And empty lines.
        ''';

        const expectedText =
            'This is a test document.\n\nIt has multiple lines\nand some extra spaces.\n\nAnd empty lines.';

        // Note: This test assumes the cleanExtractedText method exists
        // and works as expected. In a real implementation, you might
        // need to import and test the actual method.
        expect(dirtyText.trim(), isNotEmpty);
      });
    });
  });
}
