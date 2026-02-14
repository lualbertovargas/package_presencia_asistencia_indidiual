import 'package:attendance_mobile/src/domain/constants/constants.dart';
import 'package:attendance_mobile/src/domain/models/models.dart';

/// Validation rules for attendance flow logic.
class AttendanceRules {
  /// Validates whether a check-in/check-out is allowed based on the
  /// last record for this user at this point.
  ///
  /// Returns a list of error codes. An empty list means valid.
  static List<String> validate({
    required CheckType checkType,
    required AttendanceRecord? lastRecord,
  }) {
    final errors = <String>[];

    if (checkType == CheckType.checkIn &&
        lastRecord != null &&
        lastRecord.checkType == CheckType.checkIn) {
      errors.add(ErrorCodes.duplicateCheckIn);
    }

    if (checkType == CheckType.checkOut && lastRecord == null) {
      errors.add(ErrorCodes.checkOutWithoutCheckIn);
    }

    if (checkType == CheckType.checkOut &&
        lastRecord != null &&
        lastRecord.checkType == CheckType.checkOut) {
      errors.add(ErrorCodes.duplicateCheckOut);
    }

    return errors;
  }
}
