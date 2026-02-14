import 'package:attendance_mobile/src/domain/models/check_type.dart';
import 'package:attendance_mobile/src/domain/models/device_info.dart';
import 'package:attendance_mobile/src/domain/models/verification_method.dart';
import 'package:equatable/equatable.dart';

/// A complete attendance record ready to be submitted.
class AttendanceRecord extends Equatable {
  /// Creates an [AttendanceRecord].
  const AttendanceRecord({
    required this.userId,
    required this.attendancePointId,
    required this.checkType,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.verificationMethod,
    this.verificationData,
    this.deviceInfo,
  });

  /// ID of the user marking attendance.
  final String userId;

  /// ID of the attendance point.
  final String attendancePointId;

  /// Whether this is a check-in or check-out.
  final CheckType checkType;

  /// Server-side or canonical timestamp for the record.
  final DateTime timestamp;

  /// Latitude where attendance was marked.
  final double latitude;

  /// Longitude where attendance was marked.
  final double longitude;

  /// Method used to verify identity.
  final VerificationMethod verificationMethod;

  /// Optional verification payload (e.g., selfie path).
  final String? verificationData;

  /// Optional device info for anti-fraud purposes.
  final DeviceInfo? deviceInfo;

  @override
  List<Object?> get props => [
    userId,
    attendancePointId,
    checkType,
    timestamp,
    latitude,
    longitude,
    verificationMethod,
    verificationData,
    deviceInfo,
  ];
}
