import 'package:equatable/equatable.dart';
import '../models/agent_model.dart';

abstract class AgentState extends Equatable {
  const AgentState();

  @override
  List<Object?> get props => [];
}

class AgentInitial extends AgentState {}

class AgentLoading extends AgentState {}

class AgentLoaded extends AgentState {
  final List<AgentModel> agents;
  final List<AgentModel> templates;
  final AgentModel? activeAgent;

  const AgentLoaded({
    required this.agents,
    required this.templates,
    this.activeAgent,
  });

  AgentLoaded copyWith({
    List<AgentModel>? agents,
    List<AgentModel>? templates,
    AgentModel? activeAgent,
  }) {
    return AgentLoaded(
      agents: agents ?? this.agents,
      templates: templates ?? this.templates,
      activeAgent: activeAgent ?? this.activeAgent,
    );
  }

  @override
  List<Object?> get props => [agents, templates, activeAgent];
}

class AgentError extends AgentState {
  final String message;

  const AgentError(this.message);

  @override
  List<Object?> get props => [message];
}

class AgentCreating extends AgentState {
  final AgentModel agent;

  const AgentCreating(this.agent);

  @override
  List<Object?> get props => [agent];
}

class AgentUpdating extends AgentState {
  final AgentModel agent;

  const AgentUpdating(this.agent);

  @override
  List<Object?> get props => [agent];
}
