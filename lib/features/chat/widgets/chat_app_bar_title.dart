import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/bloc/agent_bloc.dart';
import '../../settings/bloc/agent_states.dart';

class ChatAppBarTitle extends StatelessWidget {
  const ChatAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgentBloc, AgentState>(
      builder: (context, agentState) {
        if (agentState is AgentLoaded && agentState.activeAgent != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GenLite'),
              Text(
                agentState.activeAgent!.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
            ],
          );
        }
        return const Text('GenLite');
      },
    );
  }
}
