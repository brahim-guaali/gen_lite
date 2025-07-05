import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genlite/shared/services/gemma_downloader.dart';
import 'package:genlite/shared/services/model_downloader.dart';
import 'package:genlite/shared/utils/logger.dart';
import 'dart:typed_data';

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
  static const String _modelUrl =
      'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task';
  static const String _modelFilename = 'gemma-3n-E4B-it-int4.task';

  static Future<bool> _isValidZipFile(File file) async {
    if (!await file.exists()) return false;
    final raf = await file.open();
    try {
      final header = await raf.read(4);
      // ZIP files start with 0x50 0x4B 0x03 0x04
      return header.length == 4 &&
          header[0] == 0x50 &&
          header[1] == 0x4B &&
          header[2] == 0x03 &&
          header[3] == 0x04;
    } catch (_) {
      return false;
    } finally {
      await raf.close();
    }
  }

  static Future<String> ensureGemmaModel({
    String modelId = 'google/gemma-3n-E4B-it-litert-preview',
    String filename = 'gemma-3n-E4B-it-int4.task',
    void Function(ProgressInfo info)? onProgress,
    int maxRetries = 3,
    bool allowResume = true,
  }) async {
    final docDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${docDir.path}/gemma2b');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
      Logger.info('EnhancedModelDownloader',
          'Created model directory: \'${modelDir.path}\'');
    }
    final filePath = '${modelDir.path}/$filename';
    final file = File(filePath);
    final downloadState = await _getDownloadState(modelId, filename);

    Logger.info('EnhancedModelDownloader',
        'File exists: ${await file.exists()}, Download state exists: ${downloadState != null}');

    // If file is missing but state exists, clear state and start fresh
    if (!(await file.exists()) && downloadState != null) {
      Logger.info('EnhancedModelDownloader',
          'File missing but download state exists. Clearing state and starting fresh.');
      await clearDownloadState(modelId, filename);
    }
    // If file exists, check if it's valid and complete
    if (await file.exists()) {
      final fileSize = await file.length();
      if (fileSize == 0) {
        Logger.info('EnhancedModelDownloader',
            'File is zero bytes, deleting and clearing state.');
        await file.delete();
        await clearDownloadState(modelId, filename);
      } else if (downloadState != null && !downloadState.isCompleted) {
        // For partial downloads, always attempt to resume if file size is > 0 and <= totalBytes
        if (fileSize > 0 && fileSize <= downloadState.totalBytes) {
          Logger.info('EnhancedModelDownloader',
              'Partial file and state found. Will attempt to resume from $fileSize bytes.');
          // Do not delete, allow resume
        } else {
          Logger.info('EnhancedModelDownloader',
              'File size does not match state, deleting and clearing state.');
          await file.delete();
          await clearDownloadState(modelId, filename);
        }
      } else if (downloadState != null && downloadState.isCompleted) {
        // For completed downloads, you may want a stricter check (e.g., signature)
        // For now, just accept the file as valid if size matches
        if (fileSize == downloadState.totalBytes) {
          onProgress?.call(ProgressInfo(
            progress: 1.0,
            receivedBytes: fileSize,
            totalBytes: fileSize,
            speedBytesPerSec: 0,
            elapsed: Duration.zero,
            status: 'Model already downloaded',
          ));
          Logger.info(
              'EnhancedModelDownloader', 'Completed file found and accepted.');
          return filePath;
        } else {
          Logger.info('EnhancedModelDownloader',
              'Completed state but file size does not match, deleting and clearing state.');
          await file.delete();
          await clearDownloadState(modelId, filename);
        }
      }
    }
    // Always download if we reach here (file missing or just deleted)
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
    final file = File(filePath);
    final modelDir = file.parent;
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
      Logger.info('EnhancedModelDownloader',
          'Created model directory in download: \'${modelDir.path}\'');
    }

    // Check for existing download state
    DownloadState? existingState;
    int resumeFrom = 0;
    int fileSize = 0;
    bool fileExists = await file.exists();
    if (fileExists) {
      fileSize = await file.length();
    }
    existingState = await _getDownloadState(modelId, filename);
    Logger.info('EnhancedModelDownloader', '--- Download Start ---');
    Logger.info('EnhancedModelDownloader',
        'File exists: $fileExists, File size: $fileSize');
    Logger.info('EnhancedModelDownloader',
        'Download state: ${existingState != null ? existingState.toJson() : 'null'}');

    if (allowResume &&
        fileExists &&
        existingState != null &&
        !existingState.isCompleted &&
        existingState.error == null) {
      // Only resume if file size matches state
      if (fileSize <= existingState.totalBytes && fileSize > 0) {
        resumeFrom = fileSize;
        Logger.info('EnhancedModelDownloader',
            'Resuming download from $resumeFrom bytes (of ${existingState.totalBytes})');
      } else {
        Logger.info('EnhancedModelDownloader',
            'File size does not match state, clearing state and starting over.');
        await EnhancedModelDownloader.clearDownloadState(modelId, filename);
        resumeFrom = 0;
      }
    } else if (fileExists &&
        (existingState == null || existingState.isCompleted)) {
      Logger.info('EnhancedModelDownloader',
          'File exists but no valid resume state, starting fresh download.');
      resumeFrom = 0;
    } else {
      Logger.info('EnhancedModelDownloader',
          'No file or state, starting fresh download.');
      resumeFrom = 0;
    }

    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final request = http.Request(
            'GET',
            Uri.parse(
                'https://huggingface.co/$modelId/resolve/main/$filename'));
        request.headers['Authorization'] = 'Bearer $token';

        if (resumeFrom > 0) {
          request.headers['Range'] = 'bytes=$resumeFrom-';
        }

        Logger.info(
            'EnhancedModelDownloader',
            resumeFrom > 0
                ? 'Sending HTTP request with Range header: bytes=$resumeFrom-'
                : 'Starting fresh download');
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

          // Log every MB chunk
          if (received % (1024 * 1024) < chunk.length) {
            Logger.info('EnhancedModelDownloader',
                'Downloaded ${_formatBytes(received)} of ${_formatBytes(totalBytes)}');
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

        Logger.info('EnhancedModelDownloader',
            'Download completed: $filePath (${_formatBytes(received)})');

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
        Logger.warning(LogTags.enhancedModelDownloader,
            'Download attempt \\${attempt + 1} failed: $e');
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
          Logger.error('EnhancedModelDownloader',
              'Download failed after $maxRetries attempts.');
          rethrow;
        }

        // Wait before retry
        Logger.info('EnhancedModelDownloader',
            'Waiting before retry (attempt $attempt)...');
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
      Logger.error(
          LogTags.enhancedModelDownloader, 'Error reading download state',
          error: e);
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
      Logger.error(
          LogTags.enhancedModelDownloader, 'Error saving download state',
          error: e);
    }
  }

  static Future<void> clearDownloadState(
      String modelId, String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_downloadStatePrefix${modelId}_$filename';
      await prefs.remove(key);
    } catch (e) {
      Logger.error(
          LogTags.enhancedModelDownloader, 'Error clearing download state',
          error: e);
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

  /// Get the model file path
  static Future<String> getModelPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_modelFilename';
  }

  /// Check if model file exists
  static Future<bool> isModelDownloaded() async {
    try {
      final file = File(await getModelPath());
      return await file.exists();
    } catch (e) {
      Logger.error(
          LogTags.enhancedModelDownloader, 'Error checking model existence',
          error: e);
      return false;
    }
  }

  /// Get model file size
  static Future<int> getModelFileSize() async {
    try {
      final file = File(await getModelPath());
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      Logger.error(
          LogTags.enhancedModelDownloader, 'Error getting model file size',
          error: e);
      return 0;
    }
  }

  /// Delete model file
  static Future<bool> deleteModel() async {
    try {
      final file = File(await getModelPath());
      if (await file.exists()) {
        await file.delete();
        await clearDownloadState(
            'google/gemma-3n-E4B-it-litert-preview', _modelFilename);
        Logger.info(
            LogTags.enhancedModelDownloader, 'Model file deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      Logger.error(LogTags.enhancedModelDownloader, 'Error deleting model file',
          error: e);
      return false;
    }
  }
}
