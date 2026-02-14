import 'package:attendance_mobile/src/domain/models/models.dart';

/// Abstract interface for obtaining device location.
///
/// The consuming app must provide an implementation.
abstract class LocationService {
  /// Returns the current geographic position.
  Future<GeoPosition> getCurrentPosition();

  /// Whether location services are available.
  Future<bool> isAvailable();
}
