import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DownloadModel {
  final String modelUrl;
  final String modelFilename;

  DownloadModel({required this.modelUrl, required this.modelFilename});
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
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_preferenceKey) ?? false) {
      final filePath = await getFilePath();
      final file = File(filePath);
      if (file.existsSync()) {
        return true;
      }
    }

    try {
      final filePath = await getFilePath();
      final file = File(filePath);

      final token = dotenv.env['HUGGINGFACE_TOKEN'] ?? '';
      final Map<String, String> headers =
          token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {};
      final headResponse = await http.head(
        Uri.parse(model.modelUrl),
        headers: headers,
      );

      if (headResponse.statusCode == 200) {
        final contentLengthHeader = headResponse.headers['content-length'];
        if (contentLengthHeader != null) {
          final remoteFileSize = int.parse(contentLengthHeader);
          if (file.existsSync() && await file.length() == remoteFileSize) {
            await prefs.setBool(_preferenceKey, true);
            return true;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking model existence: $e');
      }
    }
    await prefs.setBool(_preferenceKey, false);
    return false;
  }

  /// Downloads the model file and tracks progress.
  Future<void> downloadModel({
    required String token,
    required Function(double) onProgress,
    Function(int receivedBytes, int totalBytes, double speedBytesPerSec,
            Duration elapsed)?
        onDetailedProgress,
  }) async {
    http.StreamedResponse? response;
    IOSink? fileSink;
    final prefs = await SharedPreferences.getInstance();

    try {
      final filePath = await getFilePath();
      final file = File(filePath);

      int downloadedBytes = 0;
      if (file.existsSync()) {
        downloadedBytes = await file.length();
      }

      final request = http.Request('GET', Uri.parse(model.modelUrl));
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (downloadedBytes > 0) {
        request.headers['Range'] = 'bytes=$downloadedBytes-';
      }

      response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 206) {
        final contentLength = response.contentLength ?? 0;
        final totalBytes = downloadedBytes + contentLength;
        fileSink = file.openWrite(mode: FileMode.append);

        int received = downloadedBytes;
        final stopwatch = Stopwatch()..start();
        int lastReceived = received;
        int lastMillis = 0;

        await for (final chunk in response.stream) {
          fileSink.add(chunk);
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

          onProgress(totalBytes > 0 ? received / totalBytes : 0.0);
          onDetailedProgress?.call(received, totalBytes, speed, elapsed);
        }
        await prefs.setBool(_preferenceKey, true);
      } else {
        await prefs.setBool(_preferenceKey, false);
        if (kDebugMode) {
          print(
            'Failed to download model. Status code: ${response.statusCode}',
          );
          print('Headers: ${response.headers}');
          try {
            final errorBody = await response.stream.bytesToString();
            print('Error body: $errorBody');
          } catch (e) {
            print('Could not read error body: $e');
          }
        }
        throw Exception('Failed to download the model.');
      }
    } catch (e) {
      await prefs.setBool(_preferenceKey, false);
      if (kDebugMode) {
        print('Error downloading model: $e');
      }
      rethrow;
    } finally {
      if (fileSink != null) await fileSink.close();
    }
  }
}
