import 'package:attendance_mobile/src/domain/models/models.dart';

/// Abstract interface for persisting and querying attendance records.
///
/// The consuming app must provide an implementation.
abstract class AttendanceRepository {
  /// Submits an attendance record.
  Future<AttendanceResult> submitAttendance(AttendanceRecord record);

  /// Returns the last attendance record for a user at a given point,
  /// or `null` if none exists.
  Future<AttendanceRecord?> getLastRecord(String userId, String pointId);
}
