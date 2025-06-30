import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/services/storage_service.dart';
import 'agent_events.dart';
import 'agent_states.dart';
import '../models/agent_model.dart';

class AgentBloc extends Bloc<AgentEvent, AgentState> {
  List<AgentModel> _agents = [];
  List<AgentModel> _templates = [];
  AgentModel? _activeAgent;

  AgentBloc() : super(AgentInitial()) {
    on<CreateAgent>(_onCreateAgent);
    on<UpdateAgent>(_onUpdateAgent);
    on<DeleteAgent>(_onDeleteAgent);
    on<LoadAgents>(_onLoadAgents);
    on<SetActiveAgent>(_onSetActiveAgent);
    on<LoadAgentTemplates>(_onLoadAgentTemplates);
    on<ExportAgent>(_onExportAgent);
    on<ImportAgent>(_onImportAgent);
  }

  void _onCreateAgent(CreateAgent event, Emitter<AgentState> emit) async {
    try {
      emit(AgentLoading());

      final newAgent = AgentModel.create(
        name: event.name,
        description: event.description,
        systemPrompt: event.systemPrompt,
        parameters: event.parameters,
      );

      emit(AgentCreating(newAgent));

      _agents.add(newAgent);

      // Save to persistent storage
      await StorageService.saveAgent(newAgent);

      emit(AgentLoaded(
        agents: List.from(_agents),
        templates: List.from(_templates),
        activeAgent: _activeAgent,
      ));
    } catch (e) {
      emit(AgentError('Failed to create agent: ${e.toString()}'));
    }
  }

  void _onUpdateAgent(UpdateAgent event, Emitter<AgentState> emit) async {
    try {
      final agentIndex = _agents.indexWhere((agent) => agent.id == event.id);
      if (agentIndex == -1) return;

      final currentAgent = _agents[agentIndex];
      final updatedAgent = currentAgent.copyWith(
        name: event.name,
        description: event.description,
        systemPrompt: event.systemPrompt,
        parameters: event.parameters,
        updatedAt: DateTime.now(),
      );

      emit(AgentUpdating(updatedAgent));

      _agents[agentIndex] = updatedAgent;

      // Update active agent if it's the one being updated
      if (_activeAgent?.id == event.id) {
        _activeAgent = updatedAgent;
      }

      // Save to persistent storage
      await StorageService.updateAgent(updatedAgent);

      emit(AgentLoaded(
        agents: List.from(_agents),
        templates: List.from(_templates),
        activeAgent: _activeAgent,
      ));
    } catch (e) {
      emit(AgentError('Failed to update agent: ${e.toString()}'));
    }
  }

  void _onDeleteAgent(DeleteAgent event, Emitter<AgentState> emit) async {
    try {
      // Delete from storage
      await StorageService.deleteAgent(event.id);

      _agents.removeWhere((agent) => agent.id == event.id);

      // Clear active agent if it's the one being deleted
      if (_activeAgent?.id == event.id) {
        _activeAgent = null;
      }

      emit(AgentLoaded(
        agents: List.from(_agents),
        templates: List.from(_templates),
        activeAgent: _activeAgent,
      ));
    } catch (e) {
      emit(AgentError('Failed to delete agent: ${e.toString()}'));
    }
  }

  void _onLoadAgents(LoadAgents event, Emitter<AgentState> emit) async {
    try {
      emit(AgentLoading());

      // Load agents from persistent storage
      final savedAgents = await StorageService.loadAgents();
      _agents = savedAgents;

      emit(AgentLoaded(
        agents: List.from(_agents),
        templates: List.from(_templates),
        activeAgent: _activeAgent,
      ));
    } catch (e) {
      emit(AgentError('Failed to load agents: ${e.toString()}'));
    }
  }

  void _onSetActiveAgent(SetActiveAgent event, Emitter<AgentState> emit) async {
    try {
      final agent = _agents.firstWhere((agent) => agent.id == event.id);
      _activeAgent = agent;

      // Save active agent setting
      await StorageService.saveSetting('active_agent_id', agent.id);

      emit(AgentLoaded(
        agents: List.from(_agents),
        templates: List.from(_templates),
        activeAgent: _activeAgent,
      ));
    } catch (e) {
      emit(AgentError('Failed to set active agent: ${e.toString()}'));
    }
  }

  void _onLoadAgentTemplates(
      LoadAgentTemplates event, Emitter<AgentState> emit) async {
    try {
      _templates = List.from(AgentModel.templates);

      // Load saved agents and active agent
      await _loadSavedData();

      emit(AgentLoaded(
        agents: List.from(_agents),
        templates: List.from(_templates),
        activeAgent: _activeAgent,
      ));
    } catch (e) {
      emit(AgentError('Failed to load templates: ${e.toString()}'));
    }
  }

  void _onExportAgent(ExportAgent event, Emitter<AgentState> emit) async {
    try {
      final agent = _agents.firstWhere((agent) => agent.id == event.id);
      // In a real implementation, this would export to file or clipboard
      // For now, we'll just emit the current state
      emit(AgentLoaded(
        agents: List.from(_agents),
        templates: List.from(_templates),
        activeAgent: _activeAgent,
      ));
    } catch (e) {
      emit(AgentError('Failed to export agent: ${e.toString()}'));
    }
  }

  void _onImportAgent(ImportAgent event, Emitter<AgentState> emit) async {
    try {
      final importedAgent = event.agent.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: false,
        isTemplate: false,
      );

      _agents.add(importedAgent);

      // Save to persistent storage
      await StorageService.saveAgent(importedAgent);

      emit(AgentLoaded(
        agents: List.from(_agents),
        templates: List.from(_templates),
        activeAgent: _activeAgent,
      ));
    } catch (e) {
      emit(AgentError('Failed to import agent: ${e.toString()}'));
    }
  }

  // Helper method to load saved data
  Future<void> _loadSavedData() async {
    try {
      // Load saved agents
      final savedAgents = await StorageService.loadAgents();
      _agents = savedAgents;

      // Load active agent
      final activeAgentId =
          await StorageService.getSetting<String>('active_agent_id');
      if (activeAgentId != null) {
        try {
          _activeAgent =
              _agents.firstWhere((agent) => agent.id == activeAgentId);
        } catch (e) {
          // Active agent not found, clear the setting
          await StorageService.deleteSetting('active_agent_id');
        }
      }
    } catch (e) {
      // If loading fails, start with empty state
      _agents = [];
      _activeAgent = null;
    }
  }

  // Helper methods
  List<AgentModel> get agents => List.from(_agents);
  List<AgentModel> get templates => List.from(_templates);
  AgentModel? get activeAgent => _activeAgent;

  AgentModel? getAgentById(String id) {
    try {
      return _agents.firstWhere((agent) => agent.id == id);
    } catch (e) {
      return null;
    }
  }

  void createFromTemplate(AgentModel template) async {
    final newAgent = template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: false,
      isTemplate: false,
    );

    _agents.add(newAgent);

    // Save to persistent storage
    await StorageService.saveAgent(newAgent);
  }
}
