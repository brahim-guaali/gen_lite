import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/features/file_management/models/file_model.dart';

void main() {
  group('FileModel', () {
    group('Constructor', () {
      test('should create with required parameters', () {
        final now = DateTime.now();
        final file = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
        );

        expect(file.id, 'test-1');
        expect(file.name, 'test.txt');
        expect(file.path, '/path/to/test.txt');
        expect(file.type, 'txt');
        expect(file.size, 1024);
        expect(file.uploadedAt, now);
        expect(file.content, null);
        expect(file.isProcessed, false);
      });

      test('should create with optional parameters', () {
        final now = DateTime.now();
        final file = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
          content: 'test content',
          isProcessed: true,
        );

        expect(file.content, 'test content');
        expect(file.isProcessed, true);
      });

      test('should be equatable', () {
        final now = DateTime.now();
        final file1 = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
        );
        final file2 = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
        );
        final file3 = FileModel(
          id: 'test-2',
          name: 'test2.txt',
          path: '/path/to/test2.txt',
          type: 'txt',
          size: 2048,
          uploadedAt: now,
        );

        expect(file1, file2);
        expect(file1, isNot(file3));
      });

      test('should have correct props', () {
        final now = DateTime.now();
        final file = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
          content: 'test content',
          isProcessed: true,
        );

        expect(file.props, [
          'test-1',
          'test.txt',
          '/path/to/test.txt',
          'txt',
          1024,
          now,
          'test content',
          true,
        ]);
      });
    });

    group('copyWith', () {
      test('should copy with all fields', () {
        final now = DateTime.now();
        final original = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
          content: 'original content',
          isProcessed: false,
        );

        final copied = original.copyWith(
          id: 'test-2',
          name: 'updated.txt',
          path: '/path/to/updated.txt',
          type: 'pdf',
          size: 2048,
          uploadedAt: now.add(Duration(hours: 1)),
          content: 'updated content',
          isProcessed: true,
        );

        expect(copied.id, 'test-2');
        expect(copied.name, 'updated.txt');
        expect(copied.path, '/path/to/updated.txt');
        expect(copied.type, 'pdf');
        expect(copied.size, 2048);
        expect(copied.uploadedAt, now.add(Duration(hours: 1)));
        expect(copied.content, 'updated content');
        expect(copied.isProcessed, true);

        // Original should remain unchanged
        expect(original.id, 'test-1');
        expect(original.name, 'test.txt');
        expect(original.content, 'original content');
        expect(original.isProcessed, false);
      });

      test('should copy with partial fields', () {
        final now = DateTime.now();
        final original = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
          content: 'original content',
          isProcessed: false,
        );

        final copied = original.copyWith(
          name: 'updated.txt',
          isProcessed: true,
        );

        expect(copied.id, 'test-1'); // Should keep original
        expect(copied.name, 'updated.txt'); // Should update
        expect(copied.path, '/path/to/test.txt'); // Should keep original
        expect(copied.type, 'txt'); // Should keep original
        expect(copied.size, 1024); // Should keep original
        expect(copied.uploadedAt, now); // Should keep original
        expect(copied.content, 'original content'); // Should keep original
        expect(copied.isProcessed, true); // Should update
      });

      test('should handle null values in copyWith', () {
        final now = DateTime.now();
        final original = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
          content: 'test content',
          isProcessed: true,
        );

        final copied = original.copyWith(
          content: null,
          isProcessed: null,
        );

        expect(copied.content,
            'test content'); // copyWith doesn't handle null properly
        expect(copied.isProcessed,
            true); // Should keep original since null was passed
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final now = DateTime(2024, 1, 1, 12, 0, 0);
        final file = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
          content: 'test content',
          isProcessed: true,
        );

        final json = file.toJson();

        expect(json['id'], 'test-1');
        expect(json['name'], 'test.txt');
        expect(json['path'], '/path/to/test.txt');
        expect(json['type'], 'txt');
        expect(json['size'], 1024);
        expect(json['uploadedAt'], '2024-01-01T12:00:00.000');
        expect(json['content'], 'test content');
        expect(json['isProcessed'], true);
      });

      test('should handle null content in JSON', () {
        final now = DateTime(2024, 1, 1, 12, 0, 0);
        final file = FileModel(
          id: 'test-1',
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
          content: null,
          isProcessed: false,
        );

        final json = file.toJson();

        expect(json['content'], null);
        expect(json['isProcessed'], false);
      });
    });

    group('fromJson', () {
      test('should create from JSON correctly', () {
        final json = {
          'id': 'test-1',
          'name': 'test.txt',
          'path': '/path/to/test.txt',
          'type': 'txt',
          'size': 1024,
          'uploadedAt': '2024-01-01T12:00:00.000',
          'content': 'test content',
          'isProcessed': true,
        };

        final file = FileModel.fromJson(json);

        expect(file.id, 'test-1');
        expect(file.name, 'test.txt');
        expect(file.path, '/path/to/test.txt');
        expect(file.type, 'txt');
        expect(file.size, 1024);
        expect(file.uploadedAt, DateTime(2024, 1, 1, 12, 0, 0));
        expect(file.content, 'test content');
        expect(file.isProcessed, true);
      });

      test('should handle null content in JSON', () {
        final json = {
          'id': 'test-1',
          'name': 'test.txt',
          'path': '/path/to/test.txt',
          'type': 'txt',
          'size': 1024,
          'uploadedAt': '2024-01-01T12:00:00.000',
          'content': null,
          'isProcessed': false,
        };

        final file = FileModel.fromJson(json);

        expect(file.content, null);
        expect(file.isProcessed, false);
      });

      test('should handle missing isProcessed in JSON', () {
        final json = {
          'id': 'test-1',
          'name': 'test.txt',
          'path': '/path/to/test.txt',
          'type': 'txt',
          'size': 1024,
          'uploadedAt': '2024-01-01T12:00:00.000',
          'content': 'test content',
        };

        final file = FileModel.fromJson(json);

        expect(file.isProcessed, false); // Should default to false
      });
    });

    group('create factory', () {
      test('should create with auto-generated id and timestamp', () {
        final before = DateTime.now();
        final file = FileModel.create(
          name: 'test.txt',
          path: '/path/to/test.txt',
          type: 'txt',
          size: 1024,
        );
        final after = DateTime.now();

        expect(file.name, 'test.txt');
        expect(file.path, '/path/to/test.txt');
        expect(file.type, 'txt');
        expect(file.size, 1024);
        expect(file.content, null);
        expect(file.isProcessed, false);

        // Check that id is auto-generated
        expect(file.id, isNotEmpty);
        expect(int.tryParse(file.id), isNotNull);

        // Check that uploadedAt is set to current time
        expect(
            file.uploadedAt.isAfter(before) ||
                file.uploadedAt.isAtSameMomentAs(before),
            true);
        expect(
            file.uploadedAt.isBefore(after) ||
                file.uploadedAt.isAtSameMomentAs(after),
            true);
      });

      test('should generate unique ids for different files', () async {
        // Add small delay to ensure different timestamps
        final file1 = FileModel.create(
          name: 'test1.txt',
          path: '/path/to/test1.txt',
          type: 'txt',
          size: 1024,
        );

        // Small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 1));

        final file2 = FileModel.create(
          name: 'test2.txt',
          path: '/path/to/test2.txt',
          type: 'txt',
          size: 2048,
        );

        expect(file1.id, isNot(file2.id));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        final now = DateTime.now();
        final file = FileModel(
          id: '',
          name: '',
          path: '',
          type: '',
          size: 0,
          uploadedAt: now,
          content: '',
        );

        expect(file.id, '');
        expect(file.name, '');
        expect(file.path, '');
        expect(file.type, '');
        expect(file.size, 0);
        expect(file.content, '');
      });

      test('should handle large file sizes', () {
        final now = DateTime.now();
        final file = FileModel(
          id: 'test-1',
          name: 'large-file.bin',
          path: '/path/to/large-file.bin',
          type: 'bin',
          size: 1073741824, // 1GB
          uploadedAt: now,
        );

        expect(file.size, 1073741824);
      });

      test('should handle special characters in strings', () {
        final now = DateTime.now();
        final file = FileModel(
          id: 'test-1',
          name: 'file with spaces & symbols!.txt',
          path: '/path/with/spaces & symbols/file.txt',
          type: 'txt',
          size: 1024,
          uploadedAt: now,
          content: 'content with\nnewlines\tand\ttabs',
        );

        expect(file.name, 'file with spaces & symbols!.txt');
        expect(file.path, '/path/with/spaces & symbols/file.txt');
        expect(file.content, 'content with\nnewlines\tand\ttabs');
      });
    });
  });
}
