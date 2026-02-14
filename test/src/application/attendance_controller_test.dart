// Test file: non-const constructors used for testing value equality.
// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:typed_data';

import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQrService extends Mock implements QrService {}

class MockLocationService extends Mock implements LocationService {}

class MockBiometricService extends Mock implements BiometricService {}

class MockCameraService extends Mock implements CameraService {}

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class FakeAttendanceRecord extends Fake implements AttendanceRecord {}

void main() {
  late MockQrService qrService;
  late MockLocationService locationService;
  late MockBiometricService biometricService;
  late MockCameraService cameraService;
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
    cameraService = MockCameraService();
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
    CameraService? cameraServiceOverride,
  }) {
    return AttendanceController(
      config: config,
      userId: 'user-1',
      checkType: checkType,
      repository: repository,
      qrService: qrService,
      locationService: locationService,
      biometricService: biometricService,
      cameraService: cameraServiceOverride ?? cameraService,
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
      expect(controller.value.errors, contains(ErrorCodes.pointNotFound));
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
      expect(controller.value.errors, contains(ErrorCodes.qrPointMismatch));
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
      expect(controller.value.errors, contains(ErrorCodes.qrExpired));
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
      expect(controller.value.errors, contains(ErrorCodes.duplicateCheckIn));
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
      expect(
        controller.value.errors,
        contains(ErrorCodes.checkOutWithoutCheckIn),
      );
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
      expect(controller.value.errors, contains(ErrorCodes.outOfRange));
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
      expect(
        controller.value.errors,
        contains(ErrorCodes.mockLocationDetected),
      );
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
      expect(controller.value.errors, contains(ErrorCodes.biometricFailed));
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
        contains(ErrorCodes.unexpectedErrorPrefix),
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

    test('full flow with selfie completes successfully', () async {
      final photoBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final photo = PhotoCapture(
        bytes: photoBytes,
        mimeType: 'image/jpeg',
        timestamp: DateTime(2024),
      );

      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => validPosition);
      when(() => cameraService.takePhoto()).thenAnswer((_) async => photo);
      when(
        () => repository.submitAttendance(any()),
      ).thenAnswer((_) async => AttendanceResult.success());

      final controller = createController(
        config: AttendanceConfig(
          requireQr: true,
          requireGeolocation: true,
          verificationMethod: VerificationMethod.selfie,
        ),
      );
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.completed);
      expect(controller.value.record, isNotNull);
      expect(
        controller.value.record!.verificationData,
        base64Encode(photoBytes),
      );
      verify(() => cameraService.takePhoto()).called(1);
      verifyNever(() => biometricService.authenticate());
      addTeardownLater(controller);
    });

    test('stops at error when camera throws', () async {
      when(() => qrService.scan()).thenAnswer((_) async => qrResult);
      when(
        () => repository.getLastRecord(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => validPosition);
      when(
        () => cameraService.takePhoto(),
      ).thenThrow(Exception('Camera failed'));

      final controller = createController(
        config: AttendanceConfig(
          requireQr: true,
          requireGeolocation: true,
          verificationMethod: VerificationMethod.selfie,
        ),
      );
      await controller.startFlow();

      expect(controller.value.step, AttendanceStep.error);
      expect(
        controller.value.errors.first,
        contains(ErrorCodes.unexpectedErrorPrefix),
      );
      addTeardownLater(controller);
    });

    test('skips camera when verificationMethod is biometric', () async {
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
      verifyNever(() => cameraService.takePhoto());
      addTeardownLater(controller);
    });

    test('skips camera when verificationMethod is none', () async {
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
      verifyNever(() => cameraService.takePhoto());
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

    group('cancelFlow', () {
      test('sets state to cancelled', () {
        final controller = createController()..cancelFlow();

        expect(controller.value.step, AttendanceStep.cancelled);
        addTeardownLater(controller);
      });

      test('flag resets on new startFlow', () async {
        when(() => qrService.scan()).thenAnswer((_) async => qrResult);
        when(
          () => repository.getLastRecord(any(), any()),
        ).thenAnswer((_) async => null);
        when(
          () => locationService.getCurrentPosition(),
        ).thenAnswer((_) async => validPosition);
        when(
          () => biometricService.authenticate(),
        ).thenAnswer((_) async => true);
        when(
          () => repository.submitAttendance(any()),
        ).thenAnswer((_) async => AttendanceResult.success());

        final controller = createController()..cancelFlow();
        expect(controller.value.step, AttendanceStep.cancelled);

        await controller.startFlow();
        expect(controller.value.step, AttendanceStep.completed);
        addTeardownLater(controller);
      });
    });

    group('timeout', () {
      test('produces STEP_TIMEOUT when step exceeds timeout', () async {
        when(() => qrService.scan()).thenAnswer(
          (_) async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return qrResult;
          },
        );

        final controller = AttendanceController(
          config: AttendanceConfig(
            requireQr: true,
            requireGeolocation: false,
            verificationMethod: VerificationMethod.none,
            stepTimeout: const Duration(milliseconds: 1),
          ),
          userId: 'user-1',
          checkType: CheckType.checkIn,
          repository: repository,
          qrService: qrService,
          pointResolver: (_) async => point,
        );
        await controller.startFlow();

        expect(controller.value.step, AttendanceStep.error);
        expect(controller.value.errors, contains(ErrorCodes.stepTimeout));
        addTeardownLater(controller);
      });
    });

    group('photo size validation', () {
      test('produces PHOTO_TOO_LARGE when photo exceeds limit', () async {
        final bigPhoto = PhotoCapture(
          bytes: Uint8List(1000),
          mimeType: 'image/jpeg',
          timestamp: DateTime(2024),
        );

        when(() => qrService.scan()).thenAnswer((_) async => qrResult);
        when(
          () => repository.getLastRecord(any(), any()),
        ).thenAnswer((_) async => null);
        when(
          () => locationService.getCurrentPosition(),
        ).thenAnswer((_) async => validPosition);
        when(() => cameraService.takePhoto()).thenAnswer((_) async => bigPhoto);

        final controller = AttendanceController(
          config: AttendanceConfig(
            requireQr: true,
            requireGeolocation: true,
            verificationMethod: VerificationMethod.selfie,
            maxPhotoBytes: 500,
          ),
          userId: 'user-1',
          checkType: CheckType.checkIn,
          repository: repository,
          qrService: qrService,
          locationService: locationService,
          biometricService: biometricService,
          cameraService: cameraService,
          pointResolver: (_) async => point,
        );
        await controller.startFlow();

        expect(controller.value.step, AttendanceStep.error);
        expect(controller.value.errors, contains(ErrorCodes.photoTooLarge));
        addTeardownLater(controller);
      });

      test('completes when photo is within limit', () async {
        final smallPhoto = PhotoCapture(
          bytes: Uint8List(100),
          mimeType: 'image/jpeg',
          timestamp: DateTime(2024),
        );

        when(() => qrService.scan()).thenAnswer((_) async => qrResult);
        when(
          () => repository.getLastRecord(any(), any()),
        ).thenAnswer((_) async => null);
        when(
          () => locationService.getCurrentPosition(),
        ).thenAnswer((_) async => validPosition);
        when(
          () => cameraService.takePhoto(),
        ).thenAnswer((_) async => smallPhoto);
        when(
          () => repository.submitAttendance(any()),
        ).thenAnswer((_) async => AttendanceResult.success());

        final controller = AttendanceController(
          config: AttendanceConfig(
            requireQr: true,
            requireGeolocation: true,
            verificationMethod: VerificationMethod.selfie,
            maxPhotoBytes: 500,
          ),
          userId: 'user-1',
          checkType: CheckType.checkIn,
          repository: repository,
          qrService: qrService,
          locationService: locationService,
          biometricService: biometricService,
          cameraService: cameraService,
          pointResolver: (_) async => point,
        );
        await controller.startFlow();

        expect(controller.value.step, AttendanceStep.completed);
        addTeardownLater(controller);
      });
    });

    group('constructor asserts', () {
      test('asserts qrService when requireQr is true', () {
        expect(
          () => AttendanceController(
            config: AttendanceConfig(
              requireQr: true,
              requireGeolocation: false,
              verificationMethod: VerificationMethod.none,
            ),
            userId: 'user-1',
            checkType: CheckType.checkIn,
            repository: repository,
            pointResolver: (_) async => null,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('asserts pointResolver when requireQr is true', () {
        expect(
          () => AttendanceController(
            config: AttendanceConfig(
              requireQr: true,
              requireGeolocation: false,
              verificationMethod: VerificationMethod.none,
            ),
            userId: 'user-1',
            checkType: CheckType.checkIn,
            repository: repository,
            qrService: qrService,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('asserts locationService when requireGeolocation is true', () {
        expect(
          () => AttendanceController(
            config: AttendanceConfig(
              requireQr: false,
              requireGeolocation: true,
              verificationMethod: VerificationMethod.none,
            ),
            userId: 'user-1',
            checkType: CheckType.checkIn,
            repository: repository,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('asserts biometricService when verificationMethod is biometric', () {
        expect(
          () => AttendanceController(
            config: AttendanceConfig(
              requireQr: false,
              requireGeolocation: false,
              verificationMethod: VerificationMethod.biometric,
            ),
            userId: 'user-1',
            checkType: CheckType.checkIn,
            repository: repository,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('asserts cameraService when verificationMethod is selfie', () {
        expect(
          () => AttendanceController(
            config: AttendanceConfig(
              requireQr: false,
              requireGeolocation: false,
              verificationMethod: VerificationMethod.selfie,
            ),
            userId: 'user-1',
            checkType: CheckType.checkIn,
            repository: repository,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });
}

/// Adds a teardown that disposes the controller after the test.
void addTeardownLater(AttendanceController controller) {
  addTearDown(controller.dispose);
}
