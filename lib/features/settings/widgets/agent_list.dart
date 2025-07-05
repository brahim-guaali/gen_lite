import 'package:flutter/material.dart';
import '../models/agent_model.dart';
import 'agent_card.dart';
import 'agent_empty_state.dart';

class AgentList extends StatelessWidget {
  final List<AgentModel> agents;
  final AgentModel? activeAgent;
  final VoidCallback onCreateAgent;

  const AgentList({
    super.key,
    required this.agents,
    required this.activeAgent,
    required this.onCreateAgent,
  });

  @override
  Widget build(BuildContext context) {
    if (agents.isEmpty) {
      return AgentEmptyState(onCreateAgent: onCreateAgent);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        return AgentCard(
          agent: agent,
          isActive: activeAgent?.id == agent.id,
        );
      },
    );
  }
}
