import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/features/file_management/bloc/file_states.dart';
import 'package:genlite/features/file_management/models/file_model.dart';

void main() {
  group('FileState', () {
    group('FileInitial', () {
      test('should be equatable', () {
        final state1 = FileInitial();
        final state2 = FileInitial();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = FileInitial();
        expect(state.props, isEmpty);
      });
    });

    group('FileLoading', () {
      test('should be equatable', () {
        final state1 = FileLoading();
        final state2 = FileLoading();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = FileLoading();
        expect(state.props, isEmpty);
      });
    });

    group('FileLoaded', () {
      test('should create with required parameters', () {
        final files = [
          FileModel(
            id: '1',
            name: 'test.txt',
            path: '/path/to/test.txt',
            size: 1024,
            type: 'txt',
            content: 'test content',
            uploadedAt: DateTime.now(),
          ),
        ];
        final state = FileLoaded(files: files);
        expect(state.files, files);
        expect(state.isProcessing, false);
      });

      test('should create with custom isProcessing', () {
        final files = [
          FileModel(
            id: '1',
            name: 'test.txt',
            path: '/path/to/test.txt',
            size: 1024,
            type: 'txt',
            content: 'test content',
            uploadedAt: DateTime.now(),
          ),
        ];
        final state = FileLoaded(files: files, isProcessing: true);
        expect(state.files, files);
        expect(state.isProcessing, true);
      });

      test('should be equatable', () {
        final files = [
          FileModel(
            id: '1',
            name: 'test.txt',
            path: '/path/to/test.txt',
            size: 1024,
            type: 'txt',
            content: 'test content',
            uploadedAt: DateTime.now(),
          ),
        ];
        final state1 = FileLoaded(files: files, isProcessing: false);
        final state2 = FileLoaded(files: files, isProcessing: false);
        final state3 = FileLoaded(files: files, isProcessing: true);

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        final files = [
          FileModel(
            id: '1',
            name: 'test.txt',
            path: '/path/to/test.txt',
            size: 1024,
            type: 'txt',
            content: 'test content',
            uploadedAt: DateTime.now(),
          ),
        ];
        final state = FileLoaded(files: files, isProcessing: false);
        expect(state.props, [files, false]);
      });

      test('should copyWith correctly', () {
        final files1 = [
          FileModel(
            id: '1',
            name: 'test1.txt',
            path: '/path/to/test1.txt',
            size: 1024,
            type: 'txt',
            content: 'test content 1',
            uploadedAt: DateTime.now(),
          ),
        ];
        final files2 = [
          FileModel(
            id: '2',
            name: 'test2.txt',
            path: '/path/to/test2.txt',
            size: 2048,
            type: 'txt',
            content: 'test content 2',
            uploadedAt: DateTime.now(),
          ),
        ];

        final originalState = FileLoaded(files: files1, isProcessing: false);
        final copiedState = originalState.copyWith(
          files: files2,
          isProcessing: true,
        );

        expect(copiedState.files, files2);
        expect(copiedState.isProcessing, true);
        expect(originalState.files, files1); // Original should not change
        expect(originalState.isProcessing, false);
      });

      test('should copyWith with partial parameters', () {
        final files = [
          FileModel(
            id: '1',
            name: 'test.txt',
            path: '/path/to/test.txt',
            size: 1024,
            type: 'txt',
            content: 'test content',
            uploadedAt: DateTime.now(),
          ),
        ];

        final originalState = FileLoaded(files: files, isProcessing: false);
        final copiedState = originalState.copyWith(isProcessing: true);

        expect(copiedState.files, files); // Should keep original files
        expect(copiedState.isProcessing, true);
      });
    });

    group('FileError', () {
      test('should create with message', () {
        final state = FileError('Test error message');
        expect(state.message, 'Test error message');
      });

      test('should be equatable', () {
        final state1 = FileError('Error 1');
        final state2 = FileError('Error 1');
        final state3 = FileError('Error 2');

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        final state = FileError('Test error message');
        expect(state.props, ['Test error message']);
      });
    });

    group('FileProcessing', () {
      test('should create with required parameters', () {
        final file = FileModel(
          id: '1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          size: 1024,
          type: 'txt',
          content: 'test content',
          uploadedAt: DateTime.now(),
        );
        final state = FileProcessing(file: file, progress: 0.5);
        expect(state.file, file);
        expect(state.progress, 0.5);
      });

      test('should be equatable', () {
        final file = FileModel(
          id: '1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          size: 1024,
          type: 'txt',
          content: 'test content',
          uploadedAt: DateTime.now(),
        );
        final state1 = FileProcessing(file: file, progress: 0.5);
        final state2 = FileProcessing(file: file, progress: 0.5);
        final state3 = FileProcessing(file: file, progress: 0.8);

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        final file = FileModel(
          id: '1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          size: 1024,
          type: 'txt',
          content: 'test content',
          uploadedAt: DateTime.now(),
        );
        final state = FileProcessing(file: file, progress: 0.5);
        expect(state.props, [file, 0.5]);
      });
    });
  });
}
