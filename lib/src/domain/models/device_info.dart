import 'package:equatable/equatable.dart';

/// Anti-fraud device information captured at attendance time.
class DeviceInfo extends Equatable {
  /// Creates a [DeviceInfo].
  const DeviceInfo({
    required this.deviceTimestamp,
    required this.gpsAccuracy,
    required this.isMockLocation,
    required this.locationProvider,
  });

  /// Device-local timestamp at the moment of attendance.
  final DateTime deviceTimestamp;

  /// GPS accuracy in meters.
  final double gpsAccuracy;

  /// Whether a mock location provider was detected.
  final bool isMockLocation;

  /// The location provider used (e.g., 'gps', 'network').
  final String locationProvider;

  @override
  List<Object?> get props => [
        deviceTimestamp,
        gpsAccuracy,
        isMockLocation,
        locationProvider,
      ];
}
