import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/agent_bloc.dart';
import '../bloc/agent_states.dart';
import '../models/agent_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/agent_empty_state.dart';
import '../widgets/agent_error_message.dart';
import '../widgets/agent_list.dart';
import '../widgets/template_list.dart';
import '../widgets/voice_settings_section.dart';
import '../widgets/create_agent_dialog.dart';

class AgentManagementScreen extends StatelessWidget {
  const AgentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Agents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAgentDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AgentBloc, AgentState>(
        builder: (context, state) {
          if (state is AgentLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is AgentError) {
            return AgentErrorMessage(message: state.message);
          }

          if (state is AgentLoaded) {
            return _buildAgentList(context, state);
          }

          return AgentEmptyState(
              onCreateAgent: () => _showCreateAgentDialog(context));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateAgentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAgentList(BuildContext context, AgentLoaded state) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'My Agents'),
              Tab(text: 'Templates'),
              Tab(text: 'Voice'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMyAgents(context, state.agents, state.activeAgent),
                _buildTemplates(context, state.templates),
                _buildVoiceSettings(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAgents(
      BuildContext context, List<AgentModel> agents, AgentModel? activeAgent) {
    return AgentList(
      agents: agents,
      activeAgent: activeAgent,
      onCreateAgent: () => _showCreateAgentDialog(context),
    );
  }

  Widget _buildTemplates(BuildContext context, List<AgentModel> templates) {
    return TemplateList(templates: templates);
  }

  Widget _buildVoiceSettings(BuildContext context) {
    return const VoiceSettingsSection();
  }

  void _showCreateAgentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateAgentDialog(),
    );
  }
}
