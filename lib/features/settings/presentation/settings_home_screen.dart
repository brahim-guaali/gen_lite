import 'package:flutter/material.dart';
import 'package:genlite/core/constants/app_constants.dart';
import 'package:genlite/shared/widgets/ui_components.dart';
import 'package:genlite/features/settings/presentation/agent_management_screen.dart';
import 'package:genlite/features/settings/presentation/voice_settings_screen.dart';
import 'package:genlite/features/settings/presentation/permissions_screen.dart';
import 'package:genlite/features/settings/widgets/settings_header_section.dart';
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

            // Main Settings List
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    context,
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
                  _buildDivider(context),
                  _buildSettingsItem(
                    context,
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
                  _buildDivider(context),
                  _buildSettingsItem(
                    context,
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
                  _buildDivider(context),
                  _buildSettingsItem(
                    context,
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
            ),
            const SizedBox(height: 24),

            const PrivacyNoticeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppConstants.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
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
                const SizedBox(height: 12),
                AboutInfoCard(
                  icon: Icons.voice_chat,
                  title: 'Voice Interaction',
                  subtitle: 'Speak naturally with your AI assistant',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                AboutInfoCard(
                  icon: Icons.file_upload,
                  title: 'File Processing',
                  subtitle: 'Upload and analyze documents easily',
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // App Information
            AboutInfoSection(
              title: 'App Information',
              items: [
                AboutInfoCard(
                  icon: Icons.code,
                  title: 'License',
                  subtitle: 'MIT License - Open Source',
                  color: Colors.indigo,
                ),
                const SizedBox(height: 12),
                AboutInfoCard(
                  icon: Icons.update,
                  title: 'Version',
                  subtitle: '2.0.0',
                  color: Colors.cyan,
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
