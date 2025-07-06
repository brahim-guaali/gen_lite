import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/core/constants/app_constants.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';
import 'package:genlite/shared/widgets/voice_components.dart';

class VoiceSettingsSection extends StatelessWidget {
  const VoiceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        return Column(
          children: [
            // Voice Output Toggle with improved design
            _buildVoiceOutputToggle(context, state),

            const SizedBox(height: 16),

            // Voice Status Indicator
            _buildVoiceStatusIndicator(context, state),
          ],
        );
      },
    );
  }

  Widget _buildVoiceOutputToggle(BuildContext context, VoiceState state) {
    bool isEnabled = false;
    bool isAvailable = false;

    if (state is VoiceReady) {
      isEnabled = state.voiceOutputEnabled;
      isAvailable = true;
    } else if (state is VoiceOutputEnabled) {
      isEnabled = state.enabled;
      isAvailable = true;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isEnabled
            ? AppConstants.primaryColorWithOpacity(0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: isEnabled
              ? AppConstants.primaryColorWithOpacity(0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppConstants.primaryColorWithOpacity(0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.volume_up,
              color: isEnabled ? AppConstants.primaryColor : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Output',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? AppConstants.primaryColor
                            : Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Read AI responses aloud',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: isAvailable
                ? (value) {
                    context.read<VoiceBloc>().add(ToggleVoiceOutput(value));
                  }
                : null,
            activeColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceStatusIndicator(BuildContext context, VoiceState state) {
    if (state is VoiceInitializing) {
      return _buildStatusCard(
        context,
        icon: Icons.hourglass_empty,
        title: 'Initializing Voice Services',
        subtitle: 'Setting up speech recognition and text-to-speech...',
        color: Colors.orange,
        showProgress: true,
      );
    }

    if (state is VoiceListening) {
      return _buildStatusCard(
        context,
        icon: Icons.mic,
        title: 'Listening',
        subtitle: 'Speak now to input your message',
        color: Colors.red,
        isAnimated: true,
      );
    }

    if (state is VoiceProcessing) {
      return _buildStatusCard(
        context,
        icon: Icons.sync,
        title: 'Processing',
        subtitle: 'Converting speech to text...',
        color: Colors.blue,
        showProgress: true,
      );
    }

    if (state is VoiceError) {
      return _buildStatusCard(
        context,
        icon: Icons.error_outline,
        title: 'Voice Error',
        subtitle: state.message,
        color: Colors.red,
        isError: true,
      );
    }

    if (state is VoiceNotAvailable) {
      return _buildStatusCard(
        context,
        icon: Icons.mic_off,
        title: 'Voice Not Available',
        subtitle: state.reason,
        color: Colors.red,
        isError: true,
      );
    }

    if (state is VoiceReady || state is VoiceOutputEnabled) {
      return _buildStatusCard(
        context,
        icon: Icons.check_circle,
        title: 'Voice Ready',
        subtitle: 'Voice services are active and ready to use',
        color: Colors.green,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool isError = false,
    bool showProgress = false,
    bool isAnimated = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isError
            ? color.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (isAnimated)
            _buildAnimatedIcon(icon, color)
          else
            Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          if (showProgress)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(icon, color: color, size: 24),
        );
      },
    );
  }
}
