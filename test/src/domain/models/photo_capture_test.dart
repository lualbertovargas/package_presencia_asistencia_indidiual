import 'dart:typed_data';

import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhotoCapture', () {
    final timestamp = DateTime(2024);
    final bytes = Uint8List.fromList([1, 2, 3]);

    test('can be instantiated', () {
      expect(
        PhotoCapture(
          bytes: bytes,
          mimeType: 'image/jpeg',
          timestamp: timestamp,
        ),
        isNotNull,
      );
    });

    test('fields are accessible', () {
      final photo = PhotoCapture(
        bytes: bytes,
        mimeType: 'image/jpeg',
        timestamp: timestamp,
        width: 640,
        height: 480,
      );

      expect(photo.bytes, bytes);
      expect(photo.mimeType, 'image/jpeg');
      expect(photo.timestamp, timestamp);
      expect(photo.width, 640);
      expect(photo.height, 480);
    });

    test('optional fields default to null', () {
      final photo = PhotoCapture(
        bytes: bytes,
        mimeType: 'image/png',
        timestamp: timestamp,
      );

      expect(photo.width, isNull);
      expect(photo.height, isNull);
    });

    test('props does not include bytes', () {
      final a = PhotoCapture(
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
        timestamp: timestamp,
      );
      final b = PhotoCapture(
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
        timestamp: timestamp,
      );

      // Different Uint8List references with same content.
      // Because bytes is excluded from props, they are still equal.
      expect(a, equals(b));
    });

    test('different mimeType means not equal', () {
      final a = PhotoCapture(
        bytes: bytes,
        mimeType: 'image/jpeg',
        timestamp: timestamp,
      );
      final b = PhotoCapture(
        bytes: bytes,
        mimeType: 'image/png',
        timestamp: timestamp,
      );

      expect(a, isNot(equals(b)));
    });
  });
}
