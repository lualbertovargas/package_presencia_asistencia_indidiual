// Test file: non-const constructors used for testing value equality.
// ignore_for_file: prefer_const_constructors

import 'package:attendance_mobile/src/domain/models/attendance_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceResult', () {
    test('success factory creates successful result', () {
      final result = AttendanceResult.success();
      expect(result.success, isTrue);
      expect(result.errorCode, isNull);
      expect(result.errorMessage, isNull);
    });

    test('failure factory creates failed result', () {
      final result = AttendanceResult.failure(
        errorCode: 'OUT_OF_RANGE',
        errorMessage: 'User is outside allowed radius',
      );
      expect(result.success, isFalse);
      expect(result.errorCode, 'OUT_OF_RANGE');
      expect(result.errorMessage, 'User is outside allowed radius');
    });

    test('supports value equality for success', () {
      final a = AttendanceResult.success();
      final b = AttendanceResult.success();
      expect(a, equals(b));
    });

    test('supports value equality for failure', () {
      final a = AttendanceResult.failure(
        errorCode: 'ERR',
        errorMessage: 'msg',
      );
      final b = AttendanceResult.failure(
        errorCode: 'ERR',
        errorMessage: 'msg',
      );
      expect(a, equals(b));
    });

    test('success and failure are not equal', () {
      final success = AttendanceResult.success();
      final failure = AttendanceResult.failure(
        errorCode: 'ERR',
        errorMessage: 'msg',
      );
      expect(success, isNot(equals(failure)));
    });
  });
}
