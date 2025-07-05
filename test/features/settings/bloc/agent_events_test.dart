import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/settings/bloc/agent_events.dart';
import '../../../../lib/features/settings/models/agent_model.dart';

void main() {
  group('AgentEvent', () {
    group('CreateAgent', () {
      test('should create with required parameters', () {
        const event = CreateAgent(
          name: 'Test Agent',
          description: 'A test agent',
          systemPrompt: 'You are a helpful assistant',
        );
        expect(event.name, 'Test Agent');
        expect(event.description, 'A test agent');
        expect(event.systemPrompt, 'You are a helpful assistant');
        expect(event.parameters, null);
      });

      test('should create with optional parameters', () {
        const parameters = {'temperature': 0.7, 'maxTokens': 1000};
        const event = CreateAgent(
          name: 'Test Agent',
          description: 'A test agent',
          systemPrompt: 'You are a helpful assistant',
          parameters: parameters,
        );
        expect(event.parameters, parameters);
      });

      test('should be equatable', () {
        const event1 = CreateAgent(
          name: 'Agent 1',
          description: 'Description 1',
          systemPrompt: 'Prompt 1',
        );
        const event2 = CreateAgent(
          name: 'Agent 1',
          description: 'Description 1',
          systemPrompt: 'Prompt 1',
        );
        const event3 = CreateAgent(
          name: 'Agent 2',
          description: 'Description 2',
          systemPrompt: 'Prompt 2',
        );

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = CreateAgent(
          name: 'Test Agent',
          description: 'A test agent',
          systemPrompt: 'You are a helpful assistant',
        );
        expect(event.props, [
          'Test Agent',
          'A test agent',
          'You are a helpful assistant',
          null
        ]);
      });
    });

    group('UpdateAgent', () {
      test('should create with required parameters', () {
        const event = UpdateAgent(id: 'agent-1');
        expect(event.id, 'agent-1');
        expect(event.name, null);
        expect(event.description, null);
        expect(event.systemPrompt, null);
        expect(event.parameters, null);
      });

      test('should create with optional parameters', () {
        const parameters = {'temperature': 0.8};
        const event = UpdateAgent(
          id: 'agent-1',
          name: 'Updated Agent',
          description: 'Updated description',
          systemPrompt: 'Updated prompt',
          parameters: parameters,
        );
        expect(event.name, 'Updated Agent');
        expect(event.description, 'Updated description');
        expect(event.systemPrompt, 'Updated prompt');
        expect(event.parameters, parameters);
      });

      test('should be equatable', () {
        const event1 = UpdateAgent(
          id: 'agent-1',
          name: 'Agent 1',
        );
        const event2 = UpdateAgent(
          id: 'agent-1',
          name: 'Agent 1',
        );
        const event3 = UpdateAgent(
          id: 'agent-2',
          name: 'Agent 2',
        );

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = UpdateAgent(
          id: 'agent-1',
          name: 'Updated Agent',
        );
        expect(event.props, ['agent-1', 'Updated Agent', null, null, null]);
      });
    });

    group('DeleteAgent', () {
      test('should create with id', () {
        const event = DeleteAgent('agent-1');
        expect(event.id, 'agent-1');
      });

      test('should be equatable', () {
        const event1 = DeleteAgent('agent-1');
        const event2 = DeleteAgent('agent-1');
        const event3 = DeleteAgent('agent-2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = DeleteAgent('agent-1');
        expect(event.props, ['agent-1']);
      });
    });

    group('LoadAgents', () {
      test('should be equatable', () {
        final event1 = LoadAgents();
        final event2 = LoadAgents();
        expect(event1, event2);
      });

      test('should have empty props', () {
        final event = LoadAgents();
        expect(event.props, isEmpty);
      });
    });

    group('SetActiveAgent', () {
      test('should create with id', () {
        const event = SetActiveAgent('agent-1');
        expect(event.id, 'agent-1');
      });

      test('should be equatable', () {
        final event1 = SetActiveAgent('agent-1');
        final event2 = SetActiveAgent('agent-1');
        final event3 = SetActiveAgent('agent-2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = SetActiveAgent('agent-1');
        expect(event.props, ['agent-1']);
      });
    });

    group('LoadAgentTemplates', () {
      test('should be equatable', () {
        final event1 = LoadAgentTemplates();
        final event2 = LoadAgentTemplates();
        expect(event1, event2);
      });

      test('should have empty props', () {
        final event = LoadAgentTemplates();
        expect(event.props, isEmpty);
      });
    });

    group('ExportAgent', () {
      test('should create with id', () {
        const event = ExportAgent('agent-1');
        expect(event.id, 'agent-1');
      });

      test('should be equatable', () {
        const event1 = ExportAgent('agent-1');
        const event2 = ExportAgent('agent-1');
        const event3 = ExportAgent('agent-2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = ExportAgent('agent-1');
        expect(event.props, ['agent-1']);
      });
    });

    group('ImportAgent', () {
      test('should create with agent', () {
        final agent = AgentModel(
          id: 'agent-1',
          name: 'Test Agent',
          description: 'A test agent',
          systemPrompt: 'You are a helpful assistant',
          parameters: {'temperature': 0.7},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final event = ImportAgent(agent);
        expect(event.agent, agent);
      });

      test('should be equatable', () {
        final agent1 = AgentModel(
          id: 'agent-1',
          name: 'Agent 1',
          description: 'Description 1',
          systemPrompt: 'Prompt 1',
          parameters: {'temperature': 0.7},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final agent2 = AgentModel(
          id: 'agent-2',
          name: 'Agent 2',
          description: 'Description 2',
          systemPrompt: 'Prompt 2',
          parameters: {'temperature': 0.8},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final event1 = ImportAgent(agent1);
        final event2 = ImportAgent(agent1);
        final event3 = ImportAgent(agent2);

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        final agent = AgentModel(
          id: 'agent-1',
          name: 'Test Agent',
          description: 'A test agent',
          systemPrompt: 'You are a helpful assistant',
          parameters: {'temperature': 0.7},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final event = ImportAgent(agent);
        expect(event.props, [agent]);
      });
    });
  });
}
