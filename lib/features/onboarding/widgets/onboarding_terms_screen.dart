import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';

class OnboardingTermsScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingTermsScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                const SizedBox(height: AppConstants.paddingXLarge),
                _buildHeader(),
                const SizedBox(height: AppConstants.paddingXLarge),
                _buildTermsContent(context),
                const SizedBox(height: AppConstants.paddingXLarge),
                _buildTermsActions(context),
                const SizedBox(height: AppConstants.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.psychology,
            size: 60,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        const Text(
          'Welcome to GenLite',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          'Your Personal Offline AI Assistant',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTermsContent(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About GenLite',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'GenLite is a lightweight, offline AI assistant that runs entirely on your device.\n\n'
            'To enable AI features, the app will download a large language model (Gemma 3N) from Hugging Face.\n\n'
            'This download may take several minutes and require several GB of storage. All processing stays on your device.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Features
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Key Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildFeatureRow(
                    Icons.security, '100% Offline - No data sent to servers'),
                _buildFeatureRow(Icons.speed, 'Fast local processing'),
                _buildFeatureRow(
                    Icons.privacy_tip, 'Complete privacy protection'),
                _buildFeatureRow(Icons.file_copy, 'Document analysis support'),
                _buildFeatureRow(Icons.chat, 'Natural conversation interface'),
                _buildFeatureRow(
                    Icons.image, 'Image understanding capabilities'),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Terms acceptance
          AppCard(
            backgroundColor: AppConstants.accentColor.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppConstants.accentColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Important Notice',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'By continuing, you agree to download the AI model and accept our privacy policy. '
                  'The model will be stored locally on your device.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsActions(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          text: 'Accept & Continue',
          icon: Icons.arrow_forward,
          onPressed: onComplete,
          isFullWidth: true,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        SecondaryButton(
          text: 'Learn More',
          icon: Icons.info,
          onPressed: () {
            // TODO: Show more detailed information
          },
          isFullWidth: true,
        ),
      ],
    );
  }
}
