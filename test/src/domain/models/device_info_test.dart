// Test file: non-const constructors used for testing value equality.

import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceInfo', () {
    final timestamp = DateTime(2024);

    test('can be instantiated', () {
      expect(
        DeviceInfo(
          deviceTimestamp: timestamp,
          gpsAccuracy: 5,
          isMockLocation: false,
          locationProvider: 'gps',
        ),
        isNotNull,
      );
    });

    test('supports value equality', () {
      final a = DeviceInfo(
        deviceTimestamp: timestamp,
        gpsAccuracy: 5,
        isMockLocation: false,
        locationProvider: 'gps',
      );
      final b = DeviceInfo(
        deviceTimestamp: timestamp,
        gpsAccuracy: 5,
        isMockLocation: false,
        locationProvider: 'gps',
      );
      expect(a, equals(b));
    });

    test('different mock location means not equal', () {
      final a = DeviceInfo(
        deviceTimestamp: timestamp,
        gpsAccuracy: 5,
        isMockLocation: false,
        locationProvider: 'gps',
      );
      final b = DeviceInfo(
        deviceTimestamp: timestamp,
        gpsAccuracy: 5,
        isMockLocation: true,
        locationProvider: 'gps',
      );
      expect(a, isNot(equals(b)));
    });

    group('fromMap', () {
      test('round-trip toMap/fromMap produces equal object', () {
        final original = DeviceInfo(
          deviceTimestamp: timestamp,
          gpsAccuracy: 5,
          isMockLocation: false,
          locationProvider: 'gps',
        );

        final restored = DeviceInfo.fromMap(original.toMap());
        expect(restored, equals(original));
      });

      test('handles int gpsAccuracy from JSON decoder', () {
        final map = <String, dynamic>{
          'deviceTimestamp': timestamp.toIso8601String(),
          'gpsAccuracy': 5,
          'isMockLocation': false,
          'locationProvider': 'gps',
        };

        final info = DeviceInfo.fromMap(map);
        expect(info.gpsAccuracy, 5.0);
      });
    });

    test('toMap returns correct map', () {
      final info = DeviceInfo(
        deviceTimestamp: timestamp,
        gpsAccuracy: 5,
        isMockLocation: false,
        locationProvider: 'gps',
      );

      final map = info.toMap();

      expect(map, {
        'deviceTimestamp': timestamp.toIso8601String(),
        'gpsAccuracy': 5.0,
        'isMockLocation': false,
        'locationProvider': 'gps',
      });
    });
  });
}
