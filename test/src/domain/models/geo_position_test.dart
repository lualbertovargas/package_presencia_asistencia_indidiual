// Test file: non-const constructors used for testing value equality.

import 'package:attendance_mobile/src/domain/models/geo_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoPosition', () {
    final timestamp = DateTime(2024);

    test('can be instantiated', () {
      expect(
        GeoPosition(
          latitude: 19.4326,
          longitude: -99.1332,
          accuracy: 10,
          timestamp: timestamp,
          isMockLocation: false,
          provider: 'gps',
        ),
        isNotNull,
      );
    });

    test('supports value equality', () {
      final a = GeoPosition(
        latitude: 19.4326,
        longitude: -99.1332,
        accuracy: 10,
        timestamp: timestamp,
        isMockLocation: false,
        provider: 'gps',
      );
      final b = GeoPosition(
        latitude: 19.4326,
        longitude: -99.1332,
        accuracy: 10,
        timestamp: timestamp,
        isMockLocation: false,
        provider: 'gps',
      );
      expect(a, equals(b));
    });

    test('different values are not equal', () {
      final a = GeoPosition(
        latitude: 19.4326,
        longitude: -99.1332,
        accuracy: 10,
        timestamp: timestamp,
        isMockLocation: false,
        provider: 'gps',
      );
      final b = GeoPosition(
        latitude: 20,
        longitude: -99.1332,
        accuracy: 10,
        timestamp: timestamp,
        isMockLocation: false,
        provider: 'gps',
      );
      expect(a, isNot(equals(b)));
    });
  });
}
