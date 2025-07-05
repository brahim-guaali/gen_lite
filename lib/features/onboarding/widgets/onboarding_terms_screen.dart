import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../../shared/popups/gemma_terms_dialog.dart';

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
            'Welcome to GenLite',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'GenLite is an offline AI assistant that runs entirely on your device. '
            'To get started, you\'ll need to download the AI model (about 2GB).',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          const Text(
            'By continuing, you agree to:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          _buildAgreementItem('Download the Gemma AI model to your device'),
          _buildAgreementItem('Accept the Gemma Terms of Use'),
          _buildAgreementItem('Use the app for lawful purposes only'),
        ],
      ),
    );
  }

  Widget _buildAgreementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
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
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const GemmaTermsDialog(),
            );
          },
          child: const Text(
            'View Terms of Use',
            style: TextStyle(
              color: AppConstants.primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
