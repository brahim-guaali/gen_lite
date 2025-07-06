import 'package:flutter/material.dart';

class AboutInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const AboutInfoSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }
}
