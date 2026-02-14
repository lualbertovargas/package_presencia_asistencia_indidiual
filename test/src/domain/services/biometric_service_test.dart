import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBiometricService extends Mock implements BiometricService {}

void main() {
  group('BiometricService', () {
    late MockBiometricService service;

    setUp(() {
      service = MockBiometricService();
    });

    test('can be mocked and returns authentication result', () async {
      when(() => service.authenticate()).thenAnswer((_) async => true);

      final result = await service.authenticate();
      expect(result, isTrue);
    });

    test('can check availability', () async {
      when(() => service.isAvailable()).thenAnswer((_) async => false);

      final result = await service.isAvailable();
      expect(result, isFalse);
    });
  });
}
