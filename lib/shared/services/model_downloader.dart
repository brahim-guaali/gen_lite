import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:genlite/shared/utils/logger.dart';

class ProgressInfo {
  final double progress; // 0.0 - 1.0
  final int receivedBytes;
  final int totalBytes;
  final double speedBytesPerSec;
  final Duration elapsed;
  ProgressInfo({
    required this.progress,
    required this.receivedBytes,
    required this.totalBytes,
    required this.speedBytesPerSec,
    required this.elapsed,
  });
}

class ModelDownloader {
  static const String _modelUrl =
      'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task';
  static const String _modelFilename = 'gemma-3n-E4B-it-int4.task';

  /// Download the Gemma model
  static Future<String> downloadModel({
    required Function(double progress) onProgress,
    int maxRetries = 3,
  }) async {
    final token = dotenv.env['HUGGINGFACE_TOKEN'];
    if (token == null || token.isEmpty) {
      Logger.error(
          LogTags.modelDownloader, 'Hugging Face token not found in .env');
      throw Exception('Hugging Face token not found in .env');
    }

    final url = Uri.parse(_modelUrl);
    Logger.info(LogTags.modelDownloader, 'Downloading model from: $url');

    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final request = http.Request('GET', url);
        request.headers['Authorization'] = 'Bearer $token';

        final response = await request.send();

        if (response.statusCode != 200) {
          final errorBody = await response.stream.bytesToString();
          Logger.error(LogTags.modelDownloader,
              'Download failed with status ${response.statusCode} - Error body: $errorBody');
          throw Exception('Download failed: ${response.statusCode}');
        }

        final contentLength = response.contentLength ?? 0;
        final filePath = await _getModelPath();
        final file = File(filePath);

        // Create directory if it doesn't exist
        final directory = file.parent;
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final sink = file.openWrite();
        int received = 0;

        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;

          if (contentLength > 0) {
            final progress = received / contentLength;
            onProgress(progress);
          }
        }

        await sink.close();

        Logger.info(
            LogTags.modelDownloader, 'Model download complete: $filePath');
        return filePath;
      } catch (e) {
        attempt++;
        Logger.warning(
            LogTags.modelDownloader, 'Download attempt $attempt failed: $e');

        if (attempt >= maxRetries) {
          rethrow;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }

    throw Exception('Failed to download model after $maxRetries attempts');
  }

  /// Get the model file path
  static Future<String> _getModelPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_modelFilename';
  }

  /// Check if model file exists
  static Future<bool> isModelDownloaded() async {
    try {
      final filePath = await _getModelPath();
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      Logger.error(LogTags.modelDownloader, 'Error checking model existence',
          error: e);
      return false;
    }
  }

  /// Get model file size
  static Future<int> getModelFileSize() async {
    try {
      final filePath = await _getModelPath();
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      Logger.error(LogTags.modelDownloader, 'Error getting model file size',
          error: e);
      return 0;
    }
  }

  /// Delete model file
  static Future<bool> deleteModel() async {
    try {
      final filePath = await _getModelPath();
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        Logger.info(LogTags.modelDownloader, 'Model file deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      Logger.error(LogTags.modelDownloader, 'Error deleting model file',
          error: e);
      return false;
    }
  }
}
