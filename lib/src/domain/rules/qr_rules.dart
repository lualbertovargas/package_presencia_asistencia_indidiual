import 'package:attendance_mobile/src/domain/constants/constants.dart';
import 'package:attendance_mobile/src/domain/models/models.dart';

/// Validation rules for QR code scanning.
class QrRules {
  /// Validates a [QrResult] against an [AttendancePoint].
  ///
  /// Returns a list of error codes. An empty list means valid.
  static List<String> validate({
    required QrResult qrResult,
    required AttendancePoint point,
  }) {
    final errors = <String>[];

    if (qrResult.attendancePointId != point.id) {
      errors.add(ErrorCodes.qrPointMismatch);
    }

    if (qrResult.expiresAt != null &&
        qrResult.scannedAt.isAfter(qrResult.expiresAt!)) {
      errors.add(ErrorCodes.qrExpired);
    }

    return errors;
  }
}
