import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadState {
  final String modelId;
  final String filename;
  final int downloadedBytes;
  final int totalBytes;
  final DateTime lastUpdated;
  final bool isCompleted;
  final String? error;

  DownloadState({
    required this.modelId,
    required this.filename,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.lastUpdated,
    required this.isCompleted,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'modelId': modelId,
        'filename': filename,
        'downloadedBytes': downloadedBytes,
        'totalBytes': totalBytes,
        'lastUpdated': lastUpdated.toIso8601String(),
        'isCompleted': isCompleted,
        'error': error,
      };

  factory DownloadState.fromJson(Map<String, dynamic> json) => DownloadState(
        modelId: json['modelId'],
        filename: json['filename'],
        downloadedBytes: json['downloadedBytes'],
        totalBytes: json['totalBytes'],
        lastUpdated: DateTime.parse(json['lastUpdated']),
        isCompleted: json['isCompleted'],
        error: json['error'],
      );
}

class ProgressInfo {
  final double progress; // 0.0 - 1.0
  final int receivedBytes;
  final int totalBytes;
  final double speedBytesPerSec;
  final Duration elapsed;
  final bool isResuming;
  final String? status;

  ProgressInfo({
    required this.progress,
    required this.receivedBytes,
    required this.totalBytes,
    required this.speedBytesPerSec,
    required this.elapsed,
    this.isResuming = false,
    this.status,
  });
}

class EnhancedModelDownloader {
  static const String _downloadStateKey = 'model_download_state';
  static const String _downloadStatePrefix = 'download_state_';

  static Future<String> ensureGemmaModel({
    String modelId = 'google/gemma-2b-it',
    String filename = 'gemma-2b-it.gguf',
    void Function(ProgressInfo info)? onProgress,
    int maxRetries = 3,
    bool allowResume = true,
  }) async {
    final docDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${docDir.path}/gemma2b');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    final filePath = '${modelDir.path}/$filename';
    final file = File(filePath);

    // Check if file already exists and is complete
    if (await file.exists()) {
      final fileSize = await file.length();
      final downloadState = await _getDownloadState(modelId, filename);

      if (downloadState != null &&
          downloadState.isCompleted &&
          fileSize == downloadState.totalBytes) {
        onProgress?.call(ProgressInfo(
          progress: 1.0,
          receivedBytes: fileSize,
          totalBytes: fileSize,
          speedBytesPerSec: 0,
          elapsed: Duration.zero,
          status: 'Model already downloaded',
        ));
        return filePath;
      }
    }

    return _downloadModel(
      modelId: modelId,
      filename: filename,
      filePath: filePath,
      onProgress: onProgress,
      maxRetries: maxRetries,
      allowResume: allowResume,
    );
  }

  static Future<String> _downloadModel({
    required String modelId,
    required String filename,
    required String filePath,
    void Function(ProgressInfo info)? onProgress,
    int maxRetries = 3,
    bool allowResume = true,
  }) async {
    final token = dotenv.env['HUGGINGFACE_TOKEN'];
    if (token == null || token.isEmpty) {
      throw Exception('Hugging Face token not found in .env');
    }

    final url =
        Uri.parse('https://huggingface.co/$modelId/resolve/main/$filename');
    final file = File(filePath);

    // Check for existing download state
    DownloadState? existingState;
    int resumeFrom = 0;

    if (allowResume) {
      existingState = await _getDownloadState(modelId, filename);
      if (existingState != null &&
          !existingState.isCompleted &&
          existingState.error == null &&
          await file.exists()) {
        final fileSize = await file.length();
        if (fileSize <= existingState.totalBytes && fileSize > 0) {
          resumeFrom = fileSize;
          onProgress?.call(ProgressInfo(
            progress: fileSize / existingState.totalBytes,
            receivedBytes: fileSize,
            totalBytes: existingState.totalBytes,
            speedBytesPerSec: 0,
            elapsed: Duration.zero,
            isResuming: true,
            status: 'Resuming download from ${_formatBytes(fileSize)}',
          ));
        }
      }
    }

    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final request = http.Request('GET', url);
        request.headers['Authorization'] = 'Bearer $token';

        if (resumeFrom > 0) {
          request.headers['Range'] = 'bytes=$resumeFrom-';
        }

        final response = await request.send();

        if (response.statusCode != 200 && response.statusCode != 206) {
          final errorBody = await response.stream.bytesToString();
          throw Exception(
              'Failed to download model: ${response.statusCode} ${response.reasonPhrase}');
        }

        final contentLength = response.contentLength ?? 0;
        final totalBytes = resumeFrom + contentLength;

        // Update download state
        final downloadState = DownloadState(
          modelId: modelId,
          filename: filename,
          downloadedBytes: resumeFrom,
          totalBytes: totalBytes,
          lastUpdated: DateTime.now(),
          isCompleted: false,
        );
        await _saveDownloadState(modelId, filename, downloadState);

        final sink = file.openWrite(
            mode: resumeFrom > 0 ? FileMode.writeOnlyAppend : FileMode.write);
        int received = resumeFrom;
        final stopwatch = Stopwatch()..start();
        int lastReceived = received;
        int lastMillis = 0;

        onProgress?.call(ProgressInfo(
          progress: received / totalBytes,
          receivedBytes: received,
          totalBytes: totalBytes,
          speedBytesPerSec: 0,
          elapsed: stopwatch.elapsed,
          status:
              resumeFrom > 0 ? 'Resuming download...' : 'Starting download...',
        ));

        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          final elapsed = stopwatch.elapsed;
          final millis = elapsed.inMilliseconds;

          double speed = 0;
          if (millis > lastMillis) {
            final deltaBytes = received - lastReceived;
            final deltaMillis = millis - lastMillis;
            speed = deltaMillis > 0 ? deltaBytes / (deltaMillis / 1000) : 0;
            lastReceived = received;
            lastMillis = millis;
          }

          // Update progress
          onProgress?.call(ProgressInfo(
            progress: received / totalBytes,
            receivedBytes: received,
            totalBytes: totalBytes,
            speedBytesPerSec: speed,
            elapsed: elapsed,
            status: 'Downloading...',
          ));

          // Update download state periodically
          if (received % (1024 * 1024) < chunk.length) {
            // Every MB
            final updatedState = DownloadState(
              modelId: modelId,
              filename: filename,
              downloadedBytes: received,
              totalBytes: totalBytes,
              lastUpdated: DateTime.now(),
              isCompleted: false,
            );
            await _saveDownloadState(modelId, filename, updatedState);
          }
        }

        await sink.close();

        // Mark as completed
        final completedState = DownloadState(
          modelId: modelId,
          filename: filename,
          downloadedBytes: received,
          totalBytes: totalBytes,
          lastUpdated: DateTime.now(),
          isCompleted: true,
        );
        await _saveDownloadState(modelId, filename, completedState);

        onProgress?.call(ProgressInfo(
          progress: 1.0,
          receivedBytes: received,
          totalBytes: totalBytes,
          speedBytesPerSec: 0,
          elapsed: stopwatch.elapsed,
          status: 'Download completed',
        ));

        return filePath;
      } catch (e) {
        print(
            '[EnhancedModelDownloader] Download attempt ${attempt + 1} failed: $e');

        // Save error state
        final errorState = DownloadState(
          modelId: modelId,
          filename: filename,
          downloadedBytes: resumeFrom,
          totalBytes: existingState?.totalBytes ?? 0,
          lastUpdated: DateTime.now(),
          isCompleted: false,
          error: e.toString(),
        );
        await _saveDownloadState(modelId, filename, errorState);

        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }

    throw Exception('Failed to download model after $maxRetries attempts');
  }

  static Future<DownloadState?> _getDownloadState(
      String modelId, String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_downloadStatePrefix${modelId}_$filename';
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        return DownloadState.fromJson(json.decode(jsonString));
      }
    } catch (e) {
      print('[EnhancedModelDownloader] Error reading download state: $e');
    }
    return null;
  }

  static Future<void> _saveDownloadState(
      String modelId, String filename, DownloadState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_downloadStatePrefix${modelId}_$filename';
      await prefs.setString(key, json.encode(state.toJson()));
    } catch (e) {
      print('[EnhancedModelDownloader] Error saving download state: $e');
    }
  }

  static Future<void> clearDownloadState(
      String modelId, String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_downloadStatePrefix${modelId}_$filename';
      await prefs.remove(key);
    } catch (e) {
      print('[EnhancedModelDownloader] Error clearing download state: $e');
    }
  }

  static Future<bool> hasIncompleteDownload(
      String modelId, String filename) async {
    final state = await _getDownloadState(modelId, filename);
    return state != null && !state.isCompleted && state.error == null;
  }

  static Future<DownloadState?> getDownloadState(
      String modelId, String filename) async {
    return _getDownloadState(modelId, filename);
  }

  static String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }
}
