import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';

/// Test configuration and utilities for GenLite tests
class TestConfig {
  static bool _isInitialized = false;
  static String? _testPath;
  static final List<String> _openBoxes = [];

  /// Initialize test environment
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Flutter binding
    TestWidgetsFlutterBinding.ensureInitialized();

    // Set up platform channel mocks to prevent MissingPluginException
    _setupPlatformMocks();

    // Create unique test path
    _testPath = '/tmp/test_documents_${DateTime.now().millisecondsSinceEpoch}';

    // Set up mock path provider with unique path
    PathProviderPlatform.instance = MockPathProvider(_testPath!);

    // Initialize Hive for testing
    await Hive.initFlutter(_testPath!);

    // Open test boxes
    await _openBox('settings');
    await _openBox('conversations');
    await _openBox('agents');
    await _openBox('files');

    _isInitialized = true;
  }

  /// Set up platform channel mocks to prevent MissingPluginException
  static void _setupPlatformMocks() {
    // Mock TTS plugin
    const MethodChannel ttsChannel = MethodChannel('flutter_tts');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'setLanguage':
        case 'setSpeechRate':
        case 'setVolume':
        case 'setPitch':
        case 'speak':
        case 'stop':
        case 'pause':
        case 'resume':
        case 'getLanguages':
        case 'getSpeechRates':
        case 'getVolumes':
        case 'getPitches':
          return null;
        default:
          return null;
      }
    });

    // Mock Speech to Text plugin
    const MethodChannel speechChannel =
        MethodChannel('plugin.csdcorp.com/speech_to_text');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(speechChannel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
        case 'start':
        case 'stop':
        case 'cancel':
        case 'listen':
          return null;
        default:
          return null;
      }
    });

    // Mock Path Provider plugin
    const MethodChannel pathChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsPath':
        case 'getApplicationSupportPath':
        case 'getDownloadsPath':
        case 'getExternalCachePath':
        case 'getExternalStoragePath':
        case 'getLibraryPath':
        case 'getTemporaryPath':
        case 'getApplicationCachePath':
          return '/tmp/test_path';
        default:
          return null;
      }
    });
  }

  /// Open a Hive box with error handling
  static Future<void> _openBox(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
        _openBoxes.add(boxName);
      }
    } catch (e) {
      // If box is already open, that's fine
      if (!_openBoxes.contains(boxName)) {
        _openBoxes.add(boxName);
      }
    }
  }

  /// Clean up test environment
  static Future<void> cleanup() async {
    try {
      // Close all open boxes
      for (final boxName in _openBoxes) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
        }
      }
      _openBoxes.clear();

      // Close Hive
      await Hive.close();

      // Clean up test directory
      if (_testPath != null) {
        final directory = Directory(_testPath!);
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      }

      // Reset platform mocks
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('plugin.csdcorp.com/speech_to_text'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'), null);
    } catch (e) {
      // Ignore cleanup errors
    } finally {
      _isInitialized = false;
      _testPath = null;
    }
  }

  /// Creates a test app with the given child widget
  static Widget createTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  /// Creates a test app with BLoC providers
  static Widget createTestAppWithBloc(
      Widget child, List<BlocProvider> providers) {
    return MultiBlocProvider(
      providers: providers,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  /// Waits for a specific condition to be true
  static Future<void> waitForCondition(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();
    while (!condition()) {
      if (DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException('Condition not met within timeout', timeout);
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Finds a widget by type and text
  static Finder findByTypeAndText<T extends Widget>(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(T),
    );
  }

  /// Taps a widget and waits for the action to complete
  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Enters text and waits for the action to complete
  static Future<void> enterTextAndWait(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Creates a mock LLM service for testing
  static MockLLMService createMockLLMService() {
    return MockLLMService();
  }
}

/// Mock Path Provider for testing
class MockPathProvider extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String _testPath;

  MockPathProvider(this._testPath);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return _testPath;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return '$_testPath/support';
  }

  @override
  Future<String?> getDownloadsPath() async {
    return '$_testPath/downloads';
  }

  @override
  Future<String?> getExternalCachePath() async {
    return '$_testPath/external_cache';
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return '$_testPath/external_storage';
  }

  @override
  Future<String?> getLibraryPath() async {
    return '$_testPath/library';
  }

  @override
  Future<String?> getTemporaryPath() async {
    return '$_testPath/temp';
  }

  @override
  Future<String?> getApplicationCachePath() async {
    return '$_testPath/cache';
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return ['$_testPath/external_cache1', '$_testPath/external_cache2'];
  }

  @override
  Future<List<String>?> getExternalStoragePaths(
      {StorageDirectory? type}) async {
    return ['$_testPath/external_storage1', '$_testPath/external_storage2'];
  }
}

/// Mock LLM Service for testing
class MockLLMService {
  bool _isReady = false;
  String _lastResponse = '';

  bool get isReady => _isReady;

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isReady = true;
  }

  Future<String> processMessage(String message,
      {Function(String)? onToken}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _lastResponse = 'Mock response to: $message';

    if (onToken != null) {
      for (final token in _lastResponse.split(' ')) {
        onToken(token);
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    return _lastResponse;
  }

  String get lastResponse => _lastResponse;
}

/// Common test data for GenLite tests
class TestData {
  static const String sampleUserMessage = 'Hello, this is a test message';
  static const String sampleAIResponse =
      'Hello! I am an AI assistant. How can I help you today?';
  static const String sampleConversationTitle = 'Test Conversation';

  static const List<String> quickStartPrompts = [
    'Help me write a professional email',
    'Explain a complex topic simply',
    'Brainstorm ideas for a project',
    'Help me learn something new',
  ];
}

/// Common test matchers for GenLite tests
class TestMatchers {
  /// Matches a widget that has the given text
  static Finder hasText(String text) {
    return find.text(text);
  }

  /// Matches a widget that contains the given text
  static Finder containsText(String text) {
    return find.textContaining(text);
  }

  /// Matches a widget that has the given icon
  static Finder hasIcon(IconData icon) {
    return find.byIcon(icon);
  }

  /// Matches a widget that is enabled
  static Matcher isEnabled() {
    return predicate<Widget>((widget) {
      if (widget is StatelessWidget) return true;
      if (widget is StatefulWidget) return true;
      return false;
    });
  }

  /// Matches a widget that is visible
  static Matcher isVisible() {
    return predicate<Widget>((widget) {
      return widget is! Offstage || !widget.offstage;
    });
  }
}
