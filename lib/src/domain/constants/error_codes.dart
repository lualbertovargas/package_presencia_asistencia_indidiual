/// Centralized error code constants used throughout the attendance flow.
class ErrorCodes {
  const ErrorCodes._();

  /// The attendance point could not be resolved from the QR code.
  static const String pointNotFound = 'POINT_NOT_FOUND';

  /// Biometric authentication failed.
  static const String biometricFailed = 'BIOMETRIC_FAILED';

  /// The scanned QR code does not match the expected attendance point.
  static const String qrPointMismatch = 'QR_POINT_MISMATCH';

  /// The scanned QR code has expired.
  static const String qrExpired = 'QR_EXPIRED';

  /// A mock/fake location provider was detected.
  static const String mockLocationDetected = 'MOCK_LOCATION_DETECTED';

  /// The device is outside the allowed geo-fence radius.
  static const String outOfRange = 'OUT_OF_RANGE';

  /// A check-in was attempted when the user is already checked in.
  static const String duplicateCheckIn = 'DUPLICATE_CHECK_IN';

  /// A check-out was attempted without a prior check-in.
  static const String checkOutWithoutCheckIn = 'CHECK_OUT_WITHOUT_CHECK_IN';

  /// A check-out was attempted when the user is already checked out.
  static const String duplicateCheckOut = 'DUPLICATE_CHECK_OUT';

  /// Prefix for unexpected errors caught during the flow.
  static const String unexpectedErrorPrefix = 'UNEXPECTED_ERROR';

  /// A step in the attendance flow exceeded the configured timeout.
  static const String stepTimeout = 'STEP_TIMEOUT';

  /// The captured photo exceeds the configured maximum size.
  static const String photoTooLarge = 'PHOTO_TOO_LARGE';
}
