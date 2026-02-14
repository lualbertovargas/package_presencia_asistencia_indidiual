import 'dart:async';
import 'dart:convert';

import 'package:attendance_mobile/src/application/attendance_state.dart';
import 'package:attendance_mobile/src/data/data.dart';
import 'package:attendance_mobile/src/domain/constants/constants.dart';
import 'package:attendance_mobile/src/domain/models/models.dart';
import 'package:attendance_mobile/src/domain/rules/rules.dart';
import 'package:attendance_mobile/src/domain/services/services.dart';
import 'package:flutter/foundation.dart';

/// Callback to resolve an [AttendancePoint] by its ID.
///
/// The consuming app provides the implementation (e.g., from cache or API).
typedef AttendancePointResolver = Future<AttendancePoint?> Function(String id);

/// Orchestrates the full attendance flow.
///
/// Uses [ValueNotifier] to avoid external state-management dependencies.
class AttendanceController extends ValueNotifier<AttendanceState> {
  /// Creates an [AttendanceController].
  AttendanceController({
    required this.config,
    required this.userId,
    required this.checkType,
    required this.repository,
    this.qrService,
    this.locationService,
    this.biometricService,
    this.cameraService,
    this.pointResolver,
  }) : assert(
         !config.requireQr || qrService != null,
         'qrService must be provided when requireQr is true',
       ),
       assert(
         !config.requireQr || pointResolver != null,
         'pointResolver must be provided when requireQr is true',
       ),
       assert(
         !config.requireGeolocation || locationService != null,
         'locationService must be provided when requireGeolocation is true',
       ),
       assert(
         config.verificationMethod != VerificationMethod.biometric ||
             biometricService != null,
         'biometricService must be provided when verificationMethod '
         'is biometric',
       ),
       assert(
         config.verificationMethod != VerificationMethod.selfie ||
             cameraService != null,
         'cameraService must be provided when verificationMethod is selfie',
       ),
       super(const AttendanceState());

  /// Configuration for this attendance flow.
  final AttendanceConfig config;

  /// ID of the user performing the attendance.
  final String userId;

  /// Whether this is a check-in or check-out.
  final CheckType checkType;

  /// Repository for persisting attendance records.
  final AttendanceRepository repository;

  /// Service for scanning QR codes.
  /// Required when `AttendanceConfig.requireQr` is `true`.
  final QrService? qrService;

  /// Service for obtaining location.
  /// Required when `AttendanceConfig.requireGeolocation` is `true`.
  final LocationService? locationService;

  /// Service for biometric authentication.
  /// Required when `AttendanceConfig.verificationMethod` is
  /// [VerificationMethod.biometric].
  final BiometricService? biometricService;

  /// Service for camera photo capture.
  /// Required when `AttendanceConfig.verificationMethod` is
  /// [VerificationMethod.selfie].
  final CameraService? cameraService;

  /// Callback to resolve an [AttendancePoint] from a QR-scanned ID.
  final AttendancePointResolver? pointResolver;

  bool _cancelled = false;

  /// Cancels the current flow.
  void cancelFlow() {
    _cancelled = true;
    value = value.copyWith(step: AttendanceStep.cancelled);
  }

  bool _checkCancelled() {
    if (_cancelled) {
      value = value.copyWith(step: AttendanceStep.cancelled);
      return true;
    }
    return false;
  }

  Future<T> _withTimeout<T>(Future<T> future) {
    final timeout = config.stepTimeout;
    if (timeout == null) return future;
    return future.timeout(timeout);
  }

