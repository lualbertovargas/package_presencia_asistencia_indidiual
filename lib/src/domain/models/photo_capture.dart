import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A photo captured during the attendance flow.
class PhotoCapture extends Equatable {
  /// Creates a [PhotoCapture].
  const PhotoCapture({
    required this.bytes,
    required this.mimeType,
    required this.timestamp,
    this.width,
    this.height,
  });

  /// Raw image bytes.
  final Uint8List bytes;

  /// MIME type of the image (e.g., 'image/jpeg', 'image/png').
  final String mimeType;

  /// When the photo was captured.
  final DateTime timestamp;

  /// Optional image width in pixels.
  final int? width;

  /// Optional image height in pixels.
  final int? height;

  // Uint8List uses reference equality, so bytes is intentionally excluded
  // from props. Two PhotoCapture instances with the same bytes but different
  // references would not be equal via Equatable.
  @override
  List<Object?> get props => [mimeType, timestamp, width, height];
}
