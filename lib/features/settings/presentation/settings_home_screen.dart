import 'package:flutter/material.dart';
import 'package:genlite/core/constants/app_constants.dart';
import 'package:genlite/shared/widgets/ui_components.dart';
import 'package:genlite/features/settings/presentation/agent_management_screen.dart';
import 'package:genlite/features/settings/presentation/voice_settings_screen.dart';
import 'package:genlite/features/settings/presentation/permissions_screen.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Material 3 style is used if your theme supports it
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          // Section: Agents
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('Agents'),
            subtitle: const Text('Manage AI agents'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AgentManagementScreen(),
                ),
              );
            },
          ),
          const Divider(),
          // Section: Voice
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: const Text('Voice'),
            subtitle: const Text('Configure voice input/output'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          // Section: Permissions
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Permissions'),
            subtitle: const Text('Manage app permissions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PermissionsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          // Section: About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('App info, version, licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          // TODO: Add localization support for all strings
        ],
      ),
    );
  }
}

// Placeholder for AboutScreen
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('GenLite',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Version: 2.0'),
            SizedBox(height: 16),
            Text('A privacy-focused, offline AI assistant.'),
            SizedBox(height: 16),
            Text('License: MIT'),
            SizedBox(height: 16),
            Text('All processing happens locally. No data leaves your device.'),
          ],
        ),
      ),
    );
  }
}
