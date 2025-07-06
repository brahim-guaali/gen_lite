import 'package:flutter/material.dart';
import 'package:genlite/core/constants/app_constants.dart';
import 'package:genlite/shared/widgets/ui_components.dart';
import 'package:genlite/features/settings/presentation/agent_management_screen.dart';
import 'package:genlite/features/settings/presentation/voice_settings_screen.dart';
import 'package:genlite/features/settings/presentation/permissions_screen.dart';
import 'package:genlite/features/settings/widgets/settings_header_section.dart';
import 'package:genlite/features/settings/widgets/settings_section.dart';
import 'package:genlite/features/settings/widgets/settings_card.dart';
import 'package:genlite/features/settings/widgets/privacy_notice_card.dart';
import 'package:genlite/features/settings/widgets/about_app_header.dart';
import 'package:genlite/features/settings/widgets/about_info_section.dart';
import 'package:genlite/features/settings/widgets/about_info_card.dart';
import 'package:genlite/features/settings/widgets/about_privacy_commitment.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsHeaderSection(),
            const SizedBox(height: 24),

            // Settings Categories
            SettingsSection(
              title: 'AI & Voice',
              items: [
                SettingsCard(
                  icon: Icons.smart_toy,
                  title: 'AI Agents',
                  subtitle: 'Manage and customize AI personalities',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgentManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SettingsCard(
                  icon: Icons.record_voice_over,
                  title: 'Voice Settings',
                  subtitle: 'Configure speech recognition and TTS',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VoiceSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            SettingsSection(
              title: 'Privacy & Security',
              items: [
                SettingsCard(
                  icon: Icons.security,
                  title: 'Permissions',
                  subtitle: 'Manage app permissions and access',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PermissionsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            SettingsSection(
              title: 'Information',
              items: [
                SettingsCard(
                  icon: Icons.info_outline,
                  title: 'About GenLite',
                  subtitle: 'Version, license, and app information',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            const PrivacyNoticeCard(),
          ],
        ),
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
      appBar: AppBar(
        title: const Text(
          'About GenLite',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AboutAppHeader(),
            const SizedBox(height: 24),

            // Features Section
            AboutInfoSection(
              title: 'Key Features',
              items: [
                AboutInfoCard(
                  icon: Icons.security,
                  title: 'Privacy First',
                  subtitle: 'All processing happens locally on your device',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                AboutInfoCard(
                  icon: Icons.offline_bolt,
                  title: 'Offline Capable',
                  subtitle: 'Works without internet connection',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                AboutInfoCard(
                  icon: Icons.psychology,
                  title: 'AI Powered',
                  subtitle: 'Powered by Google\'s Gemma language model',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Technical Info
            AboutInfoSection(
              title: 'Technical Information',
              items: [
                AboutInfoCard(
                  icon: Icons.code,
                  title: 'License',
                  subtitle: 'MIT License - Open Source',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                AboutInfoCard(
                  icon: Icons.architecture,
                  title: 'Architecture',
                  subtitle: 'Clean Architecture with BLoC pattern',
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 24),

            const AboutPrivacyCommitment(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
