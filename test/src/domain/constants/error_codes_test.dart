import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorCodes', () {
    test('pointNotFound has expected value', () {
      expect(ErrorCodes.pointNotFound, 'POINT_NOT_FOUND');
    });

    test('biometricFailed has expected value', () {
      expect(ErrorCodes.biometricFailed, 'BIOMETRIC_FAILED');
    });

    test('qrPointMismatch has expected value', () {
      expect(ErrorCodes.qrPointMismatch, 'QR_POINT_MISMATCH');
    });

    test('qrExpired has expected value', () {
      expect(ErrorCodes.qrExpired, 'QR_EXPIRED');
    });

    test('mockLocationDetected has expected value', () {
      expect(ErrorCodes.mockLocationDetected, 'MOCK_LOCATION_DETECTED');
    });

    test('outOfRange has expected value', () {
      expect(ErrorCodes.outOfRange, 'OUT_OF_RANGE');
    });

    test('duplicateCheckIn has expected value', () {
      expect(ErrorCodes.duplicateCheckIn, 'DUPLICATE_CHECK_IN');
    });

    test('checkOutWithoutCheckIn has expected value', () {
      expect(ErrorCodes.checkOutWithoutCheckIn, 'CHECK_OUT_WITHOUT_CHECK_IN');
    });

    test('duplicateCheckOut has expected value', () {
      expect(ErrorCodes.duplicateCheckOut, 'DUPLICATE_CHECK_OUT');
    });

    test('unexpectedErrorPrefix has expected value', () {
      expect(ErrorCodes.unexpectedErrorPrefix, 'UNEXPECTED_ERROR');
    });

    test('stepTimeout has expected value', () {
      expect(ErrorCodes.stepTimeout, 'STEP_TIMEOUT');
    });

    test('photoTooLarge has expected value', () {
      expect(ErrorCodes.photoTooLarge, 'PHOTO_TOO_LARGE');
    });
  });
}
