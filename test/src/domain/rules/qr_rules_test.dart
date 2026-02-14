import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrRules', () {
    const point = AttendancePoint(
      id: 'point-1',
      name: 'Office',
      latitude: 19.4326,
      longitude: -99.1332,
      radiusMeters: 100,
    );

    test('returns empty list when QR matches point and is not expired', () {
      final qr = QrResult(
        attendancePointId: 'point-1',
        scannedAt: DateTime(2024),
      );

      final errors = QrRules.validate(qrResult: qr, point: point);
      expect(errors, isEmpty);
    });

    test('returns QR_POINT_MISMATCH when point ids differ', () {
      final qr = QrResult(
        attendancePointId: 'point-99',
        scannedAt: DateTime(2024),
      );

      final errors = QrRules.validate(qrResult: qr, point: point);
      expect(errors, contains(ErrorCodes.qrPointMismatch));
    });

    test('returns QR_EXPIRED when scannedAt is after expiresAt', () {
      final qr = QrResult(
        attendancePointId: 'point-1',
        scannedAt: DateTime(2024, 1, 2),
        expiresAt: DateTime(2024),
      );

      final errors = QrRules.validate(qrResult: qr, point: point);
      expect(errors, contains(ErrorCodes.qrExpired));
    });

    test('does not return QR_EXPIRED when expiresAt is null', () {
      final qr = QrResult(
        attendancePointId: 'point-1',
        scannedAt: DateTime(2024, 1, 2),
      );

      final errors = QrRules.validate(qrResult: qr, point: point);
      expect(errors, isNot(contains(ErrorCodes.qrExpired)));
    });

    test('does not return QR_EXPIRED when scannedAt is before expiresAt', () {
      final qr = QrResult(
        attendancePointId: 'point-1',
        scannedAt: DateTime(2024),
        expiresAt: DateTime(2024, 1, 2),
      );

      final errors = QrRules.validate(qrResult: qr, point: point);
      expect(errors, isNot(contains(ErrorCodes.qrExpired)));
    });

    test('can return multiple errors at once', () {
      final qr = QrResult(
        attendancePointId: 'point-99',
        scannedAt: DateTime(2024, 1, 2),
        expiresAt: DateTime(2024),
      );

      final errors = QrRules.validate(qrResult: qr, point: point);
      expect(errors, hasLength(2));
      expect(errors, contains(ErrorCodes.qrPointMismatch));
      expect(errors, contains(ErrorCodes.qrExpired));
    });
  });
}
