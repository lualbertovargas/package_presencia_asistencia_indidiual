import 'package:attendance_mobile/src/domain/models/models.dart';
import 'package:equatable/equatable.dart';

/// Steps in the attendance flow.
enum AttendanceStep {
  /// No action in progress.
  idle,

  /// Scanning the QR code.
  scanningQr,

  /// Validating the scanned QR.
  validatingQr,

  /// Obtaining device location.
  locating,

  /// Validating the obtained location.
  validatingLocation,

  /// Verifying identity (biometric / selfie).
  verifyingIdentity,

  /// Submitting the attendance record.
  submitting,

  /// Flow completed successfully.
  completed,

  /// An error occurred during the flow.
  error,
}

/// State of the attendance flow.
class AttendanceState extends Equatable {
  /// Creates an [AttendanceState].
  const AttendanceState({
    this.step = AttendanceStep.idle,
    this.errors = const [],
    this.record,
  });

  /// The current step of the flow.
  final AttendanceStep step;

  /// Error codes from validation or submission failures.
  final List<String> errors;

  /// The resulting attendance record on success.
  final AttendanceRecord? record;

  /// Returns a copy of this state with the given fields replaced.
  AttendanceState copyWith({
    AttendanceStep? step,
    List<String>? errors,
    AttendanceRecord? record,
  }) {
    return AttendanceState(
      step: step ?? this.step,
      errors: errors ?? this.errors,
      record: record ?? this.record,
    );
  }

  @override
  List<Object?> get props => [step, errors, record];
}
