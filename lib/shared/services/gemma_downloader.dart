import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:genlite/shared/utils/logger.dart';

class DownloadModel {
  final String modelUrl;
  final String modelFilename;

  DownloadModel({
    required this.modelUrl,
    required this.modelFilename,
  });
}

class GemmaDownloaderDataSource {
  final DownloadModel model;

  GemmaDownloaderDataSource({required this.model});

  String get _preferenceKey => 'model_downloaded_${model.modelFilename}';

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${model.modelFilename}';
  }

  Future<bool> checkModelExistence() async {
    try {
      final filePath = await getFilePath();
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      Logger.error(LogTags.gemmaDownloader, 'Error checking model existence',
          error: e);
      return false;
    }
  }

  /// Downloads the model file and tracks progress.
  Future<void> downloadModel({
    required String token,
    required Function(double progress) onProgress,
    Function(int receivedBytes, int totalBytes, double speedBytesPerSec,
            Duration elapsed)?
        onDetailedProgress,
  }) async {
    try {
      final url = Uri.parse(model.modelUrl);
      final filePath = await getFilePath();
      final file = File(filePath);

      // Create directory if it doesn't exist
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final request = http.Request('GET', url);
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        Logger.error(LogTags.gemmaDownloader,
            'Download failed with status ${response.statusCode} - Headers: ${response.headers}, Error body: $errorBody');
        throw Exception('Download failed: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final sink = file.openWrite();
      int received = 0;
      final stopwatch = Stopwatch()..start();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;

        if (contentLength > 0) {
          final progress = received / contentLength;
          onProgress(progress);

          if (onDetailedProgress != null) {
            final elapsed = stopwatch.elapsed;
            final speed = elapsed.inMilliseconds > 0
                ? received / (elapsed.inMilliseconds / 1000)
                : 0.0;
            onDetailedProgress(received, contentLength, speed, elapsed);
          }
        }
      }

      await sink.close();
      stopwatch.stop();

      Logger.info(
          LogTags.gemmaDownloader, 'Model download completed successfully');
    } catch (e) {
      Logger.error(LogTags.gemmaDownloader, 'Error downloading model',
          error: e);
      rethrow;
    }
  }
}
