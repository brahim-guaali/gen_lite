import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingWelcomeScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            children: [
              const Spacer(),
              _buildHeader(),
              const SizedBox(height: AppConstants.paddingXLarge),
              _buildWelcomeContent(),
              const SizedBox(height: AppConstants.paddingXLarge),
              _buildWelcomeActions(),
              const Spacer(),
            ],
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
          'Welcome to GenLite!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          'Your AI assistant is ready to help',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWelcomeContent() {
    return AppCard(
      child: Column(
        children: [
          const Text(
            'You\'re all set!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'GenLite is now ready to assist you with:\n\n'
            '• Natural conversations\n'
            '• Document analysis\n'
            '• Image understanding\n'
            '• And much more!\n\n'
            'Everything runs locally on your device for complete privacy.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeActions() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Start Using GenLite',
          icon: Icons.rocket_launch,
          onPressed: onComplete,
          isFullWidth: true,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        SecondaryButton(
          text: 'View Tutorial',
          icon: Icons.help_outline,
          onPressed: () {
            // TODO: Show tutorial
          },
          isFullWidth: true,
        ),
      ],
    );
  }
}
