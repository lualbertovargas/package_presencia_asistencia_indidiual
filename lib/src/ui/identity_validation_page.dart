import 'package:flutter/material.dart';

/// Page displayed while biometric identity is being verified.
class IdentityValidationPage extends StatelessWidget {
  /// Creates an [IdentityValidationPage].
  const IdentityValidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Verificando identidad...'),
        ],
      ),
    );
  }
}
