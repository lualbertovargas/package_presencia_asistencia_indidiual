# AttendanceRecord Schema

## Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | `String` | Yes | ID of the user marking attendance |
| `attendancePointId` | `String` | Yes | ID of the attendance point |
| `checkType` | `CheckType` | Yes | `checkIn` or `checkOut` |
| `timestamp` | `DateTime` | Yes | Canonical timestamp for the record |
| `latitude` | `double` | Yes | Latitude where attendance was marked |
| `longitude` | `double` | Yes | Longitude where attendance was marked |
| `verificationMethod` | `VerificationMethod` | Yes | `biometric`, `selfie`, or `none` |
| `verificationData` | `String?` | No | Optional verification payload |
| `deviceInfo` | `DeviceInfo?` | No | Anti-fraud device information |

## DeviceInfo

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `deviceTimestamp` | `DateTime` | Yes | Device-local timestamp |
| `gpsAccuracy` | `double` | Yes | GPS accuracy in meters |
| `isMockLocation` | `bool` | Yes | Whether mock location was detected |
| `locationProvider` | `String` | Yes | Location provider used (e.g., `gps`, `network`) |

## Enums

### CheckType
- `checkIn` - Marks arrival / entry
- `checkOut` - Marks departure / exit

### VerificationMethod
- `biometric` - Fingerprint, Face ID, etc.
- `selfie` - Selfie-based verification (Phase 2)
- `none` - No verification required
