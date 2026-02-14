/// Method used to verify the identity of the person marking attendance.
enum VerificationMethod {
  /// Biometric verification (fingerprint, face ID, etc.).
  biometric,

  /// Selfie-based verification.
  selfie,

  /// No verification required.
  none,
}
