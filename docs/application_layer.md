# Application Layer

> `lib/src/application/`

El corazon del package. Contiene el estado y el orquestador del flujo de asistencia.

---

## AttendanceStep (Enum)

> `attendance_state.dart`

Maquina de estados del flujo:

```
idle -> scanningQr -> validatingQr -> locating -> validatingLocation -> verifyingIdentity -> submitting -> completed
                                                                                                       \-> error
```

| Paso | Descripcion | Se muestra |
|------|-------------|------------|
| `idle` | Sin accion en progreso | Texto "Listo para marcar" |
| `scanningQr` | Escaneando codigo QR | QrScanPage |
| `validatingQr` | Validando QR contra punto | QrScanPage |
| `locating` | Obteniendo ubicacion GPS | GeoValidationPage |
| `validatingLocation` | Validando radio y mock | GeoValidationPage |
| `verifyingIdentity` | Verificando biometria | IdentityValidationPage |
| `submitting` | Enviando registro | CircularProgressIndicator |
| `completed` | Exito | ResultPage (verde) |
| `error` | Error en cualquier paso | ResultPage (rojo + retry) |

---

## AttendanceState

> `attendance_state.dart`

Estado inmutable del flujo. Extiende `Equatable`.

```dart
class AttendanceState extends Equatable {
  const AttendanceState({
    this.step = AttendanceStep.idle,
    this.errors = const [],
    this.record,
  });

  final AttendanceStep step;
  final List<String> errors;
  final AttendanceRecord? record;

  AttendanceState copyWith({...});
}
```

| Campo | Tipo | Default | Descripcion |
|-------|------|---------|-------------|
| `step` | `AttendanceStep` | `idle` | Paso actual |
| `errors` | `List<String>` | `[]` | Codigos de error |
| `record` | `AttendanceRecord?` | `null` | Record resultante (solo en `completed`) |

---

## AttendanceController

> `attendance_controller.dart`

Orquestador del flujo completo. Extiende `ValueNotifier<AttendanceState>`.

### Constructor

```dart
AttendanceController({
  required AttendanceConfig config,
  required String userId,
  required CheckType checkType,
  required AttendanceRepository repository,
  QrService? qrService,
  LocationService? locationService,
  BiometricService? biometricService,
  AttendancePointResolver? pointResolver,
})
```

### AttendancePointResolver

```dart
typedef AttendancePointResolver = Future<AttendancePoint?> Function(String id);
```

Callback que la app consumidora usa para resolver un `AttendancePoint` a partir de un ID. Puede consultar API, cache local, etc.

### Metodos

| Metodo | Descripcion |
|--------|-------------|
| `startFlow()` | Inicia el flujo completo de asistencia |
| `reset()` | Regresa al estado `idle` |

### Flujo de `startFlow()`

```
1. [scanningQr]         -> qrService.scan()
2. [validatingQr]       -> pointResolver(qrResult.attendancePointId)
3. [validatingQr]       -> QrRules.validate()
4. [validatingQr]       -> repository.getLastRecord() + AttendanceRules.validate()
5. [locating]           -> locationService.getCurrentPosition()
6. [validatingLocation] -> GeoRules.validate()
7. [verifyingIdentity]  -> biometricService.authenticate()
8. [submitting]         -> Construir AttendanceRecord + DeviceInfo
9. [submitting]         -> repository.submitAttendance()
10. [completed/error]   -> Resultado final
```

### Salidas de error (cortocircuito)

| Paso | Error | Codigo |
|------|-------|--------|
| 2 | Punto no encontrado | `POINT_NOT_FOUND` |
| 3 | QR no valido | `QR_POINT_MISMATCH`, `QR_EXPIRED` |
| 4 | Doble check-in / sin check-in | `DUPLICATE_CHECK_IN`, `CHECK_OUT_WITHOUT_CHECK_IN`, `DUPLICATE_CHECK_OUT` |
| 6 | Fuera de radio / mock | `OUT_OF_RANGE`, `MOCK_LOCATION_DETECTED` |
| 7 | Biometria fallida | `BIOMETRIC_FAILED` |
| 9 | Envio fallido | Codigo del repositorio (e.g., `SERVER_ERROR`) |
| Cualquiera | Exception no esperada | `UNEXPECTED_ERROR: ...` |

### Pasos opcionales

| Config | Paso que se salta |
|--------|--------------------|
| `requireQr = false` | Pasos 1-3 |
| `requireGeolocation = false` | Pasos 5-6 |
| `verificationMethod = none` | Paso 7 |

### Uso

```dart
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
  pointResolver: (id) async => await myApi.getPoint(id),
);

// Escuchar cambios
controller.addListener(() {
  print('Step: ${controller.value.step}');
});

// Iniciar flujo
await controller.startFlow();

// Verificar resultado
if (controller.value.step == AttendanceStep.completed) {
  final record = controller.value.record!;
  print('Asistencia registrada: ${record.attendancePointId}');
}

// Reintentar
controller.reset();
await controller.startFlow();

// Limpiar
controller.dispose();
```

---

## Tests del Controller (15 escenarios)

| # | Escenario | Resultado esperado |
|---|-----------|-------------------|
| 1 | Estado inicial | `idle` |
| 2 | Flujo completo exitoso | `completed` con record |
| 3 | Punto no encontrado | `error` + `POINT_NOT_FOUND` |
| 4 | QR no matchea punto | `error` + `QR_POINT_MISMATCH` |
| 5 | QR expirado | `error` + `QR_EXPIRED` |
| 6 | Doble check-in | `error` + `DUPLICATE_CHECK_IN` |
| 7 | Check-out sin check-in | `error` + `CHECK_OUT_WITHOUT_CHECK_IN` |
| 8 | Fuera de rango | `error` + `OUT_OF_RANGE` |
| 9 | Mock location detectado | `error` + `MOCK_LOCATION_DETECTED` |
| 10 | Biometria fallida | `error` + `BIOMETRIC_FAILED` |
| 11 | Envio fallido | `error` + `SERVER_ERROR` |
| 12 | Exception inesperada | `error` + `UNEXPECTED_ERROR` |
| 13 | Skip QR (requireQr=false) | `completed`, `qrService.scan()` nunca llamado |
| 14 | Skip geo (requireGeo=false) | `completed`, `locationService` nunca llamado |
| 15 | Skip biometric (method=none) | `completed`, `biometricService` nunca llamado |
| 16 | Reset despues de flujo | `idle`, errors vacios, record null |

**Total: 22 tests (16 controller + 6 state)**
