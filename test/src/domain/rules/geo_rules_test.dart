import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoRules', () {
    const point = AttendancePoint(
      id: 'point-1',
      name: 'Office',
      latitude: 19.4326,
      longitude: -99.1332,
      radiusMeters: 100,
    );

    const config = AttendanceConfig(
      requireQr: true,
      requireGeolocation: true,
      verificationMethod: VerificationMethod.none,
    );

    test('returns empty when position is within radius and not mock', () {
      final position = GeoPosition(
        latitude: 19.4326,
        longitude: -99.1332,
        accuracy: 5,
        timestamp: DateTime(2024),
        isMockLocation: false,
        provider: 'gps',
      );

      final errors = GeoRules.validate(
        position: position,
        point: point,
        config: config,
      );
      expect(errors, isEmpty);
    });

    test('returns OUT_OF_RANGE when position is outside radius', () {
      // ~1km away
      final position = GeoPosition(
        latitude: 19.4426,
        longitude: -99.1332,
        accuracy: 5,
        timestamp: DateTime(2024),
        isMockLocation: false,
        provider: 'gps',
      );

      final errors = GeoRules.validate(
        position: position,
        point: point,
        config: config,
      );
      expect(errors, contains('OUT_OF_RANGE'));
    });

    test('returns MOCK_LOCATION_DETECTED when mock and not allowed', () {
      final position = GeoPosition(
        latitude: 19.4326,
        longitude: -99.1332,
        accuracy: 5,
        timestamp: DateTime(2024),
        isMockLocation: true,
        provider: 'gps',
      );

      final errors = GeoRules.validate(
        position: position,
        point: point,
        config: config,
      );
      expect(errors, contains('MOCK_LOCATION_DETECTED'));
    });

    test('does not flag mock when allowMockLocation is true', () {
      const mockConfig = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.none,
        allowMockLocation: true,
      );

      final position = GeoPosition(
        latitude: 19.4326,
        longitude: -99.1332,
        accuracy: 5,
        timestamp: DateTime(2024),
        isMockLocation: true,
        provider: 'gps',
      );

      final errors = GeoRules.validate(
        position: position,
        point: point,
        config: mockConfig,
      );
      expect(errors, isNot(contains('MOCK_LOCATION_DETECTED')));
    });

    test('uses geoRadiusOverride when provided', () {
      const overrideConfig = AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.none,
        geoRadiusOverride: 2000, // 2km override
      );

      // ~1km away - would fail with 100m radius but pass with 2km
      final position = GeoPosition(
        latitude: 19.4426,
        longitude: -99.1332,
        accuracy: 5,
        timestamp: DateTime(2024),
        isMockLocation: false,
        provider: 'gps',
      );

      final errors = GeoRules.validate(
        position: position,
        point: point,
        config: overrideConfig,
      );
      expect(errors, isNot(contains('OUT_OF_RANGE')));
    });

    test('can return multiple errors at once', () {
      // Far away + mock
      final position = GeoPosition(
        latitude: 20,
        longitude: -100,
        accuracy: 5,
        timestamp: DateTime(2024),
        isMockLocation: true,
        provider: 'mock',
      );

      final errors = GeoRules.validate(
        position: position,
        point: point,
        config: config,
      );
      expect(errors, contains('MOCK_LOCATION_DETECTED'));
      expect(errors, contains('OUT_OF_RANGE'));
    });
  });

  group('GeoRules.haversineDistance', () {
    test('returns 0 for same point', () {
      final distance = GeoRules.haversineDistance(
        lat1: 19.4326,
        lng1: -99.1332,
        lat2: 19.4326,
        lng2: -99.1332,
      );
      expect(distance, closeTo(0, 0.01));
    });

    test('calculates known distance correctly', () {
      // Mexico City to Guadalajara ~460km
      final distance = GeoRules.haversineDistance(
        lat1: 19.4326,
        lng1: -99.1332,
        lat2: 20.6597,
        lng2: -103.3496,
      );
      expect(distance, closeTo(460000, 10000)); // ~460km ± 10km
    });
  });
}
