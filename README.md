# Attendance Mobile

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A vendible, integrable Flutter package for in-person attendance using QR codes, geolocation, and device biometrics.

## Features

- **QR Code scanning** with point matching and expiration validation
- **Geolocation** with Haversine-based radius validation and mock location detection
- **Biometric verification** via system biometrics (fingerprint, Face ID)
- **Anti-fraud** device info capture (GPS accuracy, mock detection, provider)
- **Zero external dependencies** for state management (uses `ValueNotifier`)
- **No HTTP, no auth, no endpoints** - the package generates events and the consumer handles networking

## Architecture

```
attendance_mobile/
  lib/src/
    domain/
      models/       # Equatable value objects (AttendanceRecord, GeoPosition, etc.)
      rules/        # Pure validation (QrRules, GeoRules, AttendanceRules)
      services/     # Abstract interfaces (LocationService, BiometricService, QrService)
    data/           # Abstract AttendanceRepository
    application/    # AttendanceController (ValueNotifier) + AttendanceState
    ui/             # Minimal Flutter widgets with ValueListenableBuilder
```

## Quick Start

```dart
import 'package:attendance_mobile/attendance_mobile.dart';

// 1. Implement the abstract services
class MyLocationService implements LocationService { ... }
class MyBiometricService implements BiometricService { ... }
class MyQrService implements QrService { ... }
class MyRepository implements AttendanceRepository { ... }

// 2. Create controller
final controller = AttendanceController(
  config: const AttendanceConfig(
    requireQr: true,
    requireGeolocation: true,
    verificationMethod: VerificationMethod.biometric,
  ),
  userId: 'user-123',
  checkType: CheckType.checkIn,
  repository: myRepository,
  qrService: myQrService,
  locationService: myLocationService,
  biometricService: myBiometricService,
  pointResolver: (id) => myApi.getPoint(id),
);

// 3. Start the flow
await controller.startFlow();

// 4. Or use the built-in UI
AttendanceFlowPage(controller: controller);
```

## Attendance Flow

1. Scan QR (if `config.requireQr`)
2. Resolve `AttendancePoint` via `pointResolver` callback
3. Validate QR rules (point match, expiration)
4. Validate attendance rules (no duplicate check-in)
5. Obtain geolocation (if `config.requireGeolocation`)
6. Validate geo rules (radius + mock detection)
7. Verify identity (if `config.verificationMethod == biometric`)
8. Build `AttendanceRecord` with `DeviceInfo`
9. Submit via `AttendanceRepository`
10. Return result (success/error)

## Running Tests

```sh
flutter test
```

```sh
flutter test --coverage
```

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
