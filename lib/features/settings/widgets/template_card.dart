import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/agent_bloc.dart';
import '../bloc/agent_events.dart';
import '../models/agent_model.dart';

class TemplateCard extends StatelessWidget {
  final AgentModel template;

  const TemplateCard({
    super.key,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          template.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          template.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: ElevatedButton(
          onPressed: () {
            context.read<AgentBloc>().add(ImportAgent(template));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Created agent from "${template.name}" template'),
              ),
            );
          },
          child: const Text('Use Template'),
        ),
        onTap: () => _showTemplateDetails(context),
      ),
    );
  }

  void _showTemplateDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${template.name} Template'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(template.description),
              const SizedBox(height: 16),
              Text(
                'System Prompt',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(template.systemPrompt),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AgentBloc>().add(ImportAgent(template));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Created agent from "${template.name}" template'),
                ),
              );
            },
            child: const Text('Use Template'),
          ),
        ],
      ),
    );
  }
}
