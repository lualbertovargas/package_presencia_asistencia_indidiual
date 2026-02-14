import 'package:equatable/equatable.dart';

/// A physical location where attendance can be marked.
class AttendancePoint extends Equatable {
  /// Creates an [AttendancePoint].
  const AttendancePoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  /// Unique identifier for this attendance point.
  final String id;

  /// Human-readable name of this point.
  final String name;

  /// Latitude of the point center.
  final double latitude;

  /// Longitude of the point center.
  final double longitude;

  /// Allowed radius in meters from the center.
  final double radiusMeters;

  @override
  List<Object?> get props => [id, name, latitude, longitude, radiusMeters];
}
