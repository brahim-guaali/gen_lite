import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';
import 'package:genlite/core/constants/app_constants.dart';

/// Voice input button with microphone icon
class VoiceInputButton extends StatelessWidget {
  final Function(String text)? onVoiceInput;
  final bool isEnabled;
  final double size;

  const VoiceInputButton({
    super.key,
    this.onVoiceInput,
    this.isEnabled = true,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        final isListening = state is VoiceReady && state.isListening;
        final isAvailable = state is VoiceReady || state is VoiceOutputEnabled;

        return IconButton(
          icon: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: isListening
                ? Colors.red
                : (isAvailable && isEnabled ? null : Colors.grey),
            size: size * 0.6,
          ),
          onPressed: isAvailable && isEnabled
              ? () {
                  if (isListening) {
                    context.read<VoiceBloc>().add(const StopListening());
                  } else {
                    context.read<VoiceBloc>().add(const StartListening());
                  }
                }
              : null,
          style: IconButton.styleFrom(
            backgroundColor:
                isListening ? Colors.red.withValues(alpha: 0.1) : null,
            shape: const CircleBorder(),
            minimumSize: Size(size, size),
          ),
        );
      },
    );
  }
}

/// Toggle switch for voice output
class VoiceOutputToggle extends StatelessWidget {
  final String title;
  final String subtitle;

  const VoiceOutputToggle({
    super.key,
    this.title = 'Voice Output',
    this.subtitle = 'Read AI responses aloud',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        bool isEnabled = false;
        bool isAvailable = false;

        if (state is VoiceReady) {
          isEnabled = state.voiceOutputEnabled;
          isAvailable = true;
        } else if (state is VoiceOutputEnabled) {
          isEnabled = state.enabled;
          isAvailable = true;
        }

        return SwitchListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          value: isEnabled,
          onChanged: isAvailable
              ? (value) {
                  context.read<VoiceBloc>().add(ToggleVoiceOutput(value));
                }
              : null,
          secondary: Icon(
            Icons.volume_up,
            color: isEnabled ? AppConstants.primaryColor : Colors.grey,
          ),
        );
      },
    );
  }
}

/// Panel for voice settings configuration
class VoiceSettingsPanel extends StatelessWidget {
  const VoiceSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        if (state is VoiceError) {
          return Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Voice Error',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<VoiceBloc>()
                          .add(const RetryVoiceInitialization());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is VoiceNotAvailable) {
          return Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.mic_off,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Voice Not Available',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.reason,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<VoiceBloc>()
                          .add(const RetryVoiceInitialization());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! VoiceReady && state is! VoiceOutputEnabled) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Voice settings not available'),
            ),
          );
        }

        String language = 'en-US';
        double speechRate = 0.5;
        double volume = 1.0;
        double pitch = 1.0;

        if (state is VoiceReady) {
          language = state.language;
          speechRate = state.speechRate;
          volume = state.volume;
          pitch = state.pitch;
        } else if (state is VoiceOutputEnabled) {
          language = state.language;
          speechRate = state.speechRate;
          volume = state.volume;
          pitch = state.pitch;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Language setting
                ListTile(
                  title: const Text('Speech Language'),
                  subtitle: Text(language),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showLanguageSelector(context, language),
                ),

                const Divider(),

                // Speech rate setting
                ListTile(
                  title: const Text('Speech Rate'),
                  subtitle: Slider(
                    value: speechRate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(speechRate * 100).round()}%',
                    onChanged: (value) {
                      context.read<VoiceBloc>().add(
                            UpdateVoiceSettings(speechRate: value),
                          );
                    },
                  ),
                ),

                const Divider(),

                // Volume setting
                ListTile(
                  title: const Text('Volume'),
                  subtitle: Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(volume * 100).round()}%',
                    onChanged: (value) {
                      context.read<VoiceBloc>().add(
                            UpdateVoiceSettings(volume: value),
                          );
                    },
                  ),
                ),

                const Divider(),

                // Pitch setting
                ListTile(
                  title: const Text('Pitch'),
                  subtitle: Slider(
                    value: pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: '${pitch.toStringAsFixed(1)}x',
                    onChanged: (value) {
                      context.read<VoiceBloc>().add(
                            UpdateVoiceSettings(pitch: value),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context, String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }
}

/// Dialog for selecting speech language
class LanguageSelectorDialog extends StatefulWidget {
  const LanguageSelectorDialog({super.key});

  @override
  State<LanguageSelectorDialog> createState() => _LanguageSelectorDialogState();
}

class _LanguageSelectorDialogState extends State<LanguageSelectorDialog> {
  List<Map<String, String>> _languages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    try {
      // This would typically come from the TTS service
      // For now, we'll use a predefined list
      _languages = [
        {'name': 'English (US)', 'code': 'en-US'},
        {'name': 'English (UK)', 'code': 'en-GB'},
        {'name': 'Spanish', 'code': 'es-ES'},
        {'name': 'French', 'code': 'fr-FR'},
        {'name': 'German', 'code': 'de-DE'},
        {'name': 'Italian', 'code': 'it-IT'},
        {'name': 'Portuguese', 'code': 'pt-PT'},
        {'name': 'Russian', 'code': 'ru-RU'},
        {'name': 'Japanese', 'code': 'ja-JP'},
        {'name': 'Korean', 'code': 'ko-KR'},
        {'name': 'Chinese (Simplified)', 'code': 'zh-CN'},
        {'name': 'Chinese (Traditional)', 'code': 'zh-TW'},
      ];
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Language'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  return ListTile(
                    title: Text(language['name']!),
                    onTap: () {
                      context.read<VoiceBloc>().add(
                            UpdateVoiceSettings(language: language['code']),
                          );
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Voice status indicator widget
class VoiceStatusIndicator extends StatelessWidget {
  const VoiceStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        if (state is VoiceInitializing) {
          return const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Initializing voice...'),
            ],
          );
        }

        if (state is VoiceListening) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Listening...'),
            ],
          );
        }

        if (state is VoiceProcessing) {
          return const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Processing...'),
            ],
          );
        }

        if (state is VoiceError) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Text(state.message),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
