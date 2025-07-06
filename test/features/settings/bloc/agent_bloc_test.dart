import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../lib/features/settings/bloc/agent_bloc.dart';
import '../../../../lib/features/settings/bloc/agent_events.dart';
import '../../../../lib/features/settings/bloc/agent_states.dart';
import '../../../../lib/features/settings/models/agent_model.dart';
import '../../../test_config.dart';

void main() {
  group('AgentBloc', () {
    late AgentBloc agentBloc;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    setUp(() async {
      // Ensure Hive boxes are open before creating the bloc
      if (!Hive.isBoxOpen('agents')) {
        await Hive.openBox('agents');
      }
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }

      agentBloc = AgentBloc();
    });

    tearDown(() async {
      agentBloc.close();

      // Clear test data
      if (Hive.isBoxOpen('agents')) {
        await Hive.box('agents').clear();
      }
      if (Hive.isBoxOpen('settings')) {
        await Hive.box('settings').clear();
      }
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    test('initial state should be AgentInitial', () {
      expect(agentBloc.state, isA<AgentInitial>());
    });

    group('CreateAgent', () {
      const testAgent = CreateAgent(
        name: 'Test Agent',
        description: 'Test Description',
        systemPrompt: 'You are a helpful assistant',
        parameters: {'temperature': 0.7},
      );

      blocTest<AgentBloc, AgentState>(
        'should emit [AgentLoading, AgentCreating] when CreateAgent is added',
        build: () => agentBloc,
        act: (bloc) => bloc.add(testAgent),
        expect: () => [
          isA<AgentLoading>(),
          isA<AgentCreating>(),
        ],
        verify: (bloc) {
          // Verify that the agent was created in memory
          expect(bloc.agents.length, 1);
          expect(bloc.agents.first.name, 'Test Agent');
        },
      );

      blocTest<AgentBloc, AgentState>(
        'should emit AgentError when storage fails',
        build: () => agentBloc,
        act: (bloc) async {
          // Close the agents box to simulate storage failure
          if (Hive.isBoxOpen('agents')) {
            await Hive.box('agents').close();
          }
          bloc.add(testAgent);
        },
        expect: () => [
          isA<AgentLoading>(),
          isA<AgentCreating>(),
          isA<AgentError>(),
        ],
      );
    });

    group('LoadAgentTemplates', () {
      blocTest<AgentBloc, AgentState>(
        'should emit [AgentLoaded] with templates when LoadAgentTemplates is successful',
        build: () => agentBloc,
        act: (bloc) => bloc.add(LoadAgentTemplates()),
        expect: () => [
          isA<AgentLoaded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as AgentLoaded;
          expect(state.templates.length, greaterThan(0));
        },
      );
    });

    group('LoadAgents', () {
      blocTest<AgentBloc, AgentState>(
        'should emit [AgentLoading, AgentLoaded] when LoadAgents is added',
        build: () => agentBloc,
        act: (bloc) => bloc.add(LoadAgents()),
        expect: () => [
          isA<AgentLoading>(),
          isA<AgentLoaded>(),
        ],
      );
    });

    group('Helper methods', () {
      test('getAgentById should return null when no agents exist', () {
        final foundAgent = agentBloc.getAgentById('non-existent-id');
        expect(foundAgent, isNull);
      });

      test('agents getter should return empty list initially', () {
        expect(agentBloc.agents, isEmpty);
      });

      test('templates getter should return empty list initially', () {
        expect(agentBloc.templates, isEmpty);
      });

      test('activeAgent getter should return null initially', () {
        expect(agentBloc.activeAgent, isNull);
      });
    });

    group('AgentModel templates', () {
      test('should have predefined templates', () {
        final templates = AgentModel.templates;
        expect(templates, isNotEmpty);

        for (final template in templates) {
          expect(template.isTemplate, isTrue);
          expect(template.name, isNotEmpty);
          expect(template.description, isNotEmpty);
          expect(template.systemPrompt, isNotEmpty);
        }
      });

      test('should be able to create agent from template', () {
        final template = AgentModel.templates.first;
        final newAgent = AgentModel.create(
          name: template.name,
          description: template.description,
          systemPrompt: template.systemPrompt,
        );

        expect(newAgent.name, template.name);
        expect(newAgent.isTemplate, isFalse);
        expect(newAgent.isActive, isFalse);
      });
    });

    group('AgentModel', () {
      test('should create agent with correct properties', () {
        final agent = AgentModel.create(
          name: 'Test Agent',
          description: 'Test Description',
          systemPrompt: 'Test prompt',
          parameters: {'temperature': 0.7},
        );

        expect(agent.name, 'Test Agent');
        expect(agent.description, 'Test Description');
        expect(agent.systemPrompt, 'Test prompt');
        expect(agent.parameters, {'temperature': 0.7});
        expect(agent.isTemplate, isFalse);
        expect(agent.isActive, isFalse);
        expect(agent.id, isNotEmpty);
        expect(agent.createdAt, isA<DateTime>());
        expect(agent.updatedAt, isA<DateTime>());
      });

      test('should copy agent with new values', () {
        final original = AgentModel.create(
          name: 'Original',
          description: 'Original Description',
          systemPrompt: 'Original prompt',
        );

        final copied = original.copyWith(
          name: 'Updated',
          description: 'Updated Description',
        );

        expect(copied.name, 'Updated');
        expect(copied.description, 'Updated Description');
        expect(copied.systemPrompt, 'Original prompt');
        expect(copied.id, original.id);
        expect(copied.createdAt, original.createdAt);
        expect(copied.updatedAt, isNot(original.updatedAt));
      });

      test('should convert to and from JSON', () {
        final original = AgentModel.create(
          name: 'Test Agent',
          description: 'Test Description',
          systemPrompt: 'Test prompt',
          parameters: {'temperature': 0.7},
        );

        final json = original.toJson();
        final fromJson = AgentModel.fromJson(json);

        expect(fromJson.name, original.name);
        expect(fromJson.description, original.description);
        expect(fromJson.systemPrompt, original.systemPrompt);
        expect(fromJson.parameters, original.parameters);
        expect(fromJson.id, original.id);
        expect(fromJson.isTemplate, original.isTemplate);
        expect(fromJson.isActive, original.isActive);
      });
    });
  });
}
