import 'package:flutter/material.dart';
import '../models/agent_model.dart';
import 'template_card.dart';

class TemplateList extends StatelessWidget {
  final List<AgentModel> templates;

  const TemplateList({
    super.key,
    required this.templates,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return TemplateCard(template: template);
      },
    );
  }
}
