import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/ui_components.dart';

class OnboardingErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const OnboardingErrorScreen({
    super.key,
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
            children: [
              const Spacer(),
              _buildErrorIcon(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildErrorContent(),
              const SizedBox(height: AppConstants.paddingXLarge),
              _buildErrorActions(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.error_outline,
        size: 60,
        color: Colors.red,
      ),
    );
  }

  Widget _buildErrorContent() {
    return AppCard(
      child: Column(
        children: [
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
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
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Please check your internet connection and try again.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorActions() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Try Again',
          icon: Icons.refresh,
          onPressed: onRetry,
          isFullWidth: true,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        SecondaryButton(
          text: 'Contact Support',
          icon: Icons.support_agent,
          onPressed: () {
            // TODO: Open support contact
          },
          isFullWidth: true,
        ),
      ],
    );
  }
}
