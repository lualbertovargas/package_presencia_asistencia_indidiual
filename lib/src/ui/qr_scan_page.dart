import 'package:flutter/material.dart';

/// Page displayed while the QR code is being scanned.
class QrScanPage extends StatelessWidget {
  /// Creates a [QrScanPage].
  const QrScanPage({required this.label, super.key});

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
