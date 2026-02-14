import 'package:attendance_mobile/src/domain/models/models.dart';

/// Abstract interface for QR code scanning.
///
/// The consuming app must provide an implementation.
// Intentionally a class: service interface for consumers.
// ignore: one_member_abstracts
abstract class QrService {
  /// Scans a QR code and returns the parsed result.
  Future<QrResult> scan();
}
