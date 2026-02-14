/// Configurable UI strings for the attendance flow.
///
/// Defaults are in Spanish. The consuming app can provide custom values
/// to override any label.
class AttendanceStrings {
  /// Creates [AttendanceStrings] with optional overrides.
  const AttendanceStrings({
    this.readyToMark = 'Listo para marcar asistencia',
    this.scanningQr = 'Escaneando codigo QR...',
    this.validatingLocation = 'Validando ubicacion...',
    this.verifyingIdentity = 'Verificando identidad...',
    this.attendanceRegistered = 'Asistencia registrada',
    this.error = 'Error',
    this.retry = 'Reintentar',
    this.cancelled = 'Operacion cancelada',
  });

  /// Text shown when idle.
  final String readyToMark;

  /// Text shown during QR scanning.
  final String scanningQr;

  /// Text shown during location validation.
  final String validatingLocation;

  /// Text shown during identity verification.
  final String verifyingIdentity;

  /// Text shown on successful attendance.
  final String attendanceRegistered;

  /// Text shown on error.
  final String error;

  /// Text on the retry button.
  final String retry;

  /// Text shown when the flow is cancelled.
  final String cancelled;
}
