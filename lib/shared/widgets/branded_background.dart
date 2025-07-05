import 'package:flutter/material.dart';

class BrandedBackground extends StatelessWidget {
  final Widget child;
  final bool showAppName;
  final double appNameFontSize;

  const BrandedBackground({
    super.key,
    required this.child,
    this.showAppName = true,
    this.appNameFontSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    print('[BrandedBackground] Building with showAppName=$showAppName');
    return Scaffold(
      backgroundColor: const Color(0xFF6366F1), // Primary color
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showAppName)
              Text(
                'GenLite',
                style: TextStyle(
                  fontSize: appNameFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (showAppName) const SizedBox(height: 24),
            Builder(
              builder: (context) {
                print(
                    '[BrandedBackground] Building child: [36m${child.runtimeType}[0m');
                return child;
              },
            ),
          ],
        ),
      ),
    );
  }
}
