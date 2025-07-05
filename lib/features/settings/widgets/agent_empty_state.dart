import 'package:flutter/material.dart';

class AgentEmptyState extends StatelessWidget {
  final VoidCallback onCreateAgent;

  const AgentEmptyState({super.key, required this.onCreateAgent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Custom Agents',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create custom AI agents for different tasks',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateAgent,
            icon: const Icon(Icons.add),
            label: const Text('Create Agent'),
          ),
        ],
      ),
    );
  }
}
