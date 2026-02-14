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

  /// Creates an [AttendanceRecord] from a map (e.g., from JSON decoding).
  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      userId: map['userId'] as String,
      attendancePointId: map['attendancePointId'] as String,
      checkType: CheckType.values.byName(map['checkType'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      verificationMethod: VerificationMethod.values.byName(
        map['verificationMethod'] as String,
      ),
      verificationData: map['verificationData'] as String?,
      deviceInfo: map['deviceInfo'] != null
          ? DeviceInfo.fromMap(map['deviceInfo'] as Map<String, dynamic>)
          : null,
    );
  }

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

  /// Converts this [AttendanceRecord] to a map ready for serialization.
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'attendancePointId': attendancePointId,
    'checkType': checkType.name,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'verificationMethod': verificationMethod.name,
    if (verificationData != null) 'verificationData': verificationData,
    if (deviceInfo != null) 'deviceInfo': deviceInfo!.toMap(),
  };

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
