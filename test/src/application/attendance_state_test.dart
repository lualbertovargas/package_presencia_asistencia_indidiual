// Test file: non-const constructors used for testing value equality.
// ignore_for_file: prefer_const_constructors

import 'package:attendance_mobile/src/application/attendance_state.dart';
import 'package:attendance_mobile/src/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceState', () {
    test('defaults to idle with empty errors', () {
      final state = AttendanceState();
      expect(state.step, AttendanceStep.idle);
      expect(state.errors, isEmpty);
      expect(state.record, isNull);
    });

    test('supports value equality', () {
      final a = AttendanceState();
      final b = AttendanceState();
      expect(a, equals(b));
    });

    test('copyWith replaces step', () {
      final state = AttendanceState();
      final updated = state.copyWith(step: AttendanceStep.scanningQr);
      expect(updated.step, AttendanceStep.scanningQr);
      expect(updated.errors, isEmpty);
    });

    test('copyWith replaces errors', () {
      final state = AttendanceState();
      final updated = state.copyWith(errors: ['ERR']);
      expect(updated.errors, ['ERR']);
    });

    test('copyWith replaces record', () {
      final state = AttendanceState();
      final record = AttendanceRecord(
        userId: 'user-1',
        attendancePointId: 'point-1',
        checkType: CheckType.checkIn,
        timestamp: DateTime(2024),
        latitude: 19.4326,
        longitude: -99.1332,
        verificationMethod: VerificationMethod.none,
      );
      final updated = state.copyWith(record: record);
      expect(updated.record, record);
    });
  });

  group('AttendanceStep', () {
    test('has expected values', () {
      expect(AttendanceStep.values, hasLength(9));
    });
  });
}
