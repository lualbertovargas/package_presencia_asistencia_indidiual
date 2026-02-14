# Flujo de Asistencia - Vision General

> Como funciona el package internamente y que produce como resultado.

---

## Principio de diseno

El package es un **orquestador de logica pura**. No conoce plugins, no hace HTTP, no maneja permisos. Solo:

1. Pide datos a traves de interfaces abstractas
2. Valida con reglas internas
3. Empaqueta todo en un `AttendanceRecord`
4. Lo retorna como objeto Dart o como `Map<String, dynamic>` listo para JSON

```
┌─────────────── APP CONSUMIDORA ──────────────┐
│  Permisos (camara, GPS, biometria)           │
│  HTTP / Auth / Tokens                        │
│  UI completa / Navegacion                    │
│  Manejo offline                              │
│                                              │
│   ┌─────────── PACKAGE ───────────┐          │
│   │  Orquestacion del flujo       │          │
│   │  Validaciones (QR, geo, dup.) │          │
│   │  Reglas de negocio            │          │
│   │  Record final + toMap()       │          │
│   └───────────────────────────────┘          │
└──────────────────────────────────────────────┘
```

---

## Flujo paso a paso

```
controller.startFlow()
       │
       ▼
  ┌─ Paso 1: Escanear QR
  │    qrService.scan()
  │    Retorna: QrResult(attendancePointId, scannedAt, expiresAt?)
  │    Salta si: config.requireQr == false
  │
  ├─ Paso 2: Resolver punto
  │    pointResolver(qrResult.attendancePointId)
  │    Retorna: AttendancePoint(id, name, lat, lng, radius)
  │    Error si: retorna null → POINT_NOT_FOUND
  │
  ├─ Paso 3: Validar reglas QR
  │    QrRules.validate(qrResult, point)
  │    Errores posibles: QR_POINT_MISMATCH, QR_EXPIRED
  │
  ├─ Paso 4: Validar asistencia
  │    repository.getLastRecord(userId, pointId)
  │    AttendanceRules.validate(checkType, lastRecord)
  │    Errores posibles: DUPLICATE_CHECK_IN, CHECK_OUT_WITHOUT_CHECK_IN, DUPLICATE_CHECK_OUT
  │
  ├─ Paso 5: Obtener ubicacion
  │    locationService.getCurrentPosition()
  │    Retorna: GeoPosition(lat, lng, accuracy, isMockLocation, provider)
  │    Salta si: config.requireGeolocation == false
  │
  ├─ Paso 6: Validar geolocalizacion
  │    GeoRules.validate(position, point, config)
  │    Usa Haversine para calcular distancia
  │    Errores posibles: OUT_OF_RANGE, MOCK_LOCATION_DETECTED
  │
  ├─ Paso 7: Verificar identidad
  │    Segun config.verificationMethod:
  │
  │    biometric → biometricService.authenticate()
  │                Error si retorna false → BIOMETRIC_FAILED
  │
  │    selfie   → cameraService.takePhoto()
  │                Retorna PhotoCapture(bytes, mimeType, timestamp)
  │                Los bytes se convierten a base64 → verificationData
  │
  │    none     → Se salta este paso
  │
  ├─ Paso 8: Construir record
  │    Arma AttendanceRecord con todos los datos recolectados
  │    Incluye DeviceInfo si hubo geolocalizacion
  │    Incluye verificationData si hubo selfie
  │
  ├─ Paso 9: Enviar
  │    repository.submitAttendance(record)
  │    Retorna: AttendanceResult.success() o .failure(errorCode)
  │
  └─ Paso 10: Resultado
       Exito → state.step = completed, state.record = record
       Error → state.step = error, state.errors = [codigos]
```

---

## Estados del flujo (AttendanceStep)

```
idle → scanningQr → validatingQr → locating → validatingLocation → verifyingIdentity → submitting → completed
                                                                                                   ↘ error
```

Cualquier paso puede saltar a `error`. El estado `verifyingIdentity` cubre tanto biometria como selfie (se distinguen por `config.verificationMethod`).

---

## Que contiene el record al final

Cuando `state.step == AttendanceStep.completed`, el record tiene:

```dart
final record = controller.value.record!;

record.userId;              // 'user-123'
record.attendancePointId;   // 'point-1'
record.checkType;           // CheckType.checkIn
record.timestamp;           // DateTime
record.latitude;            // 19.4326
record.longitude;           // -99.1332
record.verificationMethod;  // VerificationMethod.selfie
record.verificationData;    // 'AQIDBAUG...' (base64) o null
record.deviceInfo;          // DeviceInfo(...) o null
```

---

## toMap() - Serializacion

`record.toMap()` convierte el objeto a un mapa listo para `jsonEncode`:

```dart
final json = jsonEncode(record.toMap());
```

### Con selfie + geolocalizacion (caso completo)

```json
{
  "userId": "user-123",
  "attendancePointId": "point-1",
  "checkType": "checkIn",
  "timestamp": "2024-01-15T08:30:00.000",
  "latitude": 19.4326,
  "longitude": -99.1332,
  "verificationMethod": "selfie",
  "verificationData": "/9j/4AAQSkZJRg...",
  "deviceInfo": {
    "deviceTimestamp": "2024-01-15T08:30:00.000",
    "gpsAccuracy": 5.0,
    "isMockLocation": false,
    "locationProvider": "gps"
  }
}
```

### Con biometria (sin foto)

```json
{
  "userId": "user-123",
  "attendancePointId": "point-1",
  "checkType": "checkIn",
  "timestamp": "2024-01-15T08:30:00.000",
  "latitude": 19.4326,
  "longitude": -99.1332,
  "verificationMethod": "biometric",
  "deviceInfo": { "..." }
}
```

`verificationData` **no aparece** en el mapa cuando es null. Lo mismo con `deviceInfo` cuando no hay geolocalizacion.

---

## Codigos de error

| Codigo | Paso | Descripcion |
|--------|------|-------------|
| `POINT_NOT_FOUND` | 2 | pointResolver retorno null |
| `QR_POINT_MISMATCH` | 3 | El QR no corresponde al punto |
| `QR_EXPIRED` | 3 | El QR ya expiro |
| `DUPLICATE_CHECK_IN` | 4 | Ya tiene un check-in activo |
| `CHECK_OUT_WITHOUT_CHECK_IN` | 4 | Intenta check-out sin check-in previo |
| `DUPLICATE_CHECK_OUT` | 4 | Ya tiene un check-out |
| `OUT_OF_RANGE` | 6 | Fuera del radio permitido |
| `MOCK_LOCATION_DETECTED` | 6 | Ubicacion falsa detectada |
| `BIOMETRIC_FAILED` | 7 | Autenticacion biometrica fallo |
| `UNEXPECTED_ERROR: ...` | Cualquiera | Excepcion no controlada |

Los errores se acumulan en `state.errors` como `List<String>`. El flujo se detiene en el primer error.

---

## Pasos opcionales

La configuracion determina que pasos se ejecutan:

| Config | Efecto |
|--------|--------|
| `requireQr: false` | Salta pasos 1-3 |
| `requireGeolocation: false` | Salta pasos 5-6, no genera `DeviceInfo` |
| `verificationMethod: none` | Salta paso 7 |
| `verificationMethod: biometric` | Paso 7 usa biometria |
| `verificationMethod: selfie` | Paso 7 usa camara, genera base64 |
