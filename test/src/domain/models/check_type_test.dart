import 'package:attendance_mobile/src/domain/models/check_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckType', () {
    test('has expected values', () {
      expect(CheckType.values, hasLength(2));
      expect(CheckType.values, contains(CheckType.checkIn));
      expect(CheckType.values, contains(CheckType.checkOut));
    });
  });
}
