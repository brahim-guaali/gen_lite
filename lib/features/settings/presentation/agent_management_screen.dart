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
import '../widgets/create_agent_dialog.dart';
import 'package:genlite/core/constants/app_constants.dart';

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
      length: 2,
      child: Column(
        children: [
          // Custom Tab Bar Container
          Container(
            margin: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusLarge),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              tabs: [
                _buildTab(
                  context,
                  icon: Icons.person,
                  label: 'My Agents',
                  badge: state.agents.length.toString(),
                ),
                _buildTab(
                  context,
                  icon: Icons.layers_outlined,
                  label: 'Templates',
                  badge: state.templates.length.toString(),
                ),
              ],
              labelColor: AppConstants.primaryColor,
              unselectedLabelColor: AppConstants.secondaryTextColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppConstants.primaryColorWithOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMyAgents(context, state.agents, state.activeAgent),
                _buildTemplates(context, state.templates),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? badge,
  }) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(label),
          if (badge != null) ...[
            const SizedBox(width: AppConstants.paddingSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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

  void _showCreateAgentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateAgentDialog(),
    );
  }
}