  /// Starts the attendance flow.
  Future<void> startFlow() async {
    _cancelled = false;
    try {
      value = const AttendanceState(step: AttendanceStep.scanningQr);

      QrResult? qrResult;
      AttendancePoint? point;

      // Step 1: Scan QR
      if (config.requireQr) {
        qrResult = await _withTimeout(qrService!.scan());
        if (_checkCancelled()) return;

        // Step 2: Resolve attendance point
        value = value.copyWith(step: AttendanceStep.validatingQr);
        point = await _withTimeout(
          pointResolver!(qrResult!.attendancePointId),
        );
        if (_checkCancelled()) return;

        if (point == null) {
          value = value.copyWith(
            step: AttendanceStep.error,
            errors: [ErrorCodes.pointNotFound],
          );
          return;
        }

        // Step 3: Validate QR rules
        final qrErrors = QrRules.validate(qrResult: qrResult, point: point);
        if (qrErrors.isNotEmpty) {
          value = value.copyWith(
            step: AttendanceStep.error,
            errors: qrErrors,
          );
          return;
        }
      }

      if (_checkCancelled()) return;

      // Step 4: Validate attendance rules (no double check-in)
      final lastRecord = await _withTimeout(
        repository.getLastRecord(userId, point?.id ?? ''),
      );
      if (_checkCancelled()) return;

      final attendanceErrors = AttendanceRules.validate(
        checkType: checkType,
        lastRecord: lastRecord,
      );
      if (attendanceErrors.isNotEmpty) {
        value = value.copyWith(
          step: AttendanceStep.error,
          errors: attendanceErrors,
        );
        return;
      }

      // Step 5: Get geolocation
      GeoPosition? position;
      if (config.requireGeolocation) {
        value = value.copyWith(step: AttendanceStep.locating);
        position = await _withTimeout(
          locationService!.getCurrentPosition(),
        );
        if (_checkCancelled()) return;

        // Step 6: Validate geo rules
        value = value.copyWith(step: AttendanceStep.validatingLocation);
        final geoErrors = GeoRules.validate(
          position: position!,
          point: point!,
          config: config,
        );
        if (geoErrors.isNotEmpty) {
          value = value.copyWith(
            step: AttendanceStep.error,
            errors: geoErrors,
          );
          return;
        }
      }

      if (_checkCancelled()) return;

      // Step 7: Verify identity
      String? verificationData;
      if (config.verificationMethod == VerificationMethod.biometric) {
        value = value.copyWith(step: AttendanceStep.verifyingIdentity);
        final authenticated = await _withTimeout(
          biometricService!.authenticate(),
        );
        if (_checkCancelled()) return;
        if (!authenticated) {
          value = value.copyWith(
            step: AttendanceStep.error,
            errors: [ErrorCodes.biometricFailed],
          );
          return;
        }
      } else if (config.verificationMethod == VerificationMethod.selfie) {
        value = value.copyWith(step: AttendanceStep.verifyingIdentity);
        final photo = await _withTimeout(cameraService!.takePhoto());
        if (_checkCancelled()) return;

        // Validate photo size
        if (config.maxPhotoBytes != null &&
            photo.bytes.length > config.maxPhotoBytes!) {
          value = value.copyWith(
            step: AttendanceStep.error,
            errors: [ErrorCodes.photoTooLarge],
          );
          return;
        }

        verificationData = base64Encode(photo.bytes);
      }

      if (_checkCancelled()) return;

      // Step 8: Build record
      value = value.copyWith(step: AttendanceStep.submitting);

      final now = DateTime.now();
      final record = AttendanceRecord(
        userId: userId,
        attendancePointId: point?.id ?? '',
        checkType: checkType,
        timestamp: now,
        latitude: position?.latitude ?? 0,
        longitude: position?.longitude ?? 0,
        verificationMethod: config.verificationMethod,
        verificationData: verificationData,
        deviceInfo: position != null
            ? DeviceInfo(
                deviceTimestamp: now,
                gpsAccuracy: position.accuracy,
                isMockLocation: position.isMockLocation,
                locationProvider: position.provider,
              )
            : null,
      );

      // Step 9: Submit
      final result = await _withTimeout(
        repository.submitAttendance(record),
      );
      if (_checkCancelled()) return;

      // Step 10: Result
      if (result.success) {
        value = value.copyWith(
          step: AttendanceStep.completed,
          record: record,
        );
      } else {
        value = value.copyWith(
          step: AttendanceStep.error,
          errors: [if (result.errorCode != null) result.errorCode!],
        );
      }
    } on TimeoutException {
      value = value.copyWith(
        step: AttendanceStep.error,
        errors: [ErrorCodes.stepTimeout],
      );
    } on Exception catch (e) {
      value = value.copyWith(
        step: AttendanceStep.error,
        errors: ['${ErrorCodes.unexpectedErrorPrefix}: $e'],
      );
    }
  }

  /// Resets the controller to idle state.
  void reset() {
    value = const AttendanceState();
  }
}
