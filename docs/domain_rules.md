# Domain Rules

> `lib/src/domain/rules/`

Clases de validacion pura sin estado. Todas exponen un metodo estatico `validate()` que retorna `List<String>` de codigos de error. Lista vacia = valido.

---

## QrRules

> `qr_rules.dart`

Valida que el QR escaneado sea valido para el punto de asistencia.

### Metodo

```dart
static List<String> validate({
  required QrResult qrResult,
  required AttendancePoint point,
})
```

### Codigos de error

| Codigo | Condicion |
|--------|-----------|
| `QR_POINT_MISMATCH` | `qrResult.attendancePointId != point.id` |
| `QR_EXPIRED` | `qrResult.scannedAt` es posterior a `qrResult.expiresAt` |

### Notas
- Si `expiresAt` es `null`, no se valida expiracion
- Puede retornar ambos errores a la vez

### Tests (6)
- QR valido retorna lista vacia
- QR con punto diferente retorna `QR_POINT_MISMATCH`
- QR expirado retorna `QR_EXPIRED`
- QR sin `expiresAt` no marca expirado
- QR con `scannedAt` antes de `expiresAt` es valido
- QR invalido puede retornar ambos errores

---

## GeoRules

> `geo_rules.dart`

Valida la ubicacion del usuario contra el punto de asistencia usando la formula de Haversine.

### Metodos

```dart
static List<String> validate({
  required GeoPosition position,
  required AttendancePoint point,
  required AttendanceConfig config,
})

static double haversineDistance({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
})
```

### Codigos de error

| Codigo | Condicion |
|--------|-----------|
| `MOCK_LOCATION_DETECTED` | `position.isMockLocation == true` y `config.allowMockLocation == false` |
| `OUT_OF_RANGE` | Distancia Haversine > radio permitido |

### Logica de radio
1. Si `config.geoRadiusOverride != null`, usa ese valor
2. Si no, usa `point.radiusMeters`

### Formula Haversine
Calcula la distancia entre dos puntos en la superficie terrestre:
- Radio de la Tierra: 6,371,000 metros
- Precision: suficiente para radios de 10m a 10km

### Tests (8)
- Posicion dentro del radio y sin mock = valido
- Posicion fuera del radio = `OUT_OF_RANGE`
- Mock location sin permiso = `MOCK_LOCATION_DETECTED`
- Mock location con `allowMockLocation = true` = valido
- `geoRadiusOverride` sobrescribe el radio del punto
- Multiples errores a la vez (lejos + mock)
- Haversine retorna 0 para el mismo punto
- Haversine calcula distancia conocida (~460km CDMX-GDL)

---

## AttendanceRules

> `attendance_rules.dart`

Valida la logica de negocio de asistencia: no doble check-in, no check-out sin check-in.

### Metodo

```dart
static List<String> validate({
  required CheckType checkType,
  required AttendanceRecord? lastRecord,
})
```

### Codigos de error

| Codigo | Condicion |
|--------|-----------|
| `DUPLICATE_CHECK_IN` | Intentar check-in cuando el ultimo registro es check-in |
| `CHECK_OUT_WITHOUT_CHECK_IN` | Intentar check-out sin registro previo |
| `DUPLICATE_CHECK_OUT` | Intentar check-out cuando el ultimo registro es check-out |

### Tabla de verdad

| CheckType | lastRecord | Resultado |
|-----------|------------|-----------|
| `checkIn` | `null` | Valido |
| `checkIn` | `checkOut` | Valido |
| `checkIn` | `checkIn` | `DUPLICATE_CHECK_IN` |
| `checkOut` | `null` | `CHECK_OUT_WITHOUT_CHECK_IN` |
| `checkOut` | `checkIn` | Valido |
| `checkOut` | `checkOut` | `DUPLICATE_CHECK_OUT` |

### Tests (6)
- Check-in sin registro previo = valido
- Check-in despues de check-out = valido
- Check-in duplicado = error
- Check-out despues de check-in = valido
- Check-out sin check-in = error
- Check-out duplicado = error

---

## Total: 20 tests de reglas
