import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

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

/// Ensures the Gemma model file is present locally. Downloads from Hugging Face if missing.
/// Returns the local file path.
Future<String> ensureGemmaModel({
  String modelId = 'google/gemma-3n-E4B-it-litert-preview',
  String filename = 'gemma-3n-E4B-it-int4.task',
}) async {
  return ensureGemmaModelWithProgress(
    modelId: modelId,
    filename: filename,
    onProgress: null,
  );
}

/// Enhanced version: supports progress and retry logic.
Future<String> ensureGemmaModelWithProgress({
  String modelId = 'google/gemma-3n-E4B-it-litert-preview',
  String filename = 'gemma-3n-E4B-it-int4.task',
  void Function(ProgressInfo info)? onProgress,
  int maxRetries = 3,
}) async {
  final docDir = await getApplicationDocumentsDirectory();
  final modelDir = Directory('${docDir.path}/gemma2b');
  if (!await modelDir.exists()) {
    await modelDir.create(recursive: true);
  }
  final filePath = '${modelDir.path}/$filename';
  final file = File(filePath);
  if (await file.exists()) {
    onProgress?.call(ProgressInfo(
      progress: 1.0,
      receivedBytes: 0,
      totalBytes: 0,
      speedBytesPerSec: 0,
      elapsed: Duration.zero,
    ));
    return filePath;
  }

  final token = dotenv.env['HUGGINGFACE_TOKEN'];
  if (token == null || token.isEmpty) {
    print('[ModelDownloader] ERROR: Hugging Face token not found in .env');
    throw Exception('Hugging Face token not found in .env');
  } else {
    print(
        '[ModelDownloader] Hugging Face token found, length: [32m${token.length}[0m');
  }

  final url =
      Uri.parse('https://huggingface.co/$modelId/resolve/main/$filename');
  print('[ModelDownloader] Downloading model from: [34m$url[0m');
  int attempt = 0;
  while (attempt < maxRetries) {
    try {
      final request = http.Request('GET', url);
      request.headers['Authorization'] = 'Bearer $token';
      final response = await request.send();
      print(
          '[ModelDownloader] HTTP status: [33m${response.statusCode} ${response.reasonPhrase}[0m');
      if (response.statusCode != 200) {
        // Try to read the error body for more info
        final errorBody = await response.stream.bytesToString();
        print('[ModelDownloader] ERROR BODY: $errorBody');
        throw Exception(
            'Failed to download model: ${response.statusCode} ${response.reasonPhrase}');
      }
      final contentLength = response.contentLength ?? 0;
      final sink = file.openWrite();
      int received = 0;
      final stopwatch = Stopwatch()..start();
      int lastReceived = 0;
      int lastMillis = 0;
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
        if (contentLength > 0) {
          onProgress?.call(ProgressInfo(
            progress: received / contentLength,
            receivedBytes: received,
            totalBytes: contentLength,
            speedBytesPerSec: speed,
            elapsed: elapsed,
          ));
        }
      }
      await sink.close();
      onProgress?.call(ProgressInfo(
        progress: 1.0,
        receivedBytes: received,
        totalBytes: contentLength,
        speedBytesPerSec: 0,
        elapsed: stopwatch.elapsed,
      ));
      print('[ModelDownloader] Model download complete: $filePath');
      return filePath;
    } catch (e) {
      print('[ModelDownloader] Download attempt ${attempt + 1} failed: $e');
      attempt++;
      if (attempt >= maxRetries) {
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }
  throw Exception('Failed to download model after $maxRetries attempts');
}
