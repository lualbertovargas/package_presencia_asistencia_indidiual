# Guia de Integracion

> Como integrar `attendance_mobile` en tu aplicacion Flutter.

---

## Prerequisitos

El package solo depende de `equatable` y `flutter`. Tu app debe proveer:

- Plugin de camara (`image_picker`, `camera`, etc.)
- Plugin de GPS (`geolocator`, etc.)
- Plugin de biometria (`local_auth`, etc.)
- Plugin de QR (`mobile_scanner`, `qr_code_scanner`, etc.)
- Cliente HTTP (`http`, `dio`, `chopper`, etc.)

---

## Paso 1: Agregar dependencia

```yaml
# pubspec.yaml
dependencies:
  attendance_mobile:
    path: ../attendance_mobile  # o desde git/pub
```

---

## Paso 2: Implementar interfaces

El package define 4 interfaces abstractas + 1 repositorio. Tu app implementa cada una con los plugins que elija.

### CameraService

```dart
import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerCameraService implements CameraService {
  final _picker = ImagePicker();

  @override
  Future<PhotoCapture> takePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (file == null) throw Exception('Captura cancelada');
    final bytes = await file.readAsBytes();
    return PhotoCapture(
      bytes: bytes,
      mimeType: 'image/jpeg',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<bool> isAvailable() async => true;
}
```

### LocationService

```dart
import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorLocationService implements LocationService {
  @override
  Future<GeoPosition> getCurrentPosition() async {
    final pos = await Geolocator.getCurrentPosition();
    return GeoPosition(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      timestamp: pos.timestamp,
      isMockLocation: pos.isMocked,
      provider: 'fused',
    );
  }

  @override
  Future<bool> isAvailable() => Geolocator.isLocationServiceEnabled();
}
```

### BiometricService

```dart
import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:local_auth/local_auth.dart';

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

### QrService

```dart
import 'dart:convert';
import 'package:attendance_mobile/attendance_mobile.dart';

class MobileScannerQrService implements QrService {
  @override
  Future<QrResult> scan() async {
    // Usar mobile_scanner, qr_code_scanner, etc.
    final rawData = await MyQrScanner.scan();
    final decoded = jsonDecode(rawData) as Map<String, dynamic>;
    return QrResult(
      attendancePointId: decoded['pointId'] as String,
      scannedAt: DateTime.now(),
      expiresAt: decoded['expires'] != null
          ? DateTime.parse(decoded['expires'] as String)
          : null,
      rawData: rawData,
    );
  }
}
```

### AttendanceRepository

```dart
import 'dart:convert';
import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:http/http.dart' as http;

class ApiAttendanceRepository implements AttendanceRepository {
  ApiAttendanceRepository({required this.client, required this.token});

  final http.Client client;
  final String token;

