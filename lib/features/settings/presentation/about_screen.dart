import 'package:flutter/material.dart';

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
