import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/core/constants/app_constants.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';
import 'package:genlite/shared/widgets/ui_components.dart';
import '../widgets/voice_settings_section.dart';
import '../widgets/voice_preferences_panel.dart';

class VoiceSettingsScreen extends StatelessWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<VoiceBloc, VoiceState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(context, state),

                const SizedBox(height: AppConstants.paddingLarge),

                // Voice Status Section
                _buildVoiceStatusSection(context, state),

                const SizedBox(height: AppConstants.paddingLarge),

                // Voice Controls Section
                _buildVoiceControlsSection(context, state),

                const SizedBox(height: AppConstants.paddingLarge),

                // Voice Settings Section
                if (state is VoiceReady || state is VoiceOutputEnabled)
                  _buildVoiceSettingsSection(context, state),

                const SizedBox(height: AppConstants.paddingLarge),

                // Error Section
                if (state is VoiceError || state is VoiceNotAvailable)
                  _buildErrorSection(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, VoiceState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColorWithOpacity(0.1),
            AppConstants.primaryColorWithOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColorWithOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.record_voice_over,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Assistant',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure voice input and output settings',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusIndicator(context, state),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, VoiceState state) {
    IconData icon;
    Color color;
    String text;

    if (state is VoiceInitializing) {
      icon = Icons.hourglass_empty;
      color = Colors.orange;
      text = 'Initializing voice services...';
    } else if (state is VoiceReady) {
      icon = Icons.check_circle;
      color = Colors.green;
      text = 'Voice services ready';
    } else if (state is VoiceOutputEnabled) {
      icon = Icons.volume_up;
      color = Colors.blue;
      text = 'Voice output enabled';
    } else if (state is VoiceError) {
      icon = Icons.error;
      color = Colors.red;
      text = 'Voice error occurred';
    } else if (state is VoiceNotAvailable) {
      icon = Icons.mic_off;
      color = Colors.red;
      text = 'Voice not available';
    } else {
      icon = Icons.help;
      color = Colors.grey;
      text = 'Voice status unknown';
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceStatusSection(BuildContext context, VoiceState state) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusRow('Speech Recognition',
              state is VoiceReady || state is VoiceOutputEnabled),
          const SizedBox(height: 8),
          _buildStatusRow('Text-to-Speech',
              state is VoiceReady || state is VoiceOutputEnabled),
          const SizedBox(height: 8),
          _buildStatusRow('Microphone Access',
              state is VoiceReady || state is VoiceOutputEnabled),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isAvailable) {
    return Row(
      children: [
        Icon(
          isAvailable ? Icons.check_circle : Icons.cancel,
          color: isAvailable ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isAvailable ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceControlsSection(BuildContext context, VoiceState state) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.control_camera,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Controls',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const VoiceSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildVoiceSettingsSection(BuildContext context, VoiceState state) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Preferences',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const VoicePreferencesPanel(),
        ],
      ),
    );
  }

  Widget _buildErrorSection(BuildContext context, VoiceState state) {
    String title;
    String message;
    IconData icon;

    if (state is VoiceError) {
      title = 'Voice Error';
      message = state.message;
      icon = Icons.error_outline;
    } else if (state is VoiceNotAvailable) {
      title = 'Voice Not Available';
      message = state.reason;
      icon = Icons.mic_off;
    } else {
      return const SizedBox.shrink();
    }

    return AppCard(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Retry',
                  onPressed: () {
                    context
                        .read<VoiceBloc>()
                        .add(const RetryVoiceInitialization());
                  },
                  icon: Icons.refresh,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Settings',
                  onPressed: () {
                    // Navigate to app settings
                    Navigator.of(context).pop();
                  },
                  icon: Icons.settings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
