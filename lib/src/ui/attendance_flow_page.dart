import 'dart:async';

import 'package:attendance_mobile/src/application/application.dart';
import 'package:attendance_mobile/src/ui/attendance_strings.dart';
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
    this.strings = const AttendanceStrings(),
    super.key,
  });

  /// The attendance controller driving the flow.
  final AttendanceController controller;

  /// Configurable UI strings.
  final AttendanceStrings strings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AttendanceState>(
      valueListenable: controller,
      builder: (context, state, _) {
        return switch (state.step) {
          AttendanceStep.idle => Center(
            child: Text(strings.readyToMark),
          ),
          AttendanceStep.scanningQr ||
          AttendanceStep.validatingQr => QrScanPage(
            label: strings.scanningQr,
          ),
          AttendanceStep.locating ||
          AttendanceStep.validatingLocation => GeoValidationPage(
            label: strings.validatingLocation,
          ),
          AttendanceStep.verifyingIdentity => IdentityValidationPage(
            label: strings.verifyingIdentity,
          ),
          AttendanceStep.submitting => const Center(
            child: CircularProgressIndicator(),
          ),
          AttendanceStep.completed || AttendanceStep.error => ResultPage(
            state: state,
            onRetry: () {
              controller.reset();
              unawaited(controller.startFlow());
            },
            successText: strings.attendanceRegistered,
            errorText: strings.error,
            retryText: strings.retry,
          ),
          AttendanceStep.cancelled => Center(
            child: Text(strings.cancelled),
          ),
        };
      },
    );
  }
}
