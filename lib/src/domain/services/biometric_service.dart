/// Abstract interface for biometric authentication.
///
/// The consuming app must provide an implementation.
abstract class BiometricService {
  /// Attempts biometric authentication. Returns `true` if successful.
  Future<bool> authenticate();

  /// Whether biometric authentication is available on this device.
  Future<bool> isAvailable();
}
