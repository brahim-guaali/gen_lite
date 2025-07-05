import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

import '../../../../lib/features/file_management/bloc/file_events.dart';

void main() {
  group('FileEvent', () {
    group('PickFile', () {
      test('should create with default allowed extensions', () {
        const event = PickFile();
        expect(event.allowedExtensions, ['pdf', 'txt', 'docx']);
      });

      test('should create with custom allowed extensions', () {
        const customExtensions = ['pdf', 'doc'];
        const event = PickFile(allowedExtensions: customExtensions);
        expect(event.allowedExtensions, customExtensions);
      });

      test('should be equatable', () {
        const event1 = PickFile(allowedExtensions: ['pdf', 'txt']);
        const event2 = PickFile(allowedExtensions: ['pdf', 'txt']);
        const event3 = PickFile(allowedExtensions: ['pdf', 'doc']);

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = PickFile(allowedExtensions: ['pdf', 'txt']);
        expect(event.props, [
          ['pdf', 'txt']
        ]);
      });
    });

    group('ProcessFile', () {
      test('should create with file', () {
        final file = File('/path/to/test.txt');
        final event = ProcessFile(file);
        expect(event.file, file);
      });

      test('should be equatable', () {
        final file1 = File('/path/to/test1.txt');
        final file2 = File('/path/to/test2.txt');
        final event1 = ProcessFile(file1);
        final event2 = ProcessFile(file1);
        final event3 = ProcessFile(file2);

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        final file = File('/path/to/test.txt');
        final event = ProcessFile(file);
        expect(event.props, [file]);
      });
    });

    group('ExtractFileContent', () {
      test('should create with required parameters', () {
        const event = ExtractFileContent(
          filePath: '/path/to/test.txt',
          fileType: 'txt',
        );
        expect(event.filePath, '/path/to/test.txt');
        expect(event.fileType, 'txt');
      });

      test('should be equatable', () {
        const event1 = ExtractFileContent(
          filePath: '/path/to/test1.txt',
          fileType: 'txt',
        );
        const event2 = ExtractFileContent(
          filePath: '/path/to/test1.txt',
          fileType: 'txt',
        );
        const event3 = ExtractFileContent(
          filePath: '/path/to/test2.txt',
          fileType: 'pdf',
        );

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = ExtractFileContent(
          filePath: '/path/to/test.txt',
          fileType: 'txt',
        );
        expect(event.props, ['/path/to/test.txt', 'txt']);
      });
    });

    group('DeleteFile', () {
      test('should create with fileId', () {
        const event = DeleteFile('test-file-id');
        expect(event.fileId, 'test-file-id');
      });

      test('should be equatable', () {
        const event1 = DeleteFile('file1');
        const event2 = DeleteFile('file1');
        const event3 = DeleteFile('file2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = DeleteFile('test-file-id');
        expect(event.props, ['test-file-id']);
      });
    });

    group('RenameFile', () {
      test('should create with required parameters', () {
        const event = RenameFile(
          fileId: 'test-file-id',
          newName: 'new-name.txt',
        );
        expect(event.fileId, 'test-file-id');
        expect(event.newName, 'new-name.txt');
      });

      test('should be equatable', () {
        const event1 = RenameFile(
          fileId: 'file1',
          newName: 'new-name1.txt',
        );
        const event2 = RenameFile(
          fileId: 'file1',
          newName: 'new-name1.txt',
        );
        const event3 = RenameFile(
          fileId: 'file2',
          newName: 'new-name2.txt',
        );

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = RenameFile(
          fileId: 'test-file-id',
          newName: 'new-name.txt',
        );
        expect(event.props, ['test-file-id', 'new-name.txt']);
      });
    });

    group('LoadFiles', () {
      test('should be equatable', () {
        final event1 = LoadFiles();
        final event2 = LoadFiles();
        expect(event1, event2);
      });

      test('should have empty props', () {
        final event = LoadFiles();
        expect(event.props, isEmpty);
      });
    });

    group('ClearFiles', () {
      test('should be equatable', () {
        final event1 = ClearFiles();
        final event2 = ClearFiles();
        expect(event1, event2);
      });

      test('should have empty props', () {
        final event = ClearFiles();
        expect(event.props, isEmpty);
      });
    });
  });
}
