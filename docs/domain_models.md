# Domain Models

> `lib/src/domain/models/`

Todos los modelos extienden `Equatable` con `const` constructors. Son value objects inmutables sin logica de negocio.

---

## GeoPosition

> `geo_position.dart`

Posicion geografica capturada del dispositivo con metadata anti-fraude.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `latitude` | `double` | Latitud en grados |
| `longitude` | `double` | Longitud en grados |
| `accuracy` | `double` | Precision en metros |
| `timestamp` | `DateTime` | Momento de captura |
| `isMockLocation` | `bool` | Si es ubicacion falsa/mock |
| `provider` | `String` | Proveedor (gps, network, fused) |

**Uso**: Se obtiene de `LocationService.getCurrentPosition()` y se pasa a `GeoRules.validate()`.

---

## VerificationMethod

> `verification_method.dart`

Enum que define como se verifica la identidad.

| Valor | Descripcion |
|-------|-------------|
| `biometric` | Huella, Face ID, etc. |
| `selfie` | Verificacion por selfie (Fase 2) |
| `none` | Sin verificacion |

---

## CheckType

> `check_type.dart`

Enum que define el tipo de marcacion.

| Valor | Descripcion |
|-------|-------------|
| `checkIn` | Entrada / llegada |
| `checkOut` | Salida / partida |

---

## AttendancePoint

> `attendance_point.dart`

Ubicacion fisica donde se puede marcar asistencia.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `id` | `String` | ID unico del punto |
| `name` | `String` | Nombre legible |
| `latitude` | `double` | Latitud del centro |
| `longitude` | `double` | Longitud del centro |
| `radiusMeters` | `double` | Radio permitido en metros |

**Uso**: Se resuelve via `AttendancePointResolver` callback a partir del ID extraido del QR.

---

## DeviceInfo

> `device_info.dart`

Informacion del dispositivo para deteccion de fraude.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `deviceTimestamp` | `DateTime` | Timestamp local del dispositivo |
| `gpsAccuracy` | `double` | Precision GPS en metros |
| `isMockLocation` | `bool` | Si se detecto mock location |
| `locationProvider` | `String` | Proveedor de ubicacion usado |

**Uso**: Se construye automaticamente en `AttendanceController` a partir de la `GeoPosition`.

---

## AttendanceRecord

> `attendance_record.dart`

Registro completo de asistencia listo para enviar.

| Campo | Tipo | Requerido | Descripcion |
|-------|------|-----------|-------------|
| `userId` | `String` | Si | ID del usuario |
| `attendancePointId` | `String` | Si | ID del punto |
| `checkType` | `CheckType` | Si | Entrada o salida |
| `timestamp` | `DateTime` | Si | Timestamp canonico |
| `latitude` | `double` | Si | Latitud de marcacion |
| `longitude` | `double` | Si | Longitud de marcacion |
| `verificationMethod` | `VerificationMethod` | Si | Metodo usado |
| `verificationData` | `String?` | No | Payload de verificacion |
| `deviceInfo` | `DeviceInfo?` | No | Info anti-fraude |

**Uso**: Es el producto final del flujo. Se pasa a `AttendanceRepository.submitAttendance()`.

---

## AttendanceConfig

> `attendance_config.dart`

Configuracion de un flujo de asistencia.

| Campo | Tipo | Default | Descripcion |
|-------|------|---------|-------------|
| `requireQr` | `bool` | - | Si requiere escaneo QR |
| `requireGeolocation` | `bool` | - | Si requiere validacion GPS |
| `verificationMethod` | `VerificationMethod` | - | Metodo de verificacion |
| `geoRadiusOverride` | `double?` | `null` | Override del radio en metros |
| `allowMockLocation` | `bool` | `false` | Permitir ubicaciones mock (testing) |

**Uso**: Se pasa al `AttendanceController` para controlar que pasos del flujo se ejecutan.

---

## AttendanceResult

> `attendance_result.dart`

Resultado de un intento de envio de asistencia.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `success` | `bool` | Si fue exitoso |
| `errorCode` | `String?` | Codigo de error |
| `errorMessage` | `String?` | Mensaje legible |

**Factories**:
- `AttendanceResult.success()` - Resultado exitoso
- `AttendanceResult.failure(errorCode:, errorMessage:)` - Resultado fallido

**Uso**: Lo retorna `AttendanceRepository.submitAttendance()`.

---

## QrResult

> `qr_result.dart`

Resultado de escanear un codigo QR.

| Campo | Tipo | Requerido | Descripcion |
|-------|------|-----------|-------------|
| `attendancePointId` | `String` | Si | ID del punto extraido del QR |
| `scannedAt` | `DateTime` | Si | Cuando se escaneo |
| `expiresAt` | `DateTime?` | No | Expiracion del QR |
| `rawData` | `String?` | No | Data cruda para auditoria |

**Uso**: Lo retorna `QrService.scan()`. Se pasa a `QrRules.validate()`.

---

## Barrel

> `models.dart`

Exporta los 9 modelos:

```dart
export 'attendance_config.dart';
export 'attendance_point.dart';
export 'attendance_record.dart';
export 'attendance_result.dart';
export 'check_type.dart';
export 'device_info.dart';
export 'geo_position.dart';
export 'qr_result.dart';
export 'verification_method.dart';
```

---

## Tests

| Test file | Tests | Que valida |
|-----------|-------|------------|
| `geo_position_test.dart` | 3 | Instanciacion, igualdad, desigualdad |
| `verification_method_test.dart` | 1 | 3 valores del enum |
| `check_type_test.dart` | 1 | 2 valores del enum |
| `attendance_point_test.dart` | 3 | Instanciacion, igualdad, desigualdad por id |
| `device_info_test.dart` | 3 | Instanciacion, igualdad, desigualdad por mock |
| `attendance_record_test.dart` | 4 | Instanciacion, igualdad, campos opcionales, desigualdad por checkType |
| `attendance_config_test.dart` | 5 | Instanciacion, igualdad, default allowMock, geoRadius opcional, desigualdad |
| `attendance_result_test.dart` | 5 | Factory success, factory failure, igualdad success, igualdad failure, desigualdad |
| `qr_result_test.dart` | 4 | Instanciacion, igualdad, campos opcionales, desigualdad por pointId |

**Total: 29 tests**
