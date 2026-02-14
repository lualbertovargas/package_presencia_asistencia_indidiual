// Test file: non-const constructors used for testing value equality.
// ignore_for_file: prefer_const_constructors

import 'package:attendance_mobile/src/domain/models/models.dart';
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
