import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/agent_bloc.dart';
import '../bloc/agent_events.dart';

class CreateAgentDialog extends StatefulWidget {
  const CreateAgentDialog({super.key});

  @override
  State<CreateAgentDialog> createState() => _CreateAgentDialogState();
}

class _CreateAgentDialogState extends State<CreateAgentDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final promptController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Custom Agent'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Agent Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: promptController,
              decoration: const InputDecoration(
                labelText: 'System Prompt',
                border: OutlineInputBorder(),
                hintText: 'Define the agent\'s behavior and capabilities...',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                descriptionController.text.isNotEmpty &&
                promptController.text.isNotEmpty) {
              context.read<AgentBloc>().add(
                    CreateAgent(
                      name: nameController.text,
                      description: descriptionController.text,
                      systemPrompt: promptController.text,
                    ),
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
