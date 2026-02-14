import 'dart:typed_data';

import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCameraService extends Mock implements CameraService {}

void main() {
  group('CameraService', () {
    late MockCameraService cameraService;

    setUp(() {
      cameraService = MockCameraService();
    });

    test('can be mocked', () {
      expect(cameraService, isNotNull);
    });

    test('takePhoto returns PhotoCapture', () async {
      final photo = PhotoCapture(
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
        timestamp: DateTime(2024),
      );
      when(() => cameraService.takePhoto()).thenAnswer((_) async => photo);

      final result = await cameraService.takePhoto();

      expect(result, photo);
      verify(() => cameraService.takePhoto()).called(1);
    });

    test('isAvailable returns bool', () async {
      when(() => cameraService.isAvailable()).thenAnswer((_) async => true);

      final result = await cameraService.isAvailable();

      expect(result, isTrue);
      verify(() => cameraService.isAvailable()).called(1);
    });
  });
}
