// Test file: non-const constructors used for testing value equality.

import 'package:attendance_mobile/src/domain/models/qr_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrResult', () {
    final scannedAt = DateTime(2024);

    test('can be instantiated', () {
      expect(
        QrResult(
          attendancePointId: 'point-1',
          scannedAt: scannedAt,
        ),
        isNotNull,
      );
    });

    test('supports value equality', () {
      final a = QrResult(
        attendancePointId: 'point-1',
        scannedAt: scannedAt,
      );
      final b = QrResult(
        attendancePointId: 'point-1',
        scannedAt: scannedAt,
      );
      expect(a, equals(b));
    });

    test('supports optional fields', () {
      final expiresAt = DateTime(2024, 1, 2);
      final result = QrResult(
        attendancePointId: 'point-1',
        scannedAt: scannedAt,
        expiresAt: expiresAt,
        rawData: '{"id":"point-1"}',
      );
      expect(result.expiresAt, expiresAt);
      expect(result.rawData, '{"id":"point-1"}');
    });

    test('different attendancePointId means not equal', () {
      final a = QrResult(
        attendancePointId: 'point-1',
        scannedAt: scannedAt,
      );
      final b = QrResult(
        attendancePointId: 'point-2',
        scannedAt: scannedAt,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
