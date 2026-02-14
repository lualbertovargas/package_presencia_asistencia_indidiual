import 'package:equatable/equatable.dart';

/// Result of scanning a QR code for attendance.
class QrResult extends Equatable {
  /// Creates a [QrResult].
  const QrResult({
    required this.attendancePointId,
    required this.scannedAt,
    this.expiresAt,
    this.rawData,
  });

  /// The attendance point ID extracted from the QR code.
  final String attendancePointId;

  /// Timestamp when the QR was scanned.
  final DateTime scannedAt;

  /// Optional expiration time of the QR code.
  final DateTime? expiresAt;

  /// Optional raw QR data for audit purposes.
  final String? rawData;

  @override
  List<Object?> get props => [attendancePointId, scannedAt, expiresAt, rawData];
}
