import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/ui_components.dart';

class GemmaTermsDialog extends StatelessWidget {
  const GemmaTermsDialog({super.key});

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
                  const Text(
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
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: GemmaTermsContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GemmaTermsContent extends StatelessWidget {
  const GemmaTermsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'License Agreement',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        const Text(
          'This software is licensed under the Gemma License Agreement. By using this software, you agree to be bound by the terms of this license.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        const Text(
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
        const Text(
          'Full License',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        const Text(
          'For the complete Gemma License Agreement, please visit: https://ai.google.dev/gemma/terms',
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        const Text(
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
