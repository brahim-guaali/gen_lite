import 'package:flutter/material.dart';
import '../widgets/voice_settings_section.dart';

class VoiceSettingsScreen extends StatelessWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Settings')),
      body: const VoiceSettingsSection(),
    );
  }
}
