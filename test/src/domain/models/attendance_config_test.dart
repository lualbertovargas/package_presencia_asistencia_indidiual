// Test file: non-const constructors used for testing value equality.
// ignore_for_file: prefer_const_constructors

import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceConfig', () {
    test('can be instantiated', () {
      expect(
        AttendanceConfig(
          requireQr: true,
          requireGeolocation: true,
          verificationMethod: VerificationMethod.biometric,
        ),
        isNotNull,
      );
    });

    test('supports value equality', () {
      final a = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.biometric,
      );
      final b = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.biometric,
      );
      expect(a, equals(b));
    });

    test('allowMockLocation defaults to false', () {
      final config = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.biometric,
      );
      expect(config.allowMockLocation, isFalse);
    });

    test('geoRadiusOverride is optional', () {
      final config = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.none,
        geoRadiusOverride: 200,
      );
      expect(config.geoRadiusOverride, 200);
    });

    test('stepTimeout is optional and defaults to null', () {
      final config = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.none,
      );
      expect(config.stepTimeout, isNull);
    });

    test('stepTimeout can be set', () {
      final config = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.none,
        stepTimeout: const Duration(seconds: 10),
      );
      expect(config.stepTimeout, const Duration(seconds: 10));
    });

    test('maxPhotoBytes is optional and defaults to null', () {
      final config = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.none,
      );
      expect(config.maxPhotoBytes, isNull);
    });

    test('maxPhotoBytes can be set', () {
      final config = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.selfie,
        maxPhotoBytes: 1024 * 1024,
      );
      expect(config.maxPhotoBytes, 1024 * 1024);
    });

    test('different verificationMethod means not equal', () {
      final a = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.biometric,
      );
      final b = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.none,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
