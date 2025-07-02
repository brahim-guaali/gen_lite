import 'dart:io';

class FileProcessingService {
  /// Extract text content from various file types
  static Future<String> extractTextFromFile(File file, String fileType) async {
    try {
      switch (fileType.toLowerCase()) {
        case 'txt':
          return await _extractTextFromTxt(file);
        case 'pdf':
          return await _extractTextFromPdf(file);
        case 'docx':
          return await _extractTextFromDocx(file);
        default:
          return '[Unsupported file type: $fileType]';
      }
    } catch (e) {
      return '[Error extracting text from $fileType file: ${e.toString()}]';
    }
  }

  /// Extract text from TXT files
  static Future<String> _extractTextFromTxt(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read TXT file: ${e.toString()}');
    }
  }

  /// Extract text from PDF files (mock implementation)
  static Future<String> _extractTextFromPdf(File file) async {
    try {
      // Mock PDF extraction - in real implementation, this would use a PDF library
      await Future.delayed(
          const Duration(milliseconds: 1000)); // Simulate processing time
      return '[PDF Content - Mock extraction]\n\nThis is a simulated PDF text extraction. '
              'In the real implementation, this would extract actual text content from the PDF file. ' +
          'The file contains various sections and paragraphs that would be processed and returned here.';
    } catch (e) {
      throw Exception('Failed to extract text from PDF: ${e.toString()}');
    }
  }

  /// Extract text from DOCX files (mock implementation)
  static Future<String> _extractTextFromDocx(File file) async {
    try {
      // Mock DOCX extraction - in real implementation, this would use a DOCX library
      await Future.delayed(
          const Duration(milliseconds: 800)); // Simulate processing time
      return '[DOCX Content - Mock extraction]\n\nThis is a simulated DOCX text extraction. '
              'In the real implementation, this would extract actual text content from the DOCX file. ' +
          'The document contains formatted text, tables, and other elements that would be processed.';
    } catch (e) {
      throw Exception('Failed to extract text from DOCX: ${e.toString()}');
    }
  }

  /// Get file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Validate file type
  static bool isValidFileType(String fileType) {
    const supportedTypes = ['txt', 'pdf', 'docx'];
    return supportedTypes.contains(fileType.toLowerCase());
  }

  /// Get file type from file extension
  static String getFileTypeFromPath(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return extension;
  }

  /// Estimate processing time based on file size
  static Duration estimateProcessingTime(int fileSizeBytes) {
    // Rough estimation: 1 second per MB
    final sizeInMB = fileSizeBytes / (1024 * 1024);
    final seconds = (sizeInMB * 1).round();
    return Duration(seconds: seconds.clamp(1, 30)); // Min 1s, max 30s
  }

  /// Clean extracted text
  static String cleanExtractedText(String text) {
    if (text.isEmpty) return text;

    // Remove excessive whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Remove excessive newlines
    text = text.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    // Trim whitespace
    text = text.trim();

    return text;
  }

  /// Extract metadata from file
  static Map<String, dynamic> extractFileMetadata(File file) {
    final stat = file.statSync();
    final fileName = file.path.split('/').last;
    final fileType = getFileTypeFromPath(file.path);

    return {
      'name': fileName,
      'type': fileType,
      'size': stat.size,
      'modified': stat.modified,
      'created': stat.changed,
    };
  }
}
