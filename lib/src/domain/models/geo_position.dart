import 'package:equatable/equatable.dart';

/// Represents a geographic position with metadata for anti-fraud detection.
class GeoPosition extends Equatable {
  /// Creates a [GeoPosition].
  const GeoPosition({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    required this.isMockLocation,
    required this.provider,
  });

  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;

  /// Accuracy in meters.
  final double accuracy;

  /// Timestamp when the position was captured.
  final DateTime timestamp;

  /// Whether the location is a mock/fake location.
  final bool isMockLocation;

  /// Location provider (e.g., 'gps', 'network', 'fused').
  final String provider;

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracy,
        timestamp,
        isMockLocation,
        provider,
      ];
}
