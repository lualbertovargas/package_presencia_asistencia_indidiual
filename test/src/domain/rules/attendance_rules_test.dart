import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceRules', () {
    final timestamp = DateTime(2024);

    AttendanceRecord makeRecord(CheckType type) => AttendanceRecord(
      userId: 'user-1',
      attendancePointId: 'point-1',
      checkType: type,
      timestamp: timestamp,
      latitude: 19.4326,
      longitude: -99.1332,
      verificationMethod: VerificationMethod.none,
    );

    test('allows check-in when no previous record', () {
      final errors = AttendanceRules.validate(
        checkType: CheckType.checkIn,
        lastRecord: null,
      );
      expect(errors, isEmpty);
    });

    test('allows check-in after check-out', () {
      final errors = AttendanceRules.validate(
        checkType: CheckType.checkIn,
        lastRecord: makeRecord(CheckType.checkOut),
      );
      expect(errors, isEmpty);
    });

    test('returns DUPLICATE_CHECK_IN when already checked in', () {
      final errors = AttendanceRules.validate(
        checkType: CheckType.checkIn,
        lastRecord: makeRecord(CheckType.checkIn),
      );
      expect(errors, contains('DUPLICATE_CHECK_IN'));
    });

    test('allows check-out after check-in', () {
      final errors = AttendanceRules.validate(
        checkType: CheckType.checkOut,
        lastRecord: makeRecord(CheckType.checkIn),
      );
      expect(errors, isEmpty);
    });

    test('returns CHECK_OUT_WITHOUT_CHECK_IN when no previous record', () {
      final errors = AttendanceRules.validate(
        checkType: CheckType.checkOut,
        lastRecord: null,
      );
      expect(errors, contains('CHECK_OUT_WITHOUT_CHECK_IN'));
    });

    test('returns DUPLICATE_CHECK_OUT when already checked out', () {
      final errors = AttendanceRules.validate(
        checkType: CheckType.checkOut,
        lastRecord: makeRecord(CheckType.checkOut),
      );
      expect(errors, contains('DUPLICATE_CHECK_OUT'));
    });
  });
}
