# Services & Data Layer

> `lib/src/domain/services/` y `lib/src/data/`

Todas son **interfaces abstractas**. La app consumidora debe proveer las implementaciones concretas. El package no depende de ningun plugin concreto de camara, GPS o biometria.

---

## LocationService

> `domain/services/location_service.dart`

Obtiene la ubicacion del dispositivo.

```dart
abstract class LocationService {
  Future<GeoPosition> getCurrentPosition();
  Future<bool> isAvailable();
}
```

| Metodo | Retorna | Descripcion |
|--------|---------|-------------|
| `getCurrentPosition()` | `Future<GeoPosition>` | Posicion actual con metadata anti-fraude |
| `isAvailable()` | `Future<bool>` | Si el servicio de ubicacion esta disponible |

### Ejemplo de implementacion (app consumidora)

```dart
class GeolocatorLocationService implements LocationService {
  @override
  Future<GeoPosition> getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    return GeoPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      isMockLocation: position.isMocked,
      provider: 'fused',
    );
  }

  @override
  Future<bool> isAvailable() => Geolocator.isLocationServiceEnabled();
}
```

---

## BiometricService

> `domain/services/biometric_service.dart`

Maneja autenticacion biometrica del dispositivo.

```dart
abstract class BiometricService {
  Future<bool> authenticate();
  Future<bool> isAvailable();
}
```

| Metodo | Retorna | Descripcion |
|--------|---------|-------------|
| `authenticate()` | `Future<bool>` | `true` si la autenticacion fue exitosa |
| `isAvailable()` | `Future<bool>` | Si el dispositivo soporta biometria |

### Ejemplo de implementacion

```dart
class LocalAuthBiometricService implements BiometricService {
  final _auth = LocalAuthentication();

  @override
  Future<bool> authenticate() => _auth.authenticate(
    localizedReason: 'Verifica tu identidad para marcar asistencia',
  );

  @override
  Future<bool> isAvailable() => _auth.canCheckBiometrics;
}
```

---

## QrService

> `domain/services/qr_service.dart`

Escanea codigos QR y retorna el resultado parseado.

```dart
abstract class QrService {
  Future<QrResult> scan();
}
```

| Metodo | Retorna | Descripcion |
|--------|---------|-------------|
| `scan()` | `Future<QrResult>` | Resultado del escaneo con ID del punto |

### Ejemplo de implementacion

```dart
class MobileScannerQrService implements QrService {
  @override
  Future<QrResult> scan() async {
    final rawData = await MobileScanner.scan();
    final decoded = jsonDecode(rawData);
    return QrResult(
      attendancePointId: decoded['pointId'],
      scannedAt: DateTime.now(),
      expiresAt: DateTime.tryParse(decoded['expires'] ?? ''),
      rawData: rawData,
    );
  }
}
```

---

## AttendanceRepository

> `data/attendance_repository.dart`

Persiste y consulta registros de asistencia.

```dart
abstract class AttendanceRepository {
  Future<AttendanceResult> submitAttendance(AttendanceRecord record);
  Future<AttendanceRecord?> getLastRecord(String userId, String pointId);
}
```

| Metodo | Retorna | Descripcion |
|--------|---------|-------------|
| `submitAttendance(record)` | `Future<AttendanceResult>` | Envia el registro (API, local, etc.) |
| `getLastRecord(userId, pointId)` | `Future<AttendanceRecord?>` | Ultimo registro del usuario en ese punto |

### Ejemplo de implementacion

```dart
class ApiAttendanceRepository implements AttendanceRepository {
  final HttpClient _client;

  @override
  Future<AttendanceResult> submitAttendance(AttendanceRecord record) async {
    final response = await _client.post('/attendance', body: record.toJson());
    if (response.statusCode == 200) {
      return const AttendanceResult.success();
    }
    return AttendanceResult.failure(
      errorCode: 'SERVER_ERROR',
      errorMessage: response.body,
    );
  }

  @override
  Future<AttendanceRecord?> getLastRecord(String userId, String pointId) async {
    // Consultar API o cache local
  }
}
```

---

## Por que interfaces abstractas?

1. **Desacoplamiento**: El package no depende de `geolocator`, `local_auth`, `mobile_scanner`, etc.
2. **Testabilidad**: Se mockean facilmente con `mocktail`
3. **Flexibilidad**: Cada app consumidora elige sus plugins
4. **Peso**: El package es liviano, solo `equatable` + `flutter`
