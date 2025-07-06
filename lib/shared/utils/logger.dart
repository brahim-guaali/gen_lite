import 'package:flutter/foundation.dart';

/// Centralized logging utility for GenLite app
class Logger {
  static const String _appTag = '[GenLite]';

  /// Log debug information (only in debug mode)
  static void debug(String tag, String message, {Object? data}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final dataStr = data != null ? ' | Data: $data' : '';
      print('$timestamp $_appTag $tag $message$dataStr');
    }
  }

  /// Log information messages
  static void info(String tag, String message, {Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final dataStr = data != null ? ' | Data: $data' : '';
    print('$timestamp $_appTag $tag $message$dataStr');
  }

  /// Log warning messages
  static void warning(String tag, String message, {Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final dataStr = data != null ? ' | Data: $data' : '';
    print('$timestamp $_appTag $tag ⚠️  $message$dataStr');
  }

  /// Log error messages
  static void error(String tag, String message,
      {Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final errorStr = error != null ? ' | Error: $error' : '';
    final stackStr = stackTrace != null ? ' | Stack: $stackTrace' : '';
    print('$timestamp $_appTag $tag ❌ $message$errorStr$stackStr');
  }

  /// Log method entry (debug mode only)
  static void logMethod(String className, String methodName,
      {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      final paramStr = params != null ? ' | Params: $params' : '';
      print('$_appTag [$className] Entering $methodName$paramStr');
    }
  }

  /// Log method exit (debug mode only)
  static void logMethodExit(String className, String methodName,
      {Object? result}) {
    if (kDebugMode) {
      final resultStr = result != null ? ' | Result: $result' : '';
      print('$_appTag [$className] Exiting $methodName$resultStr');
    }
  }

  /// Log state transitions in BLoCs
  static void logStateTransition(
      String blocName, String fromState, String toState) {
    if (kDebugMode) {
      print('$_appTag [$blocName] State: $fromState → $toState');
    }
  }

  /// Log performance metrics
  static void logPerformance(String tag, String operation, int milliseconds) {
    if (kDebugMode) {
      final status = milliseconds > 1000 ? '⚠️  SLOW' : '✅';
      print('$_appTag $tag $status $operation took ${milliseconds}ms');
    }
  }
}

/// Convenience methods for common logging patterns
class LogTags {
  static const String chatBloc = '[ChatBloc]';
  static const String voiceBloc = '[VoiceBloc]';
  static const String fileBloc = '[FileBloc]';
  static const String agentBloc = '[AgentBloc]';
  static const String onboardingBloc = '[OnboardingBloc]';
  static const String chatService = '[ChatService]';
  static const String llmService = '[LLMService]';
  static const String ttsService = '[TTSService]';
  static const String speechService = '[SpeechService]';
  static const String storageService = '[StorageService]';
  static const String fileProcessingService = '[FileProcessingService]';
  static const String modelDownloader = '[ModelDownloader]';
  static const String enhancedModelDownloader = '[EnhancedModelDownloader]';
  static const String gemmaDownloader = '[GemmaDownloader]';
  static const String permissions = '[Permissions]';
}
