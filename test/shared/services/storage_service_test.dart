import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/shared/services/storage_service.dart';
import 'package:genlite/features/settings/models/agent_model.dart';
import 'package:genlite/features/chat/bloc/chat_states.dart';
import 'package:genlite/shared/models/conversation.dart';
import 'package:genlite/shared/models/message.dart';
import '../../test_config.dart';

void main() {
  group('StorageService', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    tearDown(() async {
      // Clear all data after each test
      final conversations = await StorageService.loadConversations();
      for (final conversation in conversations) {
        await StorageService.deleteConversation(conversation['id']);
      }

      final agents = await StorageService.loadAgents();
      for (final agent in agents) {
        await StorageService.deleteAgent(agent.id);
      }

      // Clear settings
      await StorageService.deleteSetting('test_key');
      await StorageService.deleteSetting('string_key');
      await StorageService.deleteSetting('int_key');
      await StorageService.deleteSetting('bool_key');
      await StorageService.deleteSetting('double_key');
    });

    group('Agent Management', () {
      test('should save and retrieve agent', () async {
        final agent = AgentModel.create(
          name: 'Test Agent',
          description: 'A test agent',
          systemPrompt: 'You are a helpful assistant.',
        );

        await StorageService.saveAgent(agent);
        final allAgents = await StorageService.loadAgents();
        final retrieved = allAgents.firstWhere((a) => a.id == agent.id);

        expect(retrieved.name, equals(agent.name));
        expect(retrieved.description, equals(agent.description));
        expect(retrieved.systemPrompt, equals(agent.systemPrompt));
      });

      test('should get all agents', () async {
        final agent1 = AgentModel.create(
          name: 'Agent 1',
          description: 'First agent',
          systemPrompt: 'Prompt 1',
        );
        final agent2 = AgentModel.create(
          name: 'Agent 2',
          description: 'Second agent',
          systemPrompt: 'Prompt 2',
        );

        await StorageService.saveAgent(agent1);
        await StorageService.saveAgent(agent2);

        final allAgents = await StorageService.loadAgents();

        expect(allAgents.length, greaterThanOrEqualTo(2));
        expect(allAgents.any((a) => a.id == agent1.id), isTrue);
        expect(allAgents.any((a) => a.id == agent2.id), isTrue);
      });

      test('should update existing agent', () async {
        final agent = AgentModel.create(
          name: 'Original Name',
          description: 'Original description',
          systemPrompt: 'Original prompt',
        );
        await StorageService.saveAgent(agent);

        final updatedAgent = agent.copyWith(name: 'Updated Name');
        await StorageService.updateAgent(updatedAgent);

        final allAgents = await StorageService.loadAgents();
        final retrieved = allAgents.firstWhere((a) => a.id == agent.id);
        expect(retrieved.name, equals('Updated Name'));
      });

      test('should delete agent', () async {
        final agent = AgentModel.create(
          name: 'Test Agent',
          description: 'A test agent',
          systemPrompt: 'You are a helpful assistant.',
        );
        await StorageService.saveAgent(agent);

        await StorageService.deleteAgent(agent.id);

        final allAgents = await StorageService.loadAgents();
        expect(allAgents.any((a) => a.id == agent.id), isFalse);
      });
    });

    group('Settings Management', () {
      test('should save and retrieve setting', () async {
        await StorageService.saveSetting('test_key', 'test_value');
        final retrieved = await StorageService.getSetting<String>('test_key');

        expect(retrieved, equals('test_value'));
      });

      test('should return null for non-existent setting', () async {
        final retrieved =
            await StorageService.getSetting<String>('non-existent-key');
        expect(retrieved, isNull);
      });

      test('should update existing setting', () async {
        await StorageService.saveSetting('test_key', 'original_value');
        await StorageService.saveSetting('test_key', 'updated_value');

        final retrieved = await StorageService.getSetting<String>('test_key');
        expect(retrieved, equals('updated_value'));
      });

      test('should handle different data types', () async {
        await StorageService.saveSetting('string_key', 'string_value');
        await StorageService.saveSetting('int_key', 42);
        await StorageService.saveSetting('bool_key', true);
        await StorageService.saveSetting('double_key', 3.14);

        expect(await StorageService.getSetting<String>('string_key'),
            equals('string_value'));
        expect(await StorageService.getSetting<int>('int_key'), equals(42));
        expect(await StorageService.getSetting<bool>('bool_key'), equals(true));
        expect(await StorageService.getSetting<double>('double_key'),
            equals(3.14));
      });

      test('should delete setting', () async {
        await StorageService.saveSetting('test_key', 'test_value');
        await StorageService.deleteSetting('test_key');

        final retrieved = await StorageService.getSetting<String>('test_key');
        expect(retrieved, isNull);
      });

      test('should handle default values', () async {
        final retrieved = await StorageService.getSetting<String>(
            'non-existent-key',
            defaultValue: 'default');
        expect(retrieved, equals('default'));
      });
    });

    group('Conversation Management', () {
      test('should save and load conversations', () async {
        final conversation = Conversation.create(title: 'Test Conversation');
        final message = Message.create(
          content: 'Hello',
          role: MessageRole.user,
          conversationId: conversation.id,
        );
        final conversationWithMessage = conversation.addMessage(message);

        final chatLoaded = ChatLoaded(
          currentConversation: conversationWithMessage,
          conversations: [conversationWithMessage],
          isProcessing: false,
        );

        await StorageService.saveConversation(chatLoaded);
        final conversations = await StorageService.loadConversations();

        expect(conversations, isNotEmpty);
        final savedConversation = conversations.first;
        expect(savedConversation['title'], equals('Test Conversation'));
      });

      test('should delete conversation', () async {
        final conversation = Conversation.create(title: 'Test Conversation');
        final chatLoaded = ChatLoaded(
          currentConversation: conversation,
          conversations: [conversation],
          isProcessing: false,
        );

        await StorageService.saveConversation(chatLoaded);
        await StorageService.deleteConversation(conversation.id);

        final conversations = await StorageService.loadConversations();
        expect(conversations.any((c) => c['id'] == conversation.id), isFalse);
      });

      test('should update conversation title', () async {
        final conversation = Conversation.create(title: 'Original Title');
        final chatLoaded = ChatLoaded(
          currentConversation: conversation,
          conversations: [conversation],
          isProcessing: false,
        );

        await StorageService.saveConversation(chatLoaded);
        await StorageService.updateConversationTitle(
            conversation.id, 'Updated Title');

        final conversations = await StorageService.loadConversations();
        final updatedConversation =
            conversations.firstWhere((c) => c['id'] == conversation.id);
        expect(updatedConversation['title'], equals('Updated Title'));
      });
    });

    group('Search Functionality', () {
      test('should search conversations by title', () async {
        final conversation = Conversation.create(title: 'Test Conversation');
        final chatLoaded = ChatLoaded(
          currentConversation: conversation,
          conversations: [conversation],
          isProcessing: false,
        );

        await StorageService.saveConversation(chatLoaded);
        final results = await StorageService.searchConversations('Test');

        expect(results, isNotEmpty);
        expect(results.first['title'], contains('Test'));
      });

      test('should search conversations by message content', () async {
        final conversation = Conversation.create(title: 'Test Conversation');
        final message = Message.create(
          content: 'Hello world',
          role: MessageRole.user,
          conversationId: conversation.id,
        );
        final conversationWithMessage = conversation.addMessage(message);

        final chatLoaded = ChatLoaded(
          currentConversation: conversationWithMessage,
          conversations: [conversationWithMessage],
          isProcessing: false,
        );

        await StorageService.saveConversation(chatLoaded);
        final results = await StorageService.searchConversations('world');

        expect(results, isNotEmpty);
      });

      test('should return empty results for non-matching query', () async {
        final conversation = Conversation.create(title: 'Test Conversation');
        final chatLoaded = ChatLoaded(
          currentConversation: conversation,
          conversations: [conversation],
          isProcessing: false,
        );

        await StorageService.saveConversation(chatLoaded);
        final results =
            await StorageService.searchConversations('non-matching-query');

        expect(results, isEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle invalid conversation ID', () async {
        await StorageService.deleteConversation('');
        // Should not throw an error
      });

      test('should handle invalid agent ID', () async {
        await StorageService.deleteAgent('');
        // Should not throw an error
      });

      test('should handle null values in settings', () async {
        await StorageService.saveSetting('null_key', null);
        final retrieved = await StorageService.getSetting('null_key');
        expect(retrieved, isNull);
      });

      test('should handle empty strings', () async {
        await StorageService.saveSetting('empty_key', '');
        final retrieved = await StorageService.getSetting<String>('empty_key');
        expect(retrieved, equals(''));
      });
    });
  });
}
