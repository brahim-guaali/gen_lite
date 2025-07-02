import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/features/settings/models/agent_model.dart';

void main() {
  group('AgentModel', () {
    test('should create agent with required fields', () {
      final agent = AgentModel.create(
        name: 'Test Agent',
        description: 'A test agent',
        systemPrompt: 'You are a helpful assistant.',
      );

      expect(agent.name, equals('Test Agent'));
      expect(agent.description, equals('A test agent'));
      expect(agent.systemPrompt, equals('You are a helpful assistant.'));
      expect(agent.id, isNotEmpty);
      expect(agent.createdAt, isNotNull);
      expect(agent.updatedAt, isNotNull);
      expect(agent.isTemplate, isFalse);
    });

    test('should create agent with custom parameters', () {
      final parameters = {
        'temperature': 0.7,
        'maxTokens': 1000,
      };

      final agent = AgentModel.create(
        name: 'Custom Agent',
        description: 'A custom agent',
        systemPrompt: 'You are a custom assistant.',
        parameters: parameters,
      );

      expect(agent.parameters, equals(parameters));
    });

    test('should copy agent with new values', () {
      final original = AgentModel.create(
        name: 'Original Agent',
        description: 'Original description',
        systemPrompt: 'Original prompt',
      );

      final copied = original.copyWith(
        name: 'Updated Agent',
        description: 'Updated description',
      );

      expect(copied.id, equals(original.id));
      expect(copied.name, equals('Updated Agent'));
      expect(copied.description, equals('Updated description'));
      expect(copied.systemPrompt, equals(original.systemPrompt));
    });

    test('should mark agent as template', () {
      final agent = AgentModel.create(
        name: 'Template Agent',
        description: 'A template agent',
        systemPrompt: 'You are a template assistant.',
      );

      final templateAgent = agent.copyWith(isTemplate: true);
      expect(templateAgent.isTemplate, isTrue);
    });

    test('should handle empty name', () {
      final agent = AgentModel.create(
        name: '',
        description: 'Test description',
        systemPrompt: 'Test prompt',
      );

      expect(agent.name, equals(''));
    });

    test('should handle empty description', () {
      final agent = AgentModel.create(
        name: 'Test Agent',
        description: '',
        systemPrompt: 'Test prompt',
      );

      expect(agent.description, equals(''));
    });

    test('should handle empty system prompt', () {
      final agent = AgentModel.create(
        name: 'Test Agent',
        description: 'Test description',
        systemPrompt: '',
      );

      expect(agent.systemPrompt, equals(''));
    });

    test('should handle long text fields', () {
      final longName = 'A' * 100;
      final longDescription = 'B' * 200;
      final longPrompt = 'C' * 500;

      final agent = AgentModel.create(
        name: longName,
        description: longDescription,
        systemPrompt: longPrompt,
      );

      expect(agent.name, equals(longName));
      expect(agent.description, equals(longDescription));
      expect(agent.systemPrompt, equals(longPrompt));
    });

    test('should have unique IDs', () {
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

      expect(agent1.id, isNot(equals(agent2.id)));
    });

    test('should update timestamp when modified', () {
      final agent = AgentModel.create(
        name: 'Test Agent',
        description: 'Test description',
        systemPrompt: 'Test prompt',
      );

      final updatedAgent = agent.copyWith(name: 'Updated Agent');

      expect(updatedAgent.updatedAt.isAfter(agent.updatedAt), isTrue);
    });

    test('should handle complex parameters', () {
      final complexParameters = {
        'temperature': 0.8,
        'maxTokens': 1500,
        'topP': 0.9,
        'frequencyPenalty': 0.1,
        'presencePenalty': 0.2,
      };

      final agent = AgentModel.create(
        name: 'Complex Agent',
        description: 'An agent with complex parameters',
        systemPrompt: 'You are a complex assistant.',
        parameters: complexParameters,
      );

      expect(agent.parameters, equals(complexParameters));
    });

    test('should handle null parameters', () {
      final agent = AgentModel.create(
        name: 'Simple Agent',
        description: 'A simple agent',
        systemPrompt: 'You are a simple assistant.',
      );

      expect(agent.parameters, isNull);
    });

    test('should create agent with custom ID', () {
      final agent = AgentModel(
        id: 'custom-id',
        name: 'Custom Agent',
        description: 'A custom agent',
        systemPrompt: 'You are a custom assistant.',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        parameters: const <String, dynamic>{},
        isTemplate: false,
      );

      expect(agent.id, equals('custom-id'));
    });

    test('should handle equality correctly', () {
      final agent1 = AgentModel.create(
        name: 'Test Agent',
        description: 'Test description',
        systemPrompt: 'Test prompt',
      );

      final agent2 = AgentModel.create(
        name: 'Test Agent',
        description: 'Test description',
        systemPrompt: 'Test prompt',
      );

      // Agents with different IDs should not be equal
      expect(agent1, isNot(equals(agent2)));
    });

    test('should handle toString correctly', () {
      final agent = AgentModel.create(
        name: 'Test Agent',
        description: 'Test description',
        systemPrompt: 'Test prompt',
      );

      final string = agent.toString();
      expect(string, contains('Test Agent'));
      expect(string, contains(agent.id));
    });

    test('should create template agent', () {
      final templateAgent = AgentModel.create(
        name: 'Template Agent',
        description: 'A template agent',
        systemPrompt: 'You are a template assistant.',
      ).copyWith(isTemplate: true);

      expect(templateAgent.isTemplate, isTrue);
      expect(templateAgent.name, equals('Template Agent'));
    });

    test('should update all fields', () {
      final original = AgentModel.create(
        name: 'Original',
        description: 'Original description',
        systemPrompt: 'Original prompt',
        parameters: const {'temp': 0.5},
      );

      final updated = original.copyWith(
        name: 'Updated',
        description: 'Updated description',
        systemPrompt: 'Updated prompt',
        parameters: {'temp': 0.8},
        isTemplate: true,
      );

      expect(updated.name, equals('Updated'));
      expect(updated.description, equals('Updated description'));
      expect(updated.systemPrompt, equals('Updated prompt'));
      expect(updated.parameters, equals({'temp': 0.8}));
      expect(updated.isTemplate, isTrue);
      expect(updated.id, equals(original.id));
    });

    test('should handle special characters in text fields', () {
      const specialName = 'Agent with special chars: !@#\$%^&*()';
      const specialDescription = 'Description with emojis: 🚀✨🎉';
      const specialPrompt = 'Prompt with quotes: "Hello" and \'world\'';

      final agent = AgentModel.create(
        name: specialName,
        description: specialDescription,
        systemPrompt: specialPrompt,
      );

      expect(agent.name, equals(specialName));
      expect(agent.description, equals(specialDescription));
      expect(agent.systemPrompt, equals(specialPrompt));
    });

    test('should handle whitespace in text fields', () {
      final agent = AgentModel.create(
        name: '  Agent with spaces  ',
        description: '  Description with spaces  ',
        systemPrompt: '  Prompt with spaces  ',
      );

      expect(agent.name, equals('  Agent with spaces  '));
      expect(agent.description, equals('  Description with spaces  '));
      expect(agent.systemPrompt, equals('  Prompt with spaces  '));
    });
  });
}
