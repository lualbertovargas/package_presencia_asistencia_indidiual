import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class FakeAttendanceRecord extends Fake implements AttendanceRecord {}

void main() {
  group('AttendanceRepository', () {
    late MockAttendanceRepository repository;

    setUpAll(() {
      registerFallbackValue(FakeAttendanceRecord());
    });

    setUp(() {
      repository = MockAttendanceRepository();
    });

    test('can submit attendance and return success', () async {
      when(
        () => repository.submitAttendance(any()),
      ).thenAnswer((_) async => const AttendanceResult.success());

      final record = AttendanceRecord(
        userId: 'user-1',
        attendancePointId: 'point-1',
        checkType: CheckType.checkIn,
        timestamp: DateTime(2024),
        latitude: 19.4326,
        longitude: -99.1332,
        verificationMethod: VerificationMethod.none,
      );

      final result = await repository.submitAttendance(record);
      expect(result.success, isTrue);
    });

    test('can get last record returning null', () async {
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);

      final result = await repository.getLastRecord('user-1', 'point-1');
      expect(result, isNull);
    });

    test('can get last record returning a record', () async {
      final record = AttendanceRecord(
        userId: 'user-1',
        attendancePointId: 'point-1',
        checkType: CheckType.checkIn,
        timestamp: DateTime(2024),
        latitude: 19.4326,
        longitude: -99.1332,
        verificationMethod: VerificationMethod.none,
      );

      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => record);

      final result = await repository.getLastRecord('user-1', 'point-1');
      expect(result, record);
    });
  });
}
