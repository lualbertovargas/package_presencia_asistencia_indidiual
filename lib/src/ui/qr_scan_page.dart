import 'package:flutter/material.dart';

/// Page displayed while the QR code is being scanned.
class QrScanPage extends StatelessWidget {
  /// Creates a [QrScanPage].
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Escaneando codigo QR...'),
        ],
      ),
    );
  }
}
