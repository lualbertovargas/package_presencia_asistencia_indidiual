# UI Layer

> `lib/src/ui/`

Widgets minimalistas que renderizan el estado del `AttendanceController` usando `ValueListenableBuilder`. Son placeholders funcionales que la app consumidora puede customizar o reemplazar.

---

## AttendanceFlowPage

> `attendance_flow_page.dart`

Contenedor principal. Hace switch por `AttendanceStep` para mostrar la pagina correcta.

```dart
const AttendanceFlowPage({required AttendanceController controller});
```

### Mapeo Step -> Widget

| Step(s) | Widget mostrado |
|---------|-----------------|
| `idle` | `Text('Listo para marcar asistencia')` |
| `scanningQr`, `validatingQr` | `QrScanPage` |
| `locating`, `validatingLocation` | `GeoValidationPage` |
| `verifyingIdentity` | `IdentityValidationPage` |
| `submitting` | `CircularProgressIndicator` |
| `completed`, `error` | `ResultPage` |

### Retry
El boton "Reintentar" en `ResultPage` ejecuta:
```dart
controller.reset();
unawaited(controller.startFlow());
```

---

## QrScanPage

> `qr_scan_page.dart`

Se muestra durante el escaneo y validacion del QR.

**Contenido**: `CircularProgressIndicator` + texto "Escaneando codigo QR..."

---

## GeoValidationPage

> `geo_validation_page.dart`

Se muestra mientras se obtiene y valida la ubicacion.

**Contenido**: `CircularProgressIndicator` + texto "Validando ubicacion..."

---

## IdentityValidationPage

> `identity_validation_page.dart`

Se muestra durante la verificacion biometrica.

**Contenido**: `CircularProgressIndicator` + texto "Verificando identidad..."

---

## ResultPage

> `result_page.dart`

Muestra el resultado final del flujo.

```dart
const ResultPage({
  required AttendanceState state,
  required VoidCallback onRetry,
});
```

### Estado exitoso (`completed`)
- Icono verde `check_circle` (64px)
- Texto "Asistencia registrada"
- Sin boton de retry

### Estado error (`error`)
- Icono rojo `error` (64px)
- Texto "Error"
- Lista de codigos de error separados por coma
- Boton "Reintentar" que invoca `onRetry`

---

## Widget Tests (7)

| Test | Que valida |
|------|------------|
| `qr_scan_page_test.dart` | Renderiza progress indicator y texto |
| `geo_validation_page_test.dart` | Renderiza progress indicator y texto |
| `identity_validation_page_test.dart` | Renderiza progress indicator y texto |
| `result_page_test.dart` (x3) | Estado exitoso, estado error con retry, callback de retry |
| `attendance_flow_page_test.dart` | Renderiza texto idle |

---

## Uso como widget standalone

```dart
Scaffold(
  appBar: AppBar(title: const Text('Marcar Asistencia')),
  body: AttendanceFlowPage(controller: controller),
  floatingActionButton: FloatingActionButton(
    onPressed: () => unawaited(controller.startFlow()),
    child: const Icon(Icons.play_arrow),
  ),
)
```

## Uso con UI custom (sin los widgets del package)

```dart
ValueListenableBuilder<AttendanceState>(
  valueListenable: controller,
  builder: (context, state, _) {
    // Tu UI completamente custom
    return MyCustomAttendanceWidget(state: state);
  },
)
```
