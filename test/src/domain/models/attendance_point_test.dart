// Test file: non-const constructors used for testing value equality.
// ignore_for_file: prefer_const_constructors

import 'package:attendance_mobile/src/domain/models/attendance_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendancePoint', () {
    test('can be instantiated', () {
      expect(
        AttendancePoint(
          id: 'point-1',
          name: 'Office',
          latitude: 19.4326,
          longitude: -99.1332,
          radiusMeters: 100,
        ),
        isNotNull,
      );
    });

    test('supports value equality', () {
      final a = AttendancePoint(
        id: 'point-1',
        name: 'Office',
        latitude: 19.4326,
        longitude: -99.1332,
        radiusMeters: 100,
      );
      final b = AttendancePoint(
        id: 'point-1',
        name: 'Office',
        latitude: 19.4326,
        longitude: -99.1332,
        radiusMeters: 100,
      );
      expect(a, equals(b));
    });

    test('different id means not equal', () {
      final a = AttendancePoint(
        id: 'point-1',
        name: 'Office',
        latitude: 19.4326,
        longitude: -99.1332,
        radiusMeters: 100,
      );
      final b = AttendancePoint(
        id: 'point-2',
        name: 'Office',
        latitude: 19.4326,
        longitude: -99.1332,
        radiusMeters: 100,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
