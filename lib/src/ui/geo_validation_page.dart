import 'package:flutter/material.dart';

/// Page displayed while geolocation is being validated.
class GeoValidationPage extends StatelessWidget {
  /// Creates a [GeoValidationPage].
  const GeoValidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Validando ubicacion...'),
        ],
      ),
    );
  }
}
