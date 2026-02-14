# Changelog - Fase 1

## [ft][01] attendance_mobile: Implementar modulo de asistencia presencial con QR, geolocalizacion y biometria

**Commit**: `23f4930`
**Fecha**: 2026-02-14
**Ticket**: #01
**Tipo**: Feature

---

### Resumen

Implementacion completa de Fase 1 del package `attendance_mobile`. Un modulo Flutter vendible e integrable para asistencia presencial que combina escaneo QR, validacion por geolocalizacion (Haversine) y verificacion biometrica del dispositivo.

**Principio fundamental**: El package NO habla con HTTP, NO conoce endpoints, NO maneja auth. Solo genera eventos de asistencia, valida reglas, pide verificaciones y entrega un `AttendanceRecord`. La app consumidora provee las implementaciones concretas.

---

### Estadisticas

| Metrica | Valor |
|---------|-------|
| Archivos creados | 45 |
| Archivos modificados | 2 |
| Archivos eliminados | 3 |
| Archivos movidos | 17 (.github/, .gitignore) |
| Lineas agregadas | +2,431 |
| Lineas eliminadas | -64 |
| Tests totales | 78 |
| Warnings de analisis | 0 |

---

### Estructura final del proyecto

```
attendance_mobile/
├── lib/
│   ├── attendance_mobile.dart              # API publica (barrel principal)
│   └── src/
│       ├── domain/
│       │   ├── models/                     # 9 value objects + barrel
│       │   ├── rules/                      # 3 clases de validacion + barrel
│       │   └── services/                   # 3 interfaces abstractas + barrel
│       ├── data/                           # Repositorio abstracto + barrel
│       ├── application/                    # Controller + State + barrel
│       └── ui/                             # 5 widgets + barrel
├── test/
│   └── src/
│       ├── domain/models/                  # 9 tests de modelos
│       ├── domain/rules/                   # 3 tests de reglas
│       ├── application/                    # 2 tests (controller + state)
│       └── ui/                             # 5 widget tests
├── docs/
│   ├── CHANGELOG_FASE1.md                  # Este archivo
│   ├── attendance_record_schema.md         # Schema del record
│   ├── domain_models.md                    # Documentacion de modelos
│   ├── domain_rules.md                     # Documentacion de reglas
│   ├── services_and_data.md                # Documentacion de servicios
│   ├── application_layer.md                # Documentacion del controller
│   └── ui_layer.md                         # Documentacion de UI
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

### Documentacion por funcionalidad

| Documento | Contenido |
|-----------|-----------|
| [domain_models.md](domain_models.md) | Los 9 value objects: campos, tipos, proposito |
| [domain_rules.md](domain_rules.md) | Reglas de QR, geolocalizacion y asistencia |
| [services_and_data.md](services_and_data.md) | Interfaces abstractas y repositorio |
| [application_layer.md](application_layer.md) | Controller, state machine, flujo completo |
| [ui_layer.md](ui_layer.md) | Widgets y paginas del flujo |
| [attendance_record_schema.md](attendance_record_schema.md) | Schema del record final |

---

### Lo que se hizo por fase

#### Fase 0: Housekeeping
- Restaurado `pubspec.yaml` (sdk: ^3.9.0, flutter: ^3.35.0, equatable: ^2.0.7)
- Movidos `.github/` y `.gitignore` de `attendance_workspace/` a raiz
- Eliminado directorio `attendance_workspace/`
- `flutter pub get` exitoso

#### Fase 1: Domain Models
- 9 value objects con `Equatable` y `const` constructors
- 1 barrel file (`models.dart`)
- 29 tests unitarios

#### Fase 2: Domain Rules
- `QrRules`: valida match de punto + vigencia
- `GeoRules`: Haversine + radio + deteccion mock
- `AttendanceRules`: no doble check-in, no check-out sin check-in
- 20 tests unitarios

#### Fase 3: Service Interfaces
- `LocationService`, `BiometricService`, `QrService`
- Todas abstractas - la app consumidora implementa

#### Fase 4: Data Layer
- `AttendanceRepository` abstracto
- `submitAttendance()` + `getLastRecord()`

#### Fase 5: Application Layer
- `AttendanceState` con enum de 9 pasos + `copyWith`
- `AttendanceController` (ValueNotifier) con flujo de 10 pasos
- `AttendancePointResolver` typedef
- 22 tests (15 escenarios del controller)

#### Fase 6: UI Layer
- 5 widgets con `ValueListenableBuilder`
- Switch por `AttendanceStep` en `AttendanceFlowPage`
- 7 widget tests

#### Fase 7-9: API, Docs, Validacion
- API publica actualizada en `lib/attendance_mobile.dart`
- Placeholder `AttendanceMobile` class eliminada
- `dart analyze` = 0 issues
- `flutter test` = 78 tests passing

---

### Decisiones tecnicas

| Decision | Razon |
|----------|-------|
| `ValueNotifier` en vez de Bloc/Riverpod | Cero dependencias externas de state management |
| `Equatable` para todos los modelos | Value equality sin code generation, estandar VGV |
| Errores como `List<String>` | Codigos componibles, no excepciones |
| `AttendancePointResolver` callback | Flexibilidad: el consumidor resuelve por API, cache, etc. |
| Interfaces abstractas para servicios | El package no depende de plugins concretos |
| `unawaited()` para fire-and-forget | Cumple `discarded_futures` de VGV analysis |

---

### Dependencias

```yaml
dependencies:
  equatable: ^2.0.7
  flutter: sdk

dev_dependencies:
  flutter_test: sdk
  mocktail: ^1.0.4
  very_good_analysis: ^10.0.0
```

---

### Archivos eliminados

| Archivo | Razon |
|---------|-------|
| `lib/src/attendance_mobile.dart` | Placeholder del scaffold VGV, reemplazado por arquitectura real |
| `test/src/attendance_mobile_test.dart` | Test del placeholder eliminado |
| `attendance_workspace/` | Directorio temporal del scaffold, archivos ya movidos a raiz |
