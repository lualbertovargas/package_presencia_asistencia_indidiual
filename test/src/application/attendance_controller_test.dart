// Test file: non-const constructors used for testing value equality.
// ignore_for_file: prefer_const_constructors

import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQrService extends Mock implements QrService {}

class MockLocationService extends Mock implements LocationService {}

class MockBiometricService extends Mock implements BiometricService {}

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class FakeAttendanceRecord extends Fake implements AttendanceRecord {}

void main() {
  late MockQrService qrService;
  late MockLocationService locationService;
  late MockBiometricService biometricService;
  late MockAttendanceRepository repository;

  const point = AttendancePoint(
    id: 'point-1',
    name: 'Office',
    latitude: 19.4326,
    longitude: -99.1332,
    radiusMeters: 100,
  );

  final qrResult = QrResult(
    attendancePointId: 'point-1',
    scannedAt: DateTime(2024),
  );

  final validPosition = GeoPosition(
    latitude: 19.4326,
    longitude: -99.1332,
    accuracy: 5,
    timestamp: DateTime(2024),
    isMockLocation: false,
    provider: 'gps',
  );

  setUpAll(() {
    registerFallbackValue(FakeAttendanceRecord());
  });

  setUp(() {
    qrService = MockQrService();
    locationService = MockLocationService();
    biometricService = MockBiometricService();
    repository = MockAttendanceRepository();
  });

  AttendanceController createController({
    AttendanceConfig config = const AttendanceConfig(
      requireQr: true,
      requireGeolocation: true,
      verificationMethod: VerificationMethod.biometric,
    ),
    CheckType checkType = CheckType.checkIn,
    AttendancePointResolver? pointResolver,
  }) {
    return AttendanceController(
      config: config,
      userId: 'user-1',
      checkType: checkType,
      repository: repository,
      qrService: qrService,
      locationService: locationService,
      biometricService: biometricService,
      pointResolver: pointResolver ?? (_) async => point,
    );
  }

  group('AttendanceController', () {
    test('initial state is idle', () {
      final controller = createController();
      expect(controller.value.step, AttendanceStep.idle);
      addTeardownLater(controller);
    });

    test('full flow completes successfully', () async {
      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => validPosition);
      when(() => biometricService.authenticate()).thenAnswer((_) async => true);
      when(
        () => repository.submitAttendance(any()),
      ).thenAnswer((_) async => AttendanceResult.success());

      final controller = createController();
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.completed);
      expect(controller.value.record, isNotNull);
      expect(controller.value.record!.userId, 'user-1');
      expect(controller.value.record!.attendancePointId, 'point-1');
      addTeardownLater(controller);
    });

    test('stops at error when QR point not found', () async {
      when(() => qrService.scan()).thenAnswer((_) async => qrResult);

      final controller = createController(
        pointResolver: (_) async => null,
      );
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(controller.value.errors, contains('POINT_NOT_FOUND'));
      addTeardownLater(controller);
    });

    test('stops at error when QR does not match point', () async {
      final wrongQr = QrResult(
        attendancePointId: 'wrong-point',
        scannedAt: DateTime(2024),
      );
      when(() => qrService.scan()).thenAnswer((_) async => wrongQr);

      final controller = createController();
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(controller.value.errors, contains('QR_POINT_MISMATCH'));
      addTeardownLater(controller);
    });

    test('stops at error when QR is expired', () async {
      final expiredQr = QrResult(
        attendancePointId: 'point-1',
        scannedAt: DateTime(2024, 1, 2),
        expiresAt: DateTime(2024),
      );
      when(() => qrService.scan()).thenAnswer((_) async => expiredQr);

      final controller = createController();
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(controller.value.errors, contains('QR_EXPIRED'));
      addTeardownLater(controller);
    });

    test('stops at error when duplicate check-in', () async {
      final lastCheckIn = AttendanceRecord(
        userId: 'user-1',
        attendancePointId: 'point-1',
        checkType: CheckType.checkIn,
        timestamp: DateTime(2024),
        latitude: 19.4326,
        longitude: -99.1332,
        verificationMethod: VerificationMethod.none,
      );

      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => lastCheckIn);

      final controller = createController();
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(controller.value.errors, contains('DUPLICATE_CHECK_IN'));
      addTeardownLater(controller);
    });

    test('stops at error when check-out without check-in', () async {
      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);

      final controller = createController(checkType: CheckType.checkOut);
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(controller.value.errors, contains('CHECK_OUT_WITHOUT_CHECK_IN'));
      addTeardownLater(controller);
    });

    test('stops at error when out of range', () async {
      final farPosition = GeoPosition(
        latitude: 20,
        longitude: -100,
        accuracy: 5,
        timestamp: DateTime(2024),
        isMockLocation: false,
        provider: 'gps',
      );

      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => farPosition);

      final controller = createController();
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(controller.value.errors, contains('OUT_OF_RANGE'));
      addTeardownLater(controller);
    });

    test('stops at error when mock location detected', () async {
      final mockPosition = GeoPosition(
        latitude: 19.4326,
        longitude: -99.1332,
        accuracy: 5,
        timestamp: DateTime(2024),
        isMockLocation: true,
        provider: 'mock',
      );

      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => mockPosition);

      final controller = createController();
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(controller.value.errors, contains('MOCK_LOCATION_DETECTED'));
      addTeardownLater(controller);
    });

    test('stops at error when biometric fails', () async {
      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => validPosition);
      when(
        () => biometricService.authenticate(),
      ).thenAnswer((_) async => false);

      final controller = createController();
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(controller.value.errors, contains('BIOMETRIC_FAILED'));
      addTeardownLater(controller);
    });

    test('stops at error when submission fails', () async {
      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => validPosition);
      when(() => biometricService.authenticate()).thenAnswer((_) async => true);
      when(() => repository.submitAttendance(any())).thenAnswer(
        (_) async => AttendanceResult.failure(
          errorCode: 'SERVER_ERROR',
          errorMessage: 'Internal error',
        ),
      );

      final controller = createController();
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(controller.value.errors, contains('SERVER_ERROR'));
      addTeardownLater(controller);
    });

    test('handles exception during flow', () async {
      when(() => qrService.scan()).thenThrow(Exception('Scanner crashed'));

      final controller = createController();
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(
        controller.value.errors.first,
        contains('UNEXPECTED_ERROR'),
      );
      addTeardownLater(controller);
    });

    test('skips QR when requireQr is false', () async {
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => validPosition);
      when(() => biometricService.authenticate()).thenAnswer((_) async => true);
      when(
        () => repository.submitAttendance(any()),
      ).thenAnswer((_) async => AttendanceResult.success());

      final controller = createController(
        config: AttendanceConfig(
          requireQr: false,
          requireGeolocation: false,
          verificationMethod: VerificationMethod.biometric,
        ),
      );
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.completed);
      verifyNever(() => qrService.scan());
      addTeardownLater(controller);
    });

    test('skips geolocation when requireGeolocation is false', () async {
      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(() => biometricService.authenticate()).thenAnswer((_) async => true);
      when(
        () => repository.submitAttendance(any()),
      ).thenAnswer((_) async => AttendanceResult.success());

      final controller = createController(
        config: AttendanceConfig(
          requireQr: true,
          requireGeolocation: false,
          verificationMethod: VerificationMethod.biometric,
        ),
      );
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.completed);
      verifyNever(() => locationService.getCurrentPosition());
      addTeardownLater(controller);
    });

    test('skips biometric when verificationMethod is none', () async {
      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => validPosition);
      when(
        () => repository.submitAttendance(any()),
      ).thenAnswer((_) async => AttendanceResult.success());

      final controller = createController(
        config: AttendanceConfig(
          requireQr: true,
          requireGeolocation: true,
          verificationMethod: VerificationMethod.none,
        ),
      );
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.completed);
      verifyNever(() => biometricService.authenticate());
      addTeardownLater(controller);
    });

    test('reset returns to idle state', () async {
      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => validPosition);
      when(() => biometricService.authenticate()).thenAnswer((_) async => true);
      when(
        () => repository.submitAttendance(any()),
      ).thenAnswer((_) async => AttendanceResult.success());

      final controller = createController();
      await controller.startFlow();
      expect(controller.value.step, AttendanceStep.completed);

      controller.reset();
      expect(controller.value.step, AttendanceStep.idle);
      expect(controller.value.errors, isEmpty);
      expect(controller.value.record, isNull);
      addTeardownLater(controller);
    });
  });
}

/// Adds a teardown that disposes the controller after the test.
void addTeardownLater(AttendanceController controller) {
  addTearDown(controller.dispose);
}
