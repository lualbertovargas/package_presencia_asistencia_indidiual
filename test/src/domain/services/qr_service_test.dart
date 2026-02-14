import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQrService extends Mock implements QrService {}

void main() {
  group('QrService', () {
    late MockQrService service;

    setUp(() {
      service = MockQrService();
    });

    test('can be mocked and returns QrResult', () async {
      final qrResult = QrResult(
        attendancePointId: 'point-1',
        scannedAt: DateTime(2024),
      );

      when(() => service.scan()).thenAnswer((_) async => qrResult);

      final result = await service.scan();
      expect(result, qrResult);
    });
  });
}
