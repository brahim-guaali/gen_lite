import 'package:flutter/material.dart';

class AboutPrivacyCommitment extends StatelessWidget {
  const AboutPrivacyCommitment({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Privacy Commitment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your privacy is our priority. All data is processed locally on your device. No information is sent to external servers or stored in the cloud.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
