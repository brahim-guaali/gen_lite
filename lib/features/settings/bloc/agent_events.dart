import 'package:equatable/equatable.dart';
import '../models/agent_model.dart';

abstract class AgentEvent extends Equatable {
  const AgentEvent();

  @override
  List<Object?> get props => [];
}

class CreateAgent extends AgentEvent {
  final String name;
  final String description;
  final String systemPrompt;
  final Map<String, dynamic>? parameters;

  const CreateAgent({
    required this.name,
    required this.description,
    required this.systemPrompt,
    this.parameters,
  });

  @override
  List<Object?> get props => [name, description, systemPrompt, parameters];
}

class UpdateAgent extends AgentEvent {
  final String id;
  final String? name;
  final String? description;
  final String? systemPrompt;
  final Map<String, dynamic>? parameters;

  const UpdateAgent({
    required this.id,
    this.name,
    this.description,
    this.systemPrompt,
    this.parameters,
  });

  @override
  List<Object?> get props => [id, name, description, systemPrompt, parameters];
}

class DeleteAgent extends AgentEvent {
  final String id;

  const DeleteAgent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadAgents extends AgentEvent {}

class SetActiveAgent extends AgentEvent {
  final String id;

  const SetActiveAgent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadAgentTemplates extends AgentEvent {}

class ExportAgent extends AgentEvent {
  final String id;

  const ExportAgent(this.id);

  @override
  List<Object?> get props => [id];
}

class ImportAgent extends AgentEvent {
  final AgentModel agent;

  const ImportAgent(this.agent);

  @override
  List<Object?> get props => [agent];
}
