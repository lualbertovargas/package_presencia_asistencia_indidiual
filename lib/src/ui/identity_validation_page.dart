import 'package:flutter/material.dart';

/// Page displayed while biometric identity is being verified.
class IdentityValidationPage extends StatelessWidget {
  /// Creates an [IdentityValidationPage].
  const IdentityValidationPage({required this.label, super.key});

  /// The text label to display.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    );
  }
}
