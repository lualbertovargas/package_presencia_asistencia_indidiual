import 'package:attendance_mobile/src/domain/models/models.dart';

/// Abstract interface for camera photo capture.
///
/// The consuming app must provide an implementation
/// (e.g., using `camera`, `image_picker`, etc.).
abstract class CameraService {
  /// Captures a photo and returns the result.
  Future<PhotoCapture> takePhoto();

  /// Whether a camera is available on this device.
  Future<bool> isAvailable();
}
