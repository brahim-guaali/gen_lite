import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/core/constants/app_constants.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';

class VoicePreferencesPanel extends StatelessWidget {
  const VoicePreferencesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        if (state is! VoiceReady && state is! VoiceOutputEnabled) {
          return const SizedBox.shrink();
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

        return Column(
          children: [
            _buildLanguageSetting(context, language),
            const SizedBox(height: 16),
            _buildSpeechRateSetting(context, speechRate),
            const SizedBox(height: 16),
            _buildVolumeSetting(context, volume),
            const SizedBox(height: 16),
            _buildPitchSetting(context, pitch),
          ],
        );
      },
    );
  }

  Widget _buildLanguageSetting(BuildContext context, String currentLanguage) {
    return _buildSettingCard(
      context,
      icon: Icons.language,
      title: 'Speech Language',
      subtitle: _getLanguageDisplayName(currentLanguage),
      onTap: () => _showLanguageSelector(context, currentLanguage),
      showArrow: true,
    );
  }

  Widget _buildSpeechRateSetting(BuildContext context, double speechRate) {
    return _buildSettingCard(
      context,
      icon: Icons.speed,
      title: 'Speech Rate',
      subtitle: '${(speechRate * 100).round()}%',
      child: Slider(
        value: speechRate,
        min: 0.1,
        max: 1.0,
        divisions: 9,
        activeColor: AppConstants.primaryColor,
        onChanged: (value) {
          context.read<VoiceBloc>().add(
                UpdateVoiceSettings(speechRate: value),
              );
        },
      ),
    );
  }

  Widget _buildVolumeSetting(BuildContext context, double volume) {
    return _buildSettingCard(
      context,
      icon: Icons.volume_up,
      title: 'Volume',
      subtitle: '${(volume * 100).round()}%',
      child: Slider(
        value: volume,
        min: 0.0,
        max: 1.0,
        divisions: 10,
        activeColor: AppConstants.primaryColor,
        onChanged: (value) {
          context.read<VoiceBloc>().add(
                UpdateVoiceSettings(volume: value),
              );
        },
      ),
    );
  }

  Widget _buildPitchSetting(BuildContext context, double pitch) {
    return _buildSettingCard(
      context,
      icon: Icons.tune,
      title: 'Pitch',
      subtitle: '${pitch.toStringAsFixed(1)}x',
      child: Slider(
        value: pitch,
        min: 0.5,
        max: 2.0,
        divisions: 15,
        activeColor: AppConstants.primaryColor,
        onChanged: (value) {
          context.read<VoiceBloc>().add(
                UpdateVoiceSettings(pitch: value),
              );
        },
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? child,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColorWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
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
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: 16),
            child,
          ],
        ],
      ),
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    final languageMap = {
      'en-US': 'English (US)',
      'en-GB': 'English (UK)',
      'es-ES': 'Spanish',
      'fr-FR': 'French',
      'de-DE': 'German',
      'it-IT': 'Italian',
      'pt-PT': 'Portuguese',
      'ru-RU': 'Russian',
      'ja-JP': 'Japanese',
      'ko-KR': 'Korean',
      'zh-CN': 'Chinese (Simplified)',
      'zh-TW': 'Chinese (Traditional)',
    };
    return languageMap[languageCode] ?? languageCode;
  }

  void _showLanguageSelector(BuildContext context, String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }
}

/// Modern language selector dialog
class LanguageSelectorDialog extends StatefulWidget {
  const LanguageSelectorDialog({super.key});

  @override
  State<LanguageSelectorDialog> createState() => _LanguageSelectorDialogState();
}

class _LanguageSelectorDialogState extends State<LanguageSelectorDialog> {
  List<Map<String, String>> _languages = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    try {
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

  List<Map<String, String>> get _filteredLanguages {
    if (_searchQuery.isEmpty) {
      return _languages;
    }
    return _languages
        .where((lang) =>
            lang['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppConstants.primaryColorWithOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.borderRadiusLarge),
                  topRight: Radius.circular(AppConstants.borderRadiusLarge),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: AppConstants.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Language',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search languages...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Language list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredLanguages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No languages found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredLanguages.length,
                          itemBuilder: (context, index) {
                            final language = _filteredLanguages[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppConstants.primaryColorWithOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.language,
                                  color: AppConstants.primaryColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                language['name']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(language['code']!),
                              onTap: () {
                                context.read<VoiceBloc>().add(
                                      UpdateVoiceSettings(
                                          language: language['code']),
                                    );
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
            ),

            // Cancel button
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
