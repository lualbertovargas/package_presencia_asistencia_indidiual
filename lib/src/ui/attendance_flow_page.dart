import 'dart:async';

import 'package:attendance_mobile/src/application/application.dart';
import 'package:attendance_mobile/src/ui/geo_validation_page.dart';
import 'package:attendance_mobile/src/ui/identity_validation_page.dart';
import 'package:attendance_mobile/src/ui/qr_scan_page.dart';
import 'package:attendance_mobile/src/ui/result_page.dart';
import 'package:flutter/material.dart';

/// Container page that switches between flow steps using
/// [ValueListenableBuilder].
class AttendanceFlowPage extends StatelessWidget {
  /// Creates an [AttendanceFlowPage].
  const AttendanceFlowPage({
    required this.controller,
    super.key,
  });

  /// The attendance controller driving the flow.
  final AttendanceController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AttendanceState>(
      valueListenable: controller,
      builder: (context, state, _) {
        return switch (state.step) {
          AttendanceStep.idle => const Center(
            child: Text('Listo para marcar asistencia'),
          ),
          AttendanceStep.scanningQr ||
          AttendanceStep.validatingQr => const QrScanPage(),
          AttendanceStep.locating ||
          AttendanceStep.validatingLocation => const GeoValidationPage(),
          AttendanceStep.verifyingIdentity => const IdentityValidationPage(),
          AttendanceStep.submitting => const Center(
            child: CircularProgressIndicator(),
          ),
          AttendanceStep.completed || AttendanceStep.error => ResultPage(
            state: state,
            onRetry: () {
              controller.reset();
              unawaited(controller.startFlow());
            },
          ),
        };
      },
    );
  }
}
