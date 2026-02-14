import 'package:attendance_mobile/src/domain/models/verification_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VerificationMethod', () {
    test('has expected values', () {
      expect(VerificationMethod.values, hasLength(3));
      expect(VerificationMethod.values, contains(VerificationMethod.biometric));
      expect(VerificationMethod.values, contains(VerificationMethod.selfie));
      expect(VerificationMethod.values, contains(VerificationMethod.none));
    });
  });
}
