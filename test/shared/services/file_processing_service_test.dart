import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/shared/services/file_processing_service.dart';
import '../../test_config.dart';

void main() {
  group('FileProcessingService', () {
    late File testFile;
    late String testFilePath;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    setUp(() {
      testFilePath = '/tmp/test_file.txt';
      testFile = File(testFilePath);
    });

    tearDown(() {
      if (testFile.existsSync()) {
        testFile.deleteSync();
      }
    });

    group('extractTextFromFile', () {
      test('should extract text from TXT file', () async {
        const testContent = 'This is a test text file content.';
        await testFile.writeAsString(testContent);

        final result =
            await FileProcessingService.extractTextFromFile(testFile, 'txt');
        expect(result, equals(testContent));
      });

      test('should extract text from PDF file (mock)', () async {
        await testFile.writeAsString('PDF content');

        final result =
            await FileProcessingService.extractTextFromFile(testFile, 'pdf');
        expect(result, contains('[PDF Content - Mock extraction]'));
        expect(result, contains('simulated PDF text extraction'));
      });

      test('should extract text from DOCX file (mock)', () async {
        await testFile.writeAsString('DOCX content');

        final result =
            await FileProcessingService.extractTextFromFile(testFile, 'docx');
        expect(result, contains('[DOCX Content - Mock extraction]'));
        expect(result, contains('simulated DOCX text extraction'));
      });

      test('should handle unsupported file type', () async {
        await testFile.writeAsString('Some content');

        final result =
            await FileProcessingService.extractTextFromFile(testFile, 'xyz');
        expect(result, equals('[Unsupported file type: xyz]'));
      });

      test('should handle file read errors', () async {
        // Create a file that will cause read errors
        final nonExistentFile = File('/non/existent/file.txt');

        final result = await FileProcessingService.extractTextFromFile(
            nonExistentFile, 'txt');
        expect(result, contains('[Error extracting text from txt file:'));
      });
    });

    group('formatFileSize', () {
      test('should format bytes correctly', () {
        expect(FileProcessingService.formatFileSize(500), equals('500 B'));
        expect(FileProcessingService.formatFileSize(1024), equals('1.0 KB'));
        expect(FileProcessingService.formatFileSize(1536), equals('1.5 KB'));
        expect(FileProcessingService.formatFileSize(1024 * 1024),
            equals('1.0 MB'));
        expect(FileProcessingService.formatFileSize(1024 * 1024 * 1024),
            equals('1.0 GB'));
      });

      test('should handle large file sizes', () {
        expect(FileProcessingService.formatFileSize(2 * 1024 * 1024 * 1024),
            equals('2.0 GB'));
      });

      test('should handle zero bytes', () {
        expect(FileProcessingService.formatFileSize(0), equals('0 B'));
      });
    });

    group('isValidFileType', () {
      test('should return true for supported file types', () {
        expect(FileProcessingService.isValidFileType('txt'), isTrue);
        expect(FileProcessingService.isValidFileType('pdf'), isTrue);
        expect(FileProcessingService.isValidFileType('docx'), isTrue);
        expect(FileProcessingService.isValidFileType('TXT'), isTrue);
        expect(FileProcessingService.isValidFileType('PDF'), isTrue);
        expect(FileProcessingService.isValidFileType('DOCX'), isTrue);
      });

      test('should return false for unsupported file types', () {
        expect(FileProcessingService.isValidFileType('jpg'), isFalse);
        expect(FileProcessingService.isValidFileType('png'), isFalse);
        expect(FileProcessingService.isValidFileType('mp4'), isFalse);
        expect(FileProcessingService.isValidFileType(''), isFalse);
      });
    });

    group('getFileTypeFromPath', () {
      test('should extract file type from path', () {
        expect(FileProcessingService.getFileTypeFromPath('/path/to/file.txt'),
            equals('txt'));
        expect(FileProcessingService.getFileTypeFromPath('document.pdf'),
            equals('pdf'));
        expect(FileProcessingService.getFileTypeFromPath('report.docx'),
            equals('docx'));
        expect(FileProcessingService.getFileTypeFromPath('file.TXT'),
            equals('txt'));
      });

      test('should handle paths without extension', () {
        expect(FileProcessingService.getFileTypeFromPath('/path/to/file'),
            equals('/path/to/file'));
      });

      test('should handle paths with multiple dots', () {
        expect(FileProcessingService.getFileTypeFromPath('file.backup.txt'),
            equals('txt'));
      });
    });

    group('estimateProcessingTime', () {
      test('should estimate processing time correctly', () {
        // 1MB = 1 second
        expect(FileProcessingService.estimateProcessingTime(1024 * 1024),
            equals(const Duration(seconds: 1)));

        // 2MB = 2 seconds
        expect(FileProcessingService.estimateProcessingTime(2 * 1024 * 1024),
            equals(const Duration(seconds: 2)));

        // 0.5MB = 1 second (minimum)
        expect(FileProcessingService.estimateProcessingTime(512 * 1024),
            equals(const Duration(seconds: 1)));
      });

      test('should respect minimum and maximum bounds', () {
        // Very small file should have minimum 1 second
        expect(FileProcessingService.estimateProcessingTime(100),
            equals(const Duration(seconds: 1)));

        // Very large file should have maximum 30 seconds
        expect(
            FileProcessingService.estimateProcessingTime(
                100 * 1024 * 1024 * 1024),
            equals(const Duration(seconds: 30)));
      });
    });

    group('cleanExtractedText', () {
      test('should clean excessive whitespace', () {
        const input = 'This   has    excessive     whitespace';
        const expected = 'This has excessive whitespace';
        expect(
            FileProcessingService.cleanExtractedText(input), equals(expected));
      });

      test('should clean excessive newlines', () {
        const input = 'Line 1\n\n\n\nLine 2\n\n\n\n\nLine 3';
        const expected = 'Line 1 Line 2 Line 3';
        expect(
            FileProcessingService.cleanExtractedText(input), equals(expected));
      });

      test('should trim whitespace', () {
        const input = '  This has leading and trailing spaces  ';
        const expected = 'This has leading and trailing spaces';
        expect(
            FileProcessingService.cleanExtractedText(input), equals(expected));
      });

      test('should handle empty string', () {
        expect(FileProcessingService.cleanExtractedText(''), equals(''));
      });

      test('should handle complex text cleaning', () {
        const input = '''
  This   text   has   multiple   issues:
  
  
  - Excessive   whitespace
  - Multiple   newlines
  - Leading   and   trailing   spaces  
''';
        const expected =
            'This text has multiple issues: - Excessive whitespace - Multiple newlines - Leading and trailing spaces';
        expect(
            FileProcessingService.cleanExtractedText(input), equals(expected));
      });
    });

    group('extractFileMetadata', () {
      test('should extract metadata from file', () async {
        const testContent = 'Test content for metadata extraction';
        await testFile.writeAsString(testContent);

        final metadata = FileProcessingService.extractFileMetadata(testFile);

        expect(metadata['name'], equals('test_file.txt'));
        expect(metadata['type'], equals('txt'));
        expect(metadata['size'], equals(testContent.length));
        expect(metadata['modified'], isA<DateTime>());
        expect(metadata['created'], isA<DateTime>());
      });

      test('should handle file with complex path', () {
        final complexFile = File('/path/to/complex/file.name.with.dots.pdf');
        final metadata = FileProcessingService.extractFileMetadata(complexFile);

        expect(metadata['name'], equals('file.name.with.dots.pdf'));
        expect(metadata['type'], equals('pdf'));
      });
    });
  });
}
