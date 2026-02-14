import 'package:equatable/equatable.dart';

/// Result of an attendance submission attempt.
class AttendanceResult extends Equatable {
  /// Creates an [AttendanceResult].
  const AttendanceResult._({
    required this.success,
    this.errorCode,
    this.errorMessage,
  });

  /// Creates a successful result.
  const factory AttendanceResult.success() = _SuccessResult;

  /// Creates a failure result with an error code and message.
  factory AttendanceResult.failure({
    required String errorCode,
    required String errorMessage,
  }) =>
      AttendanceResult._(
        success: false,
        errorCode: errorCode,
        errorMessage: errorMessage,
      );

  /// Whether the attendance was successfully submitted.
  final bool success;

  /// Error code if the submission failed.
  final String? errorCode;

  /// Human-readable error message if the submission failed.
  final String? errorMessage;

  @override
  List<Object?> get props => [success, errorCode, errorMessage];
}

class _SuccessResult extends AttendanceResult {
  const _SuccessResult() : super._(success: true);
}
