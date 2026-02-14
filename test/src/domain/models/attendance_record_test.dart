// Test file: non-const constructors used for testing value equality.

import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceRecord', () {
    final timestamp = DateTime(2024);

    test('can be instantiated', () {
      expect(
        AttendanceRecord(
          userId: 'user-1',
          attendancePointId: 'point-1',
          checkType: CheckType.checkIn,
          timestamp: timestamp,
          latitude: 19.4326,
          longitude: -99.1332,
          verificationMethod: VerificationMethod.biometric,
        ),
        isNotNull,
      );
    });

    test('supports value equality', () {
      final a = AttendanceRecord(
        userId: 'user-1',
        attendancePointId: 'point-1',
        checkType: CheckType.checkIn,
        timestamp: timestamp,
        latitude: 19.4326,
        longitude: -99.1332,
        verificationMethod: VerificationMethod.biometric,
      );
      final b = AttendanceRecord(
        userId: 'user-1',
        attendancePointId: 'point-1',
        checkType: CheckType.checkIn,
        timestamp: timestamp,
        latitude: 19.4326,
        longitude: -99.1332,
        verificationMethod: VerificationMethod.biometric,
      );
      expect(a, equals(b));
    });

    test('supports optional fields', () {
      final deviceInfo = DeviceInfo(
        deviceTimestamp: timestamp,
        gpsAccuracy: 5,
        isMockLocation: false,
        locationProvider: 'gps',
      );

      final record = AttendanceRecord(
        userId: 'user-1',
        attendancePointId: 'point-1',
        checkType: CheckType.checkIn,
        timestamp: timestamp,
        latitude: 19.4326,
        longitude: -99.1332,
        verificationMethod: VerificationMethod.biometric,
        verificationData: 'biometric-token',
        deviceInfo: deviceInfo,
      );

      expect(record.verificationData, 'biometric-token');
      expect(record.deviceInfo, deviceInfo);
    });

    test('different checkType means not equal', () {
      final a = AttendanceRecord(
        userId: 'user-1',
        attendancePointId: 'point-1',
        checkType: CheckType.checkIn,
        timestamp: timestamp,
        latitude: 19.4326,
        longitude: -99.1332,
        verificationMethod: VerificationMethod.biometric,
      );
      final b = AttendanceRecord(
        userId: 'user-1',
        attendancePointId: 'point-1',
        checkType: CheckType.checkOut,
        timestamp: timestamp,
        latitude: 19.4326,
        longitude: -99.1332,
        verificationMethod: VerificationMethod.biometric,
      );
      expect(a, isNot(equals(b)));
    });

    group('fromMap', () {
      test('round-trip toMap/fromMap produces equal object', () {
        final original = AttendanceRecord(
          userId: 'user-1',
          attendancePointId: 'point-1',
          checkType: CheckType.checkIn,
          timestamp: timestamp,
          latitude: 19.4326,
          longitude: -99.1332,
          verificationMethod: VerificationMethod.biometric,
          verificationData: 'bio-token',
          deviceInfo: DeviceInfo(
            deviceTimestamp: timestamp,
            gpsAccuracy: 5,
            isMockLocation: false,
            locationProvider: 'gps',
          ),
        );

        final restored = AttendanceRecord.fromMap(original.toMap());
        expect(restored, equals(original));
      });

      test('fromMap with null optional fields', () {
        final map = <String, dynamic>{
          'userId': 'user-1',
          'attendancePointId': 'point-1',
          'checkType': 'checkOut',
          'timestamp': timestamp.toIso8601String(),
          'latitude': 19.4326,
          'longitude': -99.1332,
          'verificationMethod': 'none',
        };

        final record = AttendanceRecord.fromMap(map);
        expect(record.verificationData, isNull);
        expect(record.deviceInfo, isNull);
        expect(record.checkType, CheckType.checkOut);
      });

      test('fromMap with nested deviceInfo', () {
        final map = <String, dynamic>{
          'userId': 'user-1',
          'attendancePointId': 'point-1',
          'checkType': 'checkIn',
          'timestamp': timestamp.toIso8601String(),
          'latitude': 19,
          'longitude': -99,
          'verificationMethod': 'selfie',
          'deviceInfo': <String, dynamic>{
            'deviceTimestamp': timestamp.toIso8601String(),
            'gpsAccuracy': 10,
            'isMockLocation': true,
            'locationProvider': 'network',
          },
        };

        final record = AttendanceRecord.fromMap(map);
        expect(record.deviceInfo, isNotNull);
        expect(record.deviceInfo!.locationProvider, 'network');
        expect(record.latitude, 19.0);
      });
    });

    group('toMap', () {
      test('returns all required fields', () {
        final record = AttendanceRecord(
          userId: 'user-1',
          attendancePointId: 'point-1',
          checkType: CheckType.checkIn,
          timestamp: timestamp,
          latitude: 19.4326,
          longitude: -99.1332,
          verificationMethod: VerificationMethod.biometric,
        );

        final map = record.toMap();

        expect(map, {
          'userId': 'user-1',
          'attendancePointId': 'point-1',
          'checkType': 'checkIn',
          'timestamp': timestamp.toIso8601String(),
          'latitude': 19.4326,
          'longitude': -99.1332,
          'verificationMethod': 'biometric',
        });
      });

      test('excludes null optional fields', () {
        final record = AttendanceRecord(
          userId: 'user-1',
          attendancePointId: 'point-1',
          checkType: CheckType.checkIn,
          timestamp: timestamp,
          latitude: 19.4326,
          longitude: -99.1332,
          verificationMethod: VerificationMethod.none,
        );

        final map = record.toMap();

        expect(map.containsKey('verificationData'), isFalse);
        expect(map.containsKey('deviceInfo'), isFalse);
      });

      test('includes verificationData when present', () {
        final record = AttendanceRecord(
          userId: 'user-1',
          attendancePointId: 'point-1',
          checkType: CheckType.checkIn,
          timestamp: timestamp,
          latitude: 19.4326,
          longitude: -99.1332,
          verificationMethod: VerificationMethod.selfie,
          verificationData: 'base64-photo-data',
        );

        final map = record.toMap();

        expect(map['verificationData'], 'base64-photo-data');
      });

      test('includes deviceInfo as nested map when present', () {
        final deviceInfo = DeviceInfo(
          deviceTimestamp: timestamp,
          gpsAccuracy: 5,
          isMockLocation: false,
          locationProvider: 'gps',
        );

        final record = AttendanceRecord(
          userId: 'user-1',
          attendancePointId: 'point-1',
          checkType: CheckType.checkIn,
          timestamp: timestamp,
          latitude: 19.4326,
          longitude: -99.1332,
          verificationMethod: VerificationMethod.biometric,
          deviceInfo: deviceInfo,
        );

        final map = record.toMap();

        expect(map['deviceInfo'], deviceInfo.toMap());
      });
    });
  });
}
