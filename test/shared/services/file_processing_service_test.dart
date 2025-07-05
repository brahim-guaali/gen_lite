import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/shared/services/file_processing_service.dart';

void main() {
  group('FileProcessingService', () {
    group('Method Signatures', () {
      test('should have extractTextFromFile method', () {
        expect(FileProcessingService.extractTextFromFile, isA<Function>());
      });

      test('should have formatFileSize method', () {
        expect(FileProcessingService.formatFileSize, isA<Function>());
      });

      test('should have isValidFileType method', () {
        expect(FileProcessingService.isValidFileType, isA<Function>());
      });

      test('should have getFileTypeFromPath method', () {
        expect(FileProcessingService.getFileTypeFromPath, isA<Function>());
      });

      test('should have estimateProcessingTime method', () {
        expect(FileProcessingService.estimateProcessingTime, isA<Function>());
      });

      test('should have cleanExtractedText method', () {
        expect(FileProcessingService.cleanExtractedText, isA<Function>());
      });

      test('should have extractFileMetadata method', () {
        expect(FileProcessingService.extractFileMetadata, isA<Function>());
      });
    });

    group('File Type Validation', () {
      test('should recognize supported file types', () {
        expect(FileProcessingService.isValidFileType('pdf'), true);
        expect(FileProcessingService.isValidFileType('txt'), true);
        expect(FileProcessingService.isValidFileType('docx'), true);
      });

      test('should reject unsupported file types', () {
        expect(FileProcessingService.isValidFileType('jpg'), false);
        expect(FileProcessingService.isValidFileType('mp4'), false);
        expect(FileProcessingService.isValidFileType('mp3'), false);
        expect(FileProcessingService.isValidFileType('zip'), false);
      });

      test('should handle case sensitivity', () {
        expect(FileProcessingService.isValidFileType('PDF'), true);
        expect(FileProcessingService.isValidFileType('TXT'), true);
        expect(FileProcessingService.isValidFileType('DOCX'), true);
      });
    });

    group('File Type from Path', () {
      test('should get file type from file path', () {
        expect(
            FileProcessingService.getFileTypeFromPath('document.pdf'), 'pdf');
        expect(FileProcessingService.getFileTypeFromPath('text.txt'), 'txt');
        expect(
            FileProcessingService.getFileTypeFromPath('document.docx'), 'docx');
      });

      test('should handle files without extension', () {
        expect(
            FileProcessingService.getFileTypeFromPath('filename'), 'filename');
        expect(FileProcessingService.getFileTypeFromPath(''), '');
      });

      test('should handle files with multiple dots', () {
        expect(FileProcessingService.getFileTypeFromPath('file.backup.pdf'),
            'pdf');
        expect(
            FileProcessingService.getFileTypeFromPath('archive.tar.gz'), 'gz');
      });

      test('should handle case sensitivity', () {
        expect(
            FileProcessingService.getFileTypeFromPath('document.PDF'), 'pdf');
        expect(FileProcessingService.getFileTypeFromPath('text.TXT'), 'txt');
      });
    });

    group('File Size Formatting', () {
      test('should format bytes correctly', () {
        expect(FileProcessingService.formatFileSize(0), '0 B');
        expect(FileProcessingService.formatFileSize(1024), '1.0 KB');
        expect(FileProcessingService.formatFileSize(1024 * 1024), '1.0 MB');
        expect(
            FileProcessingService.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
      });

      test('should format decimal sizes correctly', () {
        expect(FileProcessingService.formatFileSize(1500), '1.5 KB');
        expect(FileProcessingService.formatFileSize(1536), '1.5 KB');
        expect(FileProcessingService.formatFileSize(1572864), '1.5 MB');
      });

      test('should handle small file sizes', () {
        expect(FileProcessingService.formatFileSize(1), '1 B');
        expect(FileProcessingService.formatFileSize(512), '512 B');
        expect(FileProcessingService.formatFileSize(999), '999 B');
      });

      test('should handle large file sizes', () {
        expect(FileProcessingService.formatFileSize(1024 * 1024 * 1024 * 1024),
            '1024.0 GB');
      });
    });

    group('Processing Time Estimation', () {
      test('should estimate processing time for small files', () {
        final time =
            FileProcessingService.estimateProcessingTime(1024 * 1024); // 1MB
        expect(time.inSeconds, 1);
      });

      test('should estimate processing time for large files', () {
        final time = FileProcessingService.estimateProcessingTime(
            10 * 1024 * 1024); // 10MB
        expect(time.inSeconds, 10);
      });

      test('should have minimum processing time', () {
        final time = FileProcessingService.estimateProcessingTime(
            100); // Very small file
        expect(time.inSeconds, 1);
      });

      test('should have maximum processing time', () {
        final time = FileProcessingService.estimateProcessingTime(
            100 * 1024 * 1024); // 100MB
        expect(time.inSeconds, 30);
      });
    });

    group('Text Cleaning', () {
      test('should clean excessive whitespace', () {
        const input = 'This   has    excessive     whitespace';
        const expected = 'This has excessive whitespace';
        expect(FileProcessingService.cleanExtractedText(input), expected);
      });

      test('should clean excessive newlines', () {
        const input = 'Line 1\n\n\nLine 2\n\n\n\nLine 3';
        const expected = 'Line 1 Line 2 Line 3';
        expect(FileProcessingService.cleanExtractedText(input), expected);
      });

      test('should trim whitespace', () {
        const input = '  This has leading and trailing spaces  ';
        const expected = 'This has leading and trailing spaces';
        expect(FileProcessingService.cleanExtractedText(input), expected);
      });

      test('should handle empty text', () {
        expect(FileProcessingService.cleanExtractedText(''), '');
      });

      test('should handle text with tabs', () {
        const input = 'This\thas\ttabs\tand\tspaces   ';
        const expected = 'This has tabs and spaces';
        expect(FileProcessingService.cleanExtractedText(input), expected);
      });
    });

    group('File Metadata', () {
      test('should extract metadata from file', () {
        // Create a temporary file for testing
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/test_file.txt');
        tempFile.writeAsStringSync('Test content');

        try {
          final metadata = FileProcessingService.extractFileMetadata(tempFile);

          expect(metadata['name'], 'test_file.txt');
          expect(metadata['type'], 'txt');
          expect(metadata['size'], isA<int>());
          expect(metadata['modified'], isA<DateTime>());
          expect(metadata['created'], isA<DateTime>());
        } finally {
          tempFile.deleteSync();
        }
      });

      test('should handle file path with multiple segments', () {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/subdir/test_file.pdf');
        tempFile.parent.createSync(recursive: true);
        tempFile.writeAsStringSync('Test content');

        try {
          final metadata = FileProcessingService.extractFileMetadata(tempFile);

          expect(metadata['name'], 'test_file.pdf');
          expect(metadata['type'], 'pdf');
        } finally {
          tempFile.deleteSync();
          tempFile.parent.deleteSync();
        }
      });
    });

    group('Text Extraction', () {
      test('should handle unsupported file types', () async {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/test.jpg');
        tempFile.writeAsStringSync('This is not a real image');

        try {
          final text =
              await FileProcessingService.extractTextFromFile(tempFile, 'jpg');
          expect(text, contains('Unsupported file type'));
        } finally {
          tempFile.deleteSync();
        }
      });

      test('should handle TXT files', () async {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/test.txt');
        const content = 'This is a test text file content.';
        tempFile.writeAsStringSync(content);

        try {
          final text =
              await FileProcessingService.extractTextFromFile(tempFile, 'txt');
          expect(text, content);
        } finally {
          tempFile.deleteSync();
        }
      });

      test('should handle PDF files (mock)', () async {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/test.pdf');
        tempFile.writeAsStringSync('Mock PDF content');

        try {
          final text =
              await FileProcessingService.extractTextFromFile(tempFile, 'pdf');
          expect(text, contains('PDF Content - Mock extraction'));
        } finally {
          tempFile.deleteSync();
        }
      });

      test('should handle DOCX files (mock)', () async {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/test.docx');
        tempFile.writeAsStringSync('Mock DOCX content');

        try {
          final text =
              await FileProcessingService.extractTextFromFile(tempFile, 'docx');
          expect(text, contains('DOCX Content - Mock extraction'));
        } finally {
          tempFile.deleteSync();
        }
      });

      test('should handle file reading errors', () async {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/nonexistent.txt');

        final text =
            await FileProcessingService.extractTextFromFile(tempFile, 'txt');
        expect(text, contains('Error extracting text'));
      });
    });
  });
}
