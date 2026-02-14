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
    this.stepTimeout,
    this.maxPhotoBytes,
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

  /// Optional timeout for each async step.
  ///
  /// When set, each service call will fail with `STEP_TIMEOUT`
  /// if it takes longer than this duration.
  final Duration? stepTimeout;

  /// Optional maximum photo size in bytes.
  ///
  /// When set, a selfie that exceeds this limit will fail with
  /// `PHOTO_TOO_LARGE`.
  final int? maxPhotoBytes;

  @override
  List<Object?> get props => [
    requireQr,
    requireGeolocation,
    verificationMethod,
    geoRadiusOverride,
    allowMockLocation,
    stepTimeout,
    maxPhotoBytes,
  ];
}
