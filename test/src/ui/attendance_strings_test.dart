import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceStrings', () {
    test('has Spanish defaults', () {
      const strings = AttendanceStrings();
      expect(strings.readyToMark, 'Listo para marcar asistencia');
      expect(strings.scanningQr, 'Escaneando codigo QR...');
      expect(strings.validatingLocation, 'Validando ubicacion...');
      expect(strings.verifyingIdentity, 'Verificando identidad...');
      expect(strings.attendanceRegistered, 'Asistencia registrada');
      expect(strings.error, 'Error');
      expect(strings.retry, 'Reintentar');
      expect(strings.cancelled, 'Operacion cancelada');
    });

    test('supports custom overrides', () {
      const strings = AttendanceStrings(
        readyToMark: 'Ready',
        scanningQr: 'Scanning...',
        validatingLocation: 'Validating...',
        verifyingIdentity: 'Verifying...',
        attendanceRegistered: 'Done',
        error: 'Oops',
        retry: 'Again',
        cancelled: 'Cancelled',
      );
      expect(strings.readyToMark, 'Ready');
      expect(strings.scanningQr, 'Scanning...');
      expect(strings.validatingLocation, 'Validating...');
      expect(strings.verifyingIdentity, 'Verifying...');
      expect(strings.attendanceRegistered, 'Done');
      expect(strings.error, 'Oops');
      expect(strings.retry, 'Again');
      expect(strings.cancelled, 'Cancelled');
    });

    test('partial overrides keep defaults for unset fields', () {
      const strings = AttendanceStrings(readyToMark: 'Custom idle');
      expect(strings.readyToMark, 'Custom idle');
      expect(strings.scanningQr, 'Escaneando codigo QR...');
    });
  });
}
