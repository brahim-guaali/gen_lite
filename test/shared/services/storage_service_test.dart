import 'package:flutter_test/flutter_test.dart';

import '../../../lib/shared/services/storage_service.dart';

void main() {
  group('StorageService', () {
    group('Method Signatures', () {
      test('should have saveSetting method with correct signature', () {
        expect(StorageService.saveSetting, isA<Function>());
      });

      test('should have getSetting method with correct signature', () {
        expect(StorageService.getSetting, isA<Function>());
      });

      test('should have deleteSetting method with correct signature', () {
        expect(StorageService.deleteSetting, isA<Function>());
      });

      test('should have clearAllData method with correct signature', () {
        expect(StorageService.clearAllData, isA<Function>());
      });

      test('should have close method with correct signature', () {
        expect(StorageService.close, isA<Function>());
      });
    });

    group('Static Methods', () {
      test('should have initialize method', () {
        expect(StorageService.initialize, isA<Function>());
      });

      test('should have conversation methods', () {
        expect(StorageService.saveConversation, isA<Function>());
        expect(StorageService.loadConversations, isA<Function>());
        expect(StorageService.deleteConversation, isA<Function>());
        expect(StorageService.updateConversationTitle, isA<Function>());
      });

      test('should have file methods', () {
        expect(StorageService.saveFile, isA<Function>());
        expect(StorageService.loadFiles, isA<Function>());
        expect(StorageService.deleteFile, isA<Function>());
        expect(StorageService.updateFile, isA<Function>());
      });

      test('should have agent methods', () {
        expect(StorageService.saveAgent, isA<Function>());
        expect(StorageService.loadAgents, isA<Function>());
        expect(StorageService.deleteAgent, isA<Function>());
        expect(StorageService.updateAgent, isA<Function>());
      });

      test('should have search methods', () {
        expect(StorageService.searchConversations, isA<Function>());
      });

      test('should have export methods', () {
        expect(StorageService.exportConversationToText, isA<Function>());
        expect(StorageService.exportConversationToJson, isA<Function>());
      });
    });

    group('Export Functionality', () {
      test('should export conversation to text', () {
        final conversation = <String, dynamic>{
          'title': 'Test Conversation',
          'messages': [
            {
              'role': 'user',
              'content': 'Hello',
              'timestamp': '2023-01-01T00:00:00Z',
            },
            {
              'role': 'assistant',
              'content': 'Hi there!',
              'timestamp': '2023-01-01T00:01:00Z',
            },
          ],
        };

        final exported = StorageService.exportConversationToText(conversation);

        expect(exported, isA<String>());
        expect(exported, contains('Test Conversation'));
        expect(exported, contains('Hello'));
        expect(exported, contains('Hi there!'));
        expect(exported, contains('USER'));
        expect(exported, contains('ASSISTANT'));
      });

      test('should export conversation to JSON', () {
        final conversation = <String, dynamic>{
          'title': 'Test Conversation',
          'messages': [
            {
              'role': 'user',
              'content': 'Hello',
            },
          ],
        };

        final exported = StorageService.exportConversationToJson(conversation);

        expect(exported, isA<String>());
        expect(exported, contains('Test Conversation'));
        expect(exported, contains('Hello'));
      });

      test('should handle empty conversation in text export', () {
        final conversation = <String, dynamic>{
          'title': '',
          'messages': [],
        };

        final exported = StorageService.exportConversationToText(conversation);

        expect(exported, isA<String>());
        expect(exported, contains('Generated on:'));
      });

      test('should handle missing fields in text export', () {
        final conversation = <String, dynamic>{};

        final exported = StorageService.exportConversationToText(conversation);

        expect(exported, isA<String>());
        expect(exported, contains('Conversation'));
        expect(exported, contains('Generated on:'));
      });

      test('should handle missing message fields in text export', () {
        final conversation = <String, dynamic>{
          'title': 'Test',
          'messages': [
            {
              'role': 'user',
              // Missing content and timestamp
            },
          ],
        };

        final exported = StorageService.exportConversationToText(conversation);

        expect(exported, isA<String>());
        expect(exported, contains('USER'));
      });
    });
  });
}
