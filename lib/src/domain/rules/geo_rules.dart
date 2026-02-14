import 'dart:math' as math;

import 'package:attendance_mobile/src/domain/models/models.dart';

/// Validation rules for geolocation.
class GeoRules {
  /// Earth radius in meters.
  static const double earthRadiusMeters = 6371000;

  /// Validates a [GeoPosition] against an [AttendancePoint] and config.
  ///
  /// Returns a list of error codes. An empty list means valid.
  static List<String> validate({
    required GeoPosition position,
    required AttendancePoint point,
    required AttendanceConfig config,
  }) {
    final errors = <String>[];

    if (!config.allowMockLocation && position.isMockLocation) {
      errors.add('MOCK_LOCATION_DETECTED');
    }

    final radius = config.geoRadiusOverride ?? point.radiusMeters;
    final distance = haversineDistance(
      lat1: position.latitude,
      lng1: position.longitude,
      lat2: point.latitude,
      lng2: point.longitude,
    );

    if (distance > radius) {
      errors.add('OUT_OF_RANGE');
    }

    return errors;
  }

  /// Calculates the distance in meters between two coordinates using
  /// the Haversine formula.
  static double haversineDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
