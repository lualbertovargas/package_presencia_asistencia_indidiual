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

  /// Creates a [DeviceInfo] from a map (e.g., from JSON decoding).
  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceTimestamp: DateTime.parse(map['deviceTimestamp'] as String),
      gpsAccuracy: (map['gpsAccuracy'] as num).toDouble(),
      isMockLocation: map['isMockLocation'] as bool,
      locationProvider: map['locationProvider'] as String,
    );
  }

  /// Device-local timestamp at the moment of attendance.
  final DateTime deviceTimestamp;

  /// GPS accuracy in meters.
  final double gpsAccuracy;

  /// Whether a mock location provider was detected.
  final bool isMockLocation;

  /// The location provider used (e.g., 'gps', 'network').
  final String locationProvider;

  /// Converts this [DeviceInfo] to a map ready for serialization.
  Map<String, dynamic> toMap() => {
    'deviceTimestamp': deviceTimestamp.toIso8601String(),
    'gpsAccuracy': gpsAccuracy,
    'isMockLocation': isMockLocation,
    'locationProvider': locationProvider,
  };

  @override
  List<Object?> get props => [
    deviceTimestamp,
    gpsAccuracy,
    isMockLocation,
    locationProvider,
  ];
}
