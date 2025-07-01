import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../../shared/widgets/download_screen.dart';
import '../bloc/onboarding_bloc.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc()..add(CheckOnboardingStatus()),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingComplete) {
            onComplete();
          }
        },
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            if (state is OnboardingLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is OnboardingTermsScreen) {
              return _TermsScreen(onComplete: onComplete);
            }

            if (state is OnboardingDownloadScreen) {
              return _DownloadScreen(onComplete: onComplete);
            }

            if (state is OnboardingWelcomeScreen) {
              return _WelcomeScreen(onComplete: onComplete);
            }

            if (state is OnboardingError) {
              return _ErrorScreen(
                message: state.message,
                onRetry: () =>
                    context.read<OnboardingBloc>().add(CheckOnboardingStatus()),
              );
            }

            return const Scaffold(
              body: Center(
                child: Text('Unknown state'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TermsScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const _TermsScreen({required this.onComplete});

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
          child: Icon(
            Icons.psychology,
            size: 60,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        Text(
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
          Text(
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
                Text(
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
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppConstants.accentColor,
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        'Terms of Use',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'By using GenLite, you agree to the Gemma Terms of Use. This includes using the AI model responsibly and in compliance with applicable laws.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const GemmaTermsDialog(),
                    );
                  },
                  icon: const Icon(Icons.description),
                  label: const Text('Read Full Terms'),
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
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
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
          icon: Icons.check,
          onPressed: () => context.read<OnboardingBloc>().add(AcceptTerms()),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          'By accepting, you agree to the Gemma Terms of Use',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DownloadScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const _DownloadScreen({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return DownloadScreen(
      onDownloadComplete: () =>
          context.read<OnboardingBloc>().add(CompleteDownload()),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const _WelcomeScreen({required this.onComplete});

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
                _buildWelcomeHeader(),
                const SizedBox(height: AppConstants.paddingXLarge),
                _buildWelcomeContent(),
                const SizedBox(height: AppConstants.paddingXLarge),
                _buildWelcomeActions(),
                const SizedBox(height: AppConstants.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 60,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        Text(
          'Setup Complete!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          'GenLite is ready to use',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Next?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Your AI assistant is now ready to help you with various tasks. Here\'s what you can do:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Getting started guide
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Getting Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildGuideRow('1', 'Start a conversation in the Chat tab'),
                _buildGuideRow('2', 'Upload documents in the Files tab'),
                _buildGuideRow('3', 'Configure AI agents in Settings'),
                _buildGuideRow('4', 'Ask questions about your documents'),
                _buildGuideRow('5', 'Get help with various tasks'),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Tips
          AppCard(
            backgroundColor: AppConstants.accentColor.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppConstants.accentColor,
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        'Pro Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  '• Be specific in your questions for better responses\n'
                  '• Upload documents to get context-aware answers\n'
                  '• Use the agent settings to customize AI behavior\n'
                  '• All processing happens on your device for privacy',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeActions() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Get Started',
          icon: Icons.arrow_forward,
          onPressed: onComplete,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          'You can always access settings and help from the app menu',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppConstants.errorColor,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(
                'Setup Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingXLarge),
              PrimaryButton(
                text: 'Retry',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GemmaTermsDialog extends StatelessWidget {
  const GemmaTermsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gemma Terms of Use',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const AppDivider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: const GemmaTermsContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GemmaTermsContent extends StatelessWidget {
  const GemmaTermsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License Agreement',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          'This software is licensed under the Gemma License Agreement. By using this software, you agree to be bound by the terms of this license.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        Text(
          'Key Terms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        _buildTermItem('1. Permitted Uses',
            'You may use, reproduce, distribute, and create derivative works of the Software for any lawful purpose, subject to the restrictions below.'),
        _buildTermItem('2. Restrictions',
            'You may not use the Software for any illegal or harmful purpose, attempt to reverse engineer or decompile the Software, or remove or alter any proprietary notices.'),
        _buildTermItem('3. Attribution',
            'When distributing the Software, you must include a copy of this license.'),
        _buildTermItem('4. No Warranty',
            'The Software is provided "as is" without warranty of any kind.'),
        _buildTermItem('5. Limitation of Liability',
            'In no event shall the authors be liable for any damages arising from the use of the Software.'),
        const SizedBox(height: AppConstants.paddingLarge),
        Text(
          'Full License',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          'For the complete Gemma License Agreement, please visit: https://ai.google.dev/gemma/terms',
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          'By accepting these terms, you acknowledge that you have read, understood, and agree to be bound by the Gemma License Agreement.',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTermItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
