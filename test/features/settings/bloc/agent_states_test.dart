import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/settings/bloc/agent_states.dart';
import '../../../../lib/features/settings/models/agent_model.dart';

void main() {
  group('AgentState', () {
    group('AgentInitial', () {
      test('should be equatable', () {
        final state1 = AgentInitial();
        final state2 = AgentInitial();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = AgentInitial();
        expect(state.props, isEmpty);
      });
    });

    group('AgentLoading', () {
      test('should be equatable', () {
        final state1 = AgentLoading();
        final state2 = AgentLoading();
        expect(state1, state2);
      });

      test('should have empty props', () {
        final state = AgentLoading();
        expect(state.props, isEmpty);
      });
    });

    group('AgentLoaded', () {
      test('should create with required parameters', () {
        final agents = [
          AgentModel(
            id: 'agent-1',
            name: 'Agent 1',
            description: 'First agent',
            systemPrompt: 'You are agent 1',
            parameters: {'temperature': 0.7},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final templates = [
          AgentModel(
            id: 'template-1',
            name: 'Template 1',
            description: 'First template',
            systemPrompt: 'You are template 1',
            parameters: {'temperature': 0.8},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final state = AgentLoaded(
          agents: agents,
          templates: templates,
        );

        expect(state.agents, agents);
        expect(state.templates, templates);
        expect(state.activeAgent, null);
      });

      test('should create with active agent', () {
        final agents = [
          AgentModel(
            id: 'agent-1',
            name: 'Agent 1',
            description: 'First agent',
            systemPrompt: 'You are agent 1',
            parameters: {'temperature': 0.7},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final templates = [
          AgentModel(
            id: 'template-1',
            name: 'Template 1',
            description: 'First template',
            systemPrompt: 'You are template 1',
            parameters: {'temperature': 0.8},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final activeAgent = agents.first;
        final state = AgentLoaded(
          agents: agents,
          templates: templates,
          activeAgent: activeAgent,
        );

        expect(state.agents, agents);
        expect(state.templates, templates);
        expect(state.activeAgent, activeAgent);
      });

      test('should be equatable', () {
        final agents = [
          AgentModel(
            id: 'agent-1',
            name: 'Agent 1',
            description: 'First agent',
            systemPrompt: 'You are agent 1',
            parameters: {'temperature': 0.7},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final templates = [
          AgentModel(
            id: 'template-1',
            name: 'Template 1',
            description: 'First template',
            systemPrompt: 'You are template 1',
            parameters: {'temperature': 0.8},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final state1 = AgentLoaded(
          agents: agents,
          templates: templates,
        );
        final state2 = AgentLoaded(
          agents: agents,
          templates: templates,
        );
        final state3 = AgentLoaded(
          agents: [],
          templates: templates,
        );

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        final agents = [
          AgentModel(
            id: 'agent-1',
            name: 'Agent 1',
            description: 'First agent',
            systemPrompt: 'You are agent 1',
            parameters: {'temperature': 0.7},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final templates = [
          AgentModel(
            id: 'template-1',
            name: 'Template 1',
            description: 'First template',
            systemPrompt: 'You are template 1',
            parameters: {'temperature': 0.8},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final activeAgent = agents.first;
        final state = AgentLoaded(
          agents: agents,
          templates: templates,
          activeAgent: activeAgent,
        );

        expect(state.props, [agents, templates, activeAgent]);
      });

      test('should copyWith correctly', () {
        final agents1 = [
          AgentModel(
            id: 'agent-1',
            name: 'Agent 1',
            description: 'First agent',
            systemPrompt: 'You are agent 1',
            parameters: {'temperature': 0.7},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final agents2 = [
          AgentModel(
            id: 'agent-2',
            name: 'Agent 2',
            description: 'Second agent',
            systemPrompt: 'You are agent 2',
            parameters: {'temperature': 0.8},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final templates = [
          AgentModel(
            id: 'template-1',
            name: 'Template 1',
            description: 'First template',
            systemPrompt: 'You are template 1',
            parameters: {'temperature': 0.9},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final originalState = AgentLoaded(
          agents: agents1,
          templates: templates,
        );
        final copiedState = originalState.copyWith(
          agents: agents2,
          activeAgent: agents2.first,
        );

        expect(copiedState.agents, agents2);
        expect(copiedState.templates, templates); // Should keep original
        expect(copiedState.activeAgent, agents2.first);
        expect(originalState.agents, agents1); // Original should not change
        expect(originalState.activeAgent, null);
      });

      test('should copyWith with partial parameters', () {
        final agents = [
          AgentModel(
            id: 'agent-1',
            name: 'Agent 1',
            description: 'First agent',
            systemPrompt: 'You are agent 1',
            parameters: {'temperature': 0.7},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final templates = [
          AgentModel(
            id: 'template-1',
            name: 'Template 1',
            description: 'First template',
            systemPrompt: 'You are template 1',
            parameters: {'temperature': 0.8},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final originalState = AgentLoaded(
          agents: agents,
          templates: templates,
        );
        final copiedState = originalState.copyWith(
          activeAgent: agents.first,
        );

        expect(copiedState.agents, agents); // Should keep original
        expect(copiedState.templates, templates); // Should keep original
        expect(copiedState.activeAgent, agents.first);
      });
    });

    group('AgentError', () {
      test('should create with message', () {
        const state = AgentError('Test error message');
        expect(state.message, 'Test error message');
      });

      test('should be equatable', () {
        const state1 = AgentError('Error 1');
        const state2 = AgentError('Error 1');
        const state3 = AgentError('Error 2');

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        const state = AgentError('Test error message');
        expect(state.props, ['Test error message']);
      });
    });

    group('AgentCreating', () {
      test('should create with agent', () {
        final agent = AgentModel(
          id: 'agent-1',
          name: 'Agent 1',
          description: 'First agent',
          systemPrompt: 'You are agent 1',
          parameters: {'temperature': 0.7},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = AgentCreating(agent);
        expect(state.agent, agent);
      });

      test('should be equatable', () {
        final agent1 = AgentModel(
          id: 'agent-1',
          name: 'Agent 1',
          description: 'First agent',
          systemPrompt: 'You are agent 1',
          parameters: {'temperature': 0.7},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final agent2 = AgentModel(
          id: 'agent-2',
          name: 'Agent 2',
          description: 'Second agent',
          systemPrompt: 'You are agent 2',
          parameters: {'temperature': 0.8},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state1 = AgentCreating(agent1);
        final state2 = AgentCreating(agent1);
        final state3 = AgentCreating(agent2);

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        final agent = AgentModel(
          id: 'agent-1',
          name: 'Agent 1',
          description: 'First agent',
          systemPrompt: 'You are agent 1',
          parameters: {'temperature': 0.7},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = AgentCreating(agent);
        expect(state.props, [agent]);
      });
    });

    group('AgentUpdating', () {
      test('should create with agent', () {
        final agent = AgentModel(
          id: 'agent-1',
          name: 'Agent 1',
          description: 'First agent',
          systemPrompt: 'You are agent 1',
          parameters: {'temperature': 0.7},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = AgentUpdating(agent);
        expect(state.agent, agent);
      });

      test('should be equatable', () {
        final agent1 = AgentModel(
          id: 'agent-1',
          name: 'Agent 1',
          description: 'First agent',
          systemPrompt: 'You are agent 1',
          parameters: {'temperature': 0.7},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final agent2 = AgentModel(
          id: 'agent-2',
          name: 'Agent 2',
          description: 'Second agent',
          systemPrompt: 'You are agent 2',
          parameters: {'temperature': 0.8},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state1 = AgentUpdating(agent1);
        final state2 = AgentUpdating(agent1);
        final state3 = AgentUpdating(agent2);

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        final agent = AgentModel(
          id: 'agent-1',
          name: 'Agent 1',
          description: 'First agent',
          systemPrompt: 'You are agent 1',
          parameters: {'temperature': 0.7},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = AgentUpdating(agent);
        expect(state.props, [agent]);
      });
    });
  });
}