  @override
  Future<AttendanceResult> submitAttendance(AttendanceRecord record) async {
    final response = await client.post(
      Uri.parse('https://api.miapp.com/v1/attendance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(record.toMap()),
    );

    if (response.statusCode == 200) {
      return const AttendanceResult.success();
    }
    return AttendanceResult.failure(
      errorCode: 'SERVER_ERROR',
      errorMessage: response.body,
    );
  }

  @override
  Future<AttendanceRecord?> getLastRecord(
    String userId,
    String pointId,
  ) async {
    // Consultar API o cache local para saber
    // si el usuario ya tiene un check-in activo
    return null;
  }
}
```

---

## Paso 3: Solicitar permisos ANTES del flujo

El package **no maneja permisos**. Tu app debe solicitarlos antes de crear el controller:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermissions(VerificationMethod method) async {
  final permissions = <Permission>[
    Permission.location,
  ];

  if (method == VerificationMethod.selfie) {
    permissions.add(Permission.camera);
  }

  final statuses = await permissions.request();

  return statuses.values.every((s) => s.isGranted);
}
```

### Ejemplo completo de solicitud

```dart
Future<void> onMarkAttendance() async {
  final method = VerificationMethod.selfie;

  // 1. Permisos
  final granted = await requestPermissions(method);
  if (!granted) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Permisos requeridos'),
        content: Text('Necesitamos acceso a camara y ubicacion.'),
      ),
    );
    return;
  }

  // 2. Verificar disponibilidad de servicios
  final gpsEnabled = await locationService.isAvailable();
  if (!gpsEnabled) {
    // Pedir al usuario que active el GPS
    return;
  }

  if (method == VerificationMethod.selfie) {
    final cameraReady = await cameraService.isAvailable();
    if (!cameraReady) {
      // Notificar que no hay camara disponible
      return;
    }
  }

  // 3. Ahora si, arrancar el flujo del package
  await controller.startFlow();
}
```

---

## Paso 4: Crear el controller

```dart
final controller = AttendanceController(
  config: const AttendanceConfig(
    requireQr: true,
    requireGeolocation: true,
    verificationMethod: VerificationMethod.selfie,
  ),
  userId: 'user-123',
  checkType: CheckType.checkIn,
  repository: ApiAttendanceRepository(client: client, token: token),
  qrService: MobileScannerQrService(),
  locationService: GeolocatorLocationService(),
  biometricService: LocalAuthBiometricService(),
  cameraService: ImagePickerCameraService(),
  pointResolver: (id) async {
    // Resolver desde tu API o cache local
    final response = await client.get(
      Uri.parse('https://api.miapp.com/v1/points/$id'),
    );
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AttendancePoint(
      id: data['id'] as String,
      name: data['name'] as String,
      latitude: data['latitude'] as double,
      longitude: data['longitude'] as double,
      radiusMeters: data['radius'] as double,
    );
  },
);
```

### Parametros opcionales segun configuracion

No todos los servicios son necesarios. Depende de tu `AttendanceConfig`:

| Config | Servicios requeridos |
|--------|---------------------|
| `requireQr: true` | `qrService` + `pointResolver` |
| `requireGeolocation: true` | `locationService` |
| `verificationMethod: biometric` | `biometricService` |
| `verificationMethod: selfie` | `cameraService` |
| `verificationMethod: none` | Ninguno adicional |

Si `requireQr: false` y `requireGeolocation: false` y `verificationMethod: none`, solo necesitas `repository`.

---

## Paso 5: Escuchar el estado

### Opcion A: ValueListenableBuilder (UI reactiva)

```dart
ValueListenableBuilder<AttendanceState>(
  valueListenable: controller,
  builder: (context, state, _) {
    switch (state.step) {
      case AttendanceStep.idle:
        return ElevatedButton(
          onPressed: () => controller.startFlow(),
          child: Text('Marcar asistencia'),
        );
      case AttendanceStep.completed:
        return Text('Registrado: ${state.record!.attendancePointId}');
      case AttendanceStep.error:
        return Column(
          children: [
            Text('Error: ${state.errors.join(", ")}'),
            ElevatedButton(
              onPressed: () {
                controller.reset();
                controller.startFlow();
              },
              child: Text('Reintentar'),
            ),
          ],
        );
      default:
        return CircularProgressIndicator();
    }
  },
)
```

### Opcion B: Listener programatico

```dart
controller.addListener(() {
  final state = controller.value;
  if (state.step == AttendanceStep.completed) {
    Navigator.of(context).pop(state.record);
  }
  if (state.step == AttendanceStep.error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.errors.first)),
    );
  }
});

await controller.startFlow();
```

### Opcion C: UI incluida del package

```dart
// El package trae paginas minimas listas para usar
AttendanceFlowPage(controller: controller);
```

---

## Paso 6: Leer el resultado

```dart
if (controller.value.step == AttendanceStep.completed) {
  final record = controller.value.record!;

  // Como objeto Dart
  print(record.userId);
  print(record.verificationData); // base64 de la selfie

  // Como Map para JSON
  final map = record.toMap();
  final json = jsonEncode(map);

  // El mapa contiene:
  // {
  //   "userId": "user-123",
  //   "attendancePointId": "point-1",
  //   "checkType": "checkIn",
  //   "timestamp": "2024-01-15T08:30:00.000",
  //   "latitude": 19.4326,
  //   "longitude": -99.1332,
  //   "verificationMethod": "selfie",
  //   "verificationData": "/9j/4AAQSkZJRg...",  <-- base64
  //   "deviceInfo": {
  //     "deviceTimestamp": "2024-01-15T08:30:00.000",
  //     "gpsAccuracy": 5.0,
  //     "isMockLocation": false,
  //     "locationProvider": "gps"
  //   }
  // }
}
```

---

## Paso 7: Limpiar recursos

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

---

## Responsabilidades: Package vs App

| Responsabilidad | Package | App |
|----------------|---------|-----|
| Orquestar el flujo de asistencia | Si | - |
| Validar QR (match, expiracion) | Si | - |
| Validar geolocalizacion (radio, mock) | Si | - |
| Validar duplicados (check-in/out) | Si | - |
| Convertir foto a base64 | Si | - |
| Armar el record con toMap() | Si | - |
| Solicitar permisos del OS | - | Si |
| Implementar captura de foto | - | Si |
| Implementar obtencion de GPS | - | Si |
| Implementar escaneo de QR | - | Si |
| Implementar biometria | - | Si |
| Hacer HTTP POST al backend | - | Si |
| Manejar autenticacion/tokens | - | Si |
| Manejar errores de red/offline | - | Si |
| Navegacion entre pantallas | - | Si |
| Diseno UI / tema visual | - | Si |

---

## Manejo de errores comunes

### Error en la app consumidora

```dart
controller.addListener(() {
  final errors = controller.value.errors;

  for (final code in errors) {
    switch (code) {
      case 'POINT_NOT_FOUND':
        showError('Punto de asistencia no encontrado');
      case 'QR_EXPIRED':
        showError('El codigo QR ha expirado, solicita uno nuevo');
      case 'OUT_OF_RANGE':
        showError('Estas fuera del rango permitido');
      case 'MOCK_LOCATION_DETECTED':
        showError('Ubicacion falsa detectada');
      case 'DUPLICATE_CHECK_IN':
        showError('Ya marcaste entrada');
      case 'CHECK_OUT_WITHOUT_CHECK_IN':
        showError('Primero debes marcar entrada');
      case 'BIOMETRIC_FAILED':
        showError('Verificacion biometrica fallida');
      default:
        if (code.startsWith('UNEXPECTED_ERROR')) {
          showError('Error inesperado, intenta de nuevo');
        } else {
          showError('Error: $code');
        }
    }
  }
});
```

---

## Ejemplo minimo completo

```dart
import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late final AttendanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AttendanceController(
      config: const AttendanceConfig(
        requireQr: true,
        requireGeolocation: true,
        verificationMethod: VerificationMethod.selfie,
      ),
      userId: 'user-123',
      checkType: CheckType.checkIn,
      repository: MyRepository(),
      qrService: MyQrService(),
      locationService: MyLocationService(),
      cameraService: MyCameraService(),
      pointResolver: (id) => MyApi.getPoint(id),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
      body: AttendanceFlowPage(controller: _controller),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _controller.startFlow(),
        child: const Icon(Icons.qr_code),
      ),
    );
  }
}
```
