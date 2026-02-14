import 'package:attendance_mobile/src/domain/models/verification_method.dart';
import 'package:equatable/equatable.dart';

/// Configuration for an attendance flow.
class AttendanceConfig extends Equatable {
  /// Creates an [AttendanceConfig].
  const AttendanceConfig({
    required this.requireQr,
    required this.requireGeolocation,
    required this.verificationMethod,
    this.geoRadiusOverride,
    this.allowMockLocation = false,
  });

  /// Whether a QR code scan is required.
  final bool requireQr;

  /// Whether geolocation validation is required.
  final bool requireGeolocation;

  /// The verification method to use for identity.
  final VerificationMethod verificationMethod;

  /// Optional override for the geo-fence radius in meters.
  final double? geoRadiusOverride;

  /// Whether to allow mock/fake locations (for testing).
  final bool allowMockLocation;

  @override
  List<Object?> get props => [
    requireQr,
    requireGeolocation,
    verificationMethod,
    geoRadiusOverride,
    allowMockLocation,
  ];
}
