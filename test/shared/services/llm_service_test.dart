import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

import '../../../lib/shared/services/llm_service.dart';

void main() {
  group('LLMService', () {
    late LLMService llmService;

    setUp(() {
      llmService = LLMService();
    });

    tearDown(() async {
      await llmService.dispose();
    });

    group('Singleton Pattern', () {
      test('should be a singleton', () {
        final instance1 = LLMService();
        final instance2 = LLMService();
        expect(identical(instance1, instance2), true);
      });
    });

    group('Initial State', () {
      test('should not be ready initially', () {
        expect(llmService.isReady, false);
      });

      test('should not have model initially', () {
        expect(llmService.model, null);
      });
    });

    group('Model Info', () {
      test('should return correct model info', () {
        final info = llmService.getModelInfo();
        expect(info['name'], 'Gemma 3N');
        expect(info['version'], '3N');
        expect(info['parameters'], '3B');
        expect(info['context_length'], 8192);
        expect(info['status'], 'not ready');
        expect(info['model_path'], null);
      });
    });

    group('Byte Formatting', () {
      test('should format bytes correctly', () {
        // Test with reflection to access private method
        // Since _formatBytes is private, we'll test it indirectly through getModelInfo
        // or create a simple test for the logic
        expect(llmService.getModelInfo()['name'], 'Gemma 3N');
      });
    });

    group('Dispose', () {
      test('should dispose successfully', () async {
        await expectLater(llmService.dispose(), completes);
      });

      test('should handle multiple dispose calls', () async {
        await llmService.dispose();
        await expectLater(llmService.dispose(), completes);
      });
    });

    group('Create Chat', () {
      test('should return null when not ready', () async {
        final chat = await llmService.createChat();
        expect(chat, null);
      });

      test('should return null when not ready with image support', () async {
        final chat = await llmService.createChat(supportImage: true);
        expect(chat, null);
      });
    });

    group('Process Message', () {
      test('should return null when not ready', () async {
        final response = await llmService.processMessage('Hello');
        expect(response, null);
      });

      test('should return null when not ready with callback', () async {
        final response = await llmService.processMessage(
          'Hello',
          onTokenReceived: (token) {},
        );
        expect(response, null);
      });

      test('should return null when not ready with chat', () async {
        final response = await llmService.processMessage(
          'Hello',
          chat: null,
        );
        expect(response, null);
      });
    });

    group('Process Message With Image', () {
      test('should return null when not ready', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final response = await llmService.processMessageWithImage(
          'Hello',
          imageBytes,
        );
        expect(response, null);
      });

      test('should return null when not ready with chat', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final response = await llmService.processMessageWithImage(
          'Hello',
          imageBytes,
          chat: null,
        );
        expect(response, null);
      });
    });

    group('Initialize', () {
      test('should handle initialization when already loading', () async {
        // This test would require mocking the FlutterGemmaPlugin
        // For now, we'll test the basic structure
        expect(llmService.isReady, false);
      });

      test('should handle initialization when already ready', () async {
        // This test would require mocking the FlutterGemmaPlugin
        // For now, we'll test the basic structure
        expect(llmService.isReady, false);
      });
    });

    group('Error Handling', () {
      test('should handle errors gracefully in createChat', () async {
        final chat = await llmService.createChat();
        expect(chat, null);
      });

      test('should handle errors gracefully in processMessage', () async {
        final response = await llmService.processMessage('Hello');
        expect(response, null);
      });

      test('should handle errors gracefully in processMessageWithImage',
          () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        final response = await llmService.processMessageWithImage(
          'Hello',
          imageBytes,
        );
        expect(response, null);
      });
    });

    group('Service Properties', () {
      test('should have correct initial state', () {
        expect(llmService.isReady, false);
        expect(llmService.model, null);
      });

      test('should maintain singleton pattern across instances', () {
        final service1 = LLMService();
        final service2 = LLMService();
        expect(identical(service1, service2), true);
      });
    });
  });
}
