import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  group('LocationService', () {
    late MockLocationService service;

    setUp(() {
      service = MockLocationService();
    });

    test('can be mocked and returns GeoPosition', () async {
      final position = GeoPosition(
        latitude: 19.4326,
        longitude: -99.1332,
        accuracy: 5,
        timestamp: DateTime(2024),
        isMockLocation: false,
        provider: 'gps',
      );

      when(
        () => service.getCurrentPosition(),
      ).thenAnswer((_) async => position);

      final result = await service.getCurrentPosition();
      expect(result, position);
    });

    test('can check availability', () async {
      when(() => service.isAvailable()).thenAnswer((_) async => true);

      final result = await service.isAvailable();
      expect(result, isTrue);
    });
  });
}
