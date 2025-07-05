import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/bloc/agent_bloc.dart';
import '../../settings/bloc/agent_events.dart';
import '../../settings/bloc/agent_states.dart';

class AgentSwitcherMenu extends StatelessWidget {
  const AgentSwitcherMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgentBloc, AgentState>(
      builder: (context, agentState) {
        if (agentState is AgentLoaded && agentState.agents.isNotEmpty) {
          return PopupMenuButton<String>(
            icon: const Icon(Icons.smart_toy),
            tooltip: 'Switch Agent',
            onSelected: (agentId) {
              if (agentId == 'none') {
                context.read<AgentBloc>().add(const SetActiveAgent(''));
              } else {
                context.read<AgentBloc>().add(SetActiveAgent(agentId));
              }
            },
            itemBuilder: (context) => [
              ...agentState.agents.map((agent) => PopupMenuItem(
                    value: agent.id,
                    child: Row(
                      children: [
                        Icon(
                          Icons.smart_toy,
                          size: 16,
                          color: agentState.activeAgent?.id == agent.id
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(agent.name)),
                        if (agentState.activeAgent?.id == agent.id)
                          Icon(
                            Icons.check,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  )),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'none',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 8),
                    const Text('Default AI'),
                    if (agentState.activeAgent == null)
                      Icon(
                        Icons.check,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
