import 'package:flutter/material.dart';

/// Page displayed while geolocation is being validated.
class GeoValidationPage extends StatelessWidget {
  /// Creates a [GeoValidationPage].
  const GeoValidationPage({required this.label, super.key});

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
